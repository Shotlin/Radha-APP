// Offline-first sync service.
//
// Single entry point for state-changing API calls. Behaviour:
//
//   * `enqueue<T>(...)`           — try the request immediately; persist on
//     transient failure (network down / 5xx) and return `null` so the
//     caller can render an "It'll sync when you're back online" UX.
//   * `processQueue()`            — drain the durable queue. Each row is
//     POSTed; on 2xx the row is deleted, on transient failure the row's
//     retry counter is bumped and `next_retry_at` is set via exponential
//     backoff (`min(60s, 1s * 2^retry_count)`). After [maxRetries] failures
//     the row is removed and the user is notified.
//   * `evictExpiredProductCache()` — drop product-cache rows older than
//     [ttl] (24h by default).
//
// Connectivity wiring lives in [SyncBootstrap]: it listens for online
// transitions via `connectivity_plus` and re-runs `processQueue` whenever
// the device regains network. The bootstrap is `ref.read` from
// `BootstrapController` (Task 5) so processing also fires on cold start.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/dio_provider.dart';
import 'db.dart';

/// Maximum number of retry attempts before a queued row is dropped and
/// the user is notified. Mirrors task 16: "max 6 retries".
const int kSyncMaxRetries = 6;

/// Backoff cap. The 6th retry sits at `min(60s, 32s) = 32s`; we still cap
/// at 60s defensively in case the constant is bumped later.
const Duration kSyncBackoffCap = Duration(seconds: 60);

/// Default TTL for the product cache.
const Duration kProductCacheTtl = Duration(hours: 24);

/// Notification surface for "queue exhausted" events. Defaults to a debug
/// log; the UI layer can swap in a snackbar/notification host via
/// [syncNotifierProvider].
typedef SyncNotifier =
    void Function(String message, {Map<String, dynamic>? context});

/// Default debug-print notifier used when no UI host has registered.
void defaultSyncNotifier(String message, {Map<String, dynamic>? context}) {
  if (kDebugMode) {
    debugPrint('[sync] $message ${context ?? ''}');
  }
}

/// Riverpod handle for the notifier callback. Override at the app shell
/// (e.g. inside `RootShell`) to bind a real snackbar/notification handler.
final syncNotifierProvider = Provider<SyncNotifier>((ref) {
  return defaultSyncNotifier;
});

/// Outcome surfaced to the caller of [SyncService.enqueue].
@immutable
class EnqueueResult<T> {
  const EnqueueResult({
    required this.synced,
    required this.queued,
    this.value,
    this.queueRowId,
  });

  /// True if the request reached the backend with a 2xx response.
  final bool synced;

  /// True if the request was persisted to `pending_writes` for later retry.
  final bool queued;

  /// Parsed response value when [synced] is true.
  final T? value;

  /// Row id in `pending_writes` when [queued] is true. Useful for tests
  /// and for observability / cancellation in the future.
  final int? queueRowId;
}

/// Function abstraction for "is the device offline right now?" Pulled out
/// so unit tests can sub in a fake without depending on the real
/// `connectivity_plus` plugin (whose `Connectivity` class is a singleton
/// without an extension point).
typedef OfflineProbe = Future<bool> Function();

/// Function abstraction for "stream of connectivity transitions". Each
/// emitted event is the current `List<ConnectivityResult>`. The bootstrap
/// only needs the offline → online transition signal.
typedef ConnectivityChanges = Stream<List<ConnectivityResult>> Function();

/// Real implementation backed by the `connectivity_plus` singleton.
Future<bool> defaultOfflineProbe() async {
  try {
    final results = await Connectivity().checkConnectivity();
    if (results.isEmpty) return true;
    return results.every((r) => r == ConnectivityResult.none);
  } catch (_) {
    // Plugin unavailable (e.g. test runner without bindings) — assume
    // online and let the actual request decide.
    return false;
  }
}

/// Real implementation of [ConnectivityChanges].
Stream<List<ConnectivityResult>> defaultConnectivityChanges() {
  try {
    return Connectivity().onConnectivityChanged;
  } catch (_) {
    return const Stream<List<ConnectivityResult>>.empty();
  }
}

/// Single offline-first entry point used by every state-changing screen.
class SyncService {
  SyncService({
    required RadhaDatabase db,
    required Dio dio,
    required SyncNotifier notifier,
    OfflineProbe? offlineProbe,
    DateTime Function()? clock,
  }) : _db = db,
       _dio = dio,
       _notify = notifier,
       _offlineProbe = offlineProbe ?? defaultOfflineProbe,
       _now = clock ?? DateTime.now;

  final RadhaDatabase _db;
  final Dio _dio;
  final SyncNotifier _notify;
  final OfflineProbe _offlineProbe;
  final DateTime Function() _now;

  /// Single-flight guard so concurrent triggers (e.g. cold start + a
  /// connectivity-restore event firing in quick succession) don't double-
  /// process the same rows.
  bool _draining = false;

  /// Tries the write immediately. On success returns the parsed body. On
  /// a transient failure (offline, network error, 5xx) the row is persisted
  /// to `pending_writes` and a queued result is returned. Non-transient
  /// failures (4xx other than 408 / 429) bubble out as `DioException`.
  Future<EnqueueResult<T>> enqueue<T>({
    required String endpoint,
    required String method,
    required Map<String, dynamic> body,
    T Function(Map<String, dynamic> json)? parser,
  }) async {
    final upperMethod = method.toUpperCase();
    final encodedBody = jsonEncode(body);

    // 1. Check connectivity. If we're offline, skip the network round-trip
    //    entirely and persist the row.
    if (await _isOffline()) {
      final id = await _persist(endpoint, upperMethod, encodedBody);
      return EnqueueResult<T>(synced: false, queued: true, queueRowId: id);
    }

    // 2. Otherwise attempt the request. Handle transient failures by
    //    persisting; let permanent failures throw.
    try {
      final response = await _dio.request<dynamic>(
        endpoint,
        data: body,
        options: Options(method: upperMethod),
      );
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final value = _parseResponse<T>(response.data, parser);
        return EnqueueResult<T>(synced: true, queued: false, value: value);
      }
      // Non-2xx without a thrown DioException is unusual; treat anything
      // 5xx-shaped as transient, else surface to the caller.
      if ((response.statusCode ?? 500) >= 500) {
        final id = await _persist(
          endpoint,
          upperMethod,
          encodedBody,
          error: 'HTTP ${response.statusCode}',
        );
        return EnqueueResult<T>(synced: false, queued: true, queueRowId: id);
      }
      // Any other non-2xx is a hard failure — let the caller deal with it.
      throw DioException.badResponse(
        statusCode: response.statusCode ?? 0,
        requestOptions: response.requestOptions,
        response: response,
      );
    } on DioException catch (e) {
      if (_isTransient(e)) {
        final id = await _persist(
          endpoint,
          upperMethod,
          encodedBody,
          error: _summariseError(e),
        );
        return EnqueueResult<T>(synced: false, queued: true, queueRowId: id);
      }
      rethrow;
    } on SocketException catch (e) {
      // Belt-and-braces — Dio normally wraps these in DioException, but we
      // catch it here too in case a custom adapter lets it bubble through.
      final id = await _persist(
        endpoint,
        upperMethod,
        encodedBody,
        error: e.message,
      );
      return EnqueueResult<T>(synced: false, queued: true, queueRowId: id);
    }
  }

  /// Drains the queue. Loops over every row whose `next_retry_at <= now`,
  /// retries it, and either deletes (success) or bumps the backoff watermark
  /// (transient failure). Rows that exhaust [kSyncMaxRetries] are dropped
  /// and the user is notified.
  Future<void> processQueue() async {
    if (_draining) return;
    _draining = true;
    try {
      // Bail early if we're still offline — saves a database round-trip.
      if (await _isOffline()) return;

      final due = await _db.getDuePendingWrites(_now());
      for (final row in due) {
        await _processOne(row);
      }
    } finally {
      _draining = false;
    }
  }

  /// Drops cached product rows older than [ttl].
  Future<int> evictExpiredProductCache({Duration ttl = kProductCacheTtl}) {
    final cutoff = _now().subtract(ttl);
    return _db.evictCachedProductsBefore(cutoff);
  }

  // ── internals ────────────────────────────────────────────────────────

  Future<int> _persist(
    String endpoint,
    String method,
    String body, {
    String? error,
  }) {
    return _db.enqueueWrite(
      endpoint: endpoint,
      method: method,
      bodyJson: body,
      createdAt: _now(),
      lastError: error,
      // Ready immediately for the queue runner to pick up next time.
      nextRetryAt: null,
      retryCount: 0,
    );
  }

  Future<void> _processOne(PendingWrite row) async {
    Map<String, dynamic>? body;
    if (row.bodyJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(row.bodyJson);
        if (decoded is Map<String, dynamic>) body = decoded;
      } catch (_) {
        // Corrupt body — drop the row so it doesn't poison the queue.
        await _db.deletePendingWrite(row.id);
        _notify(
          'Dropped a corrupt offline write',
          context: {'id': row.id, 'endpoint': row.endpoint},
        );
        return;
      }
    }

    try {
      final response = await _dio.request<dynamic>(
        row.endpoint,
        data: body,
        options: Options(method: row.method),
      );
      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300) {
        await _db.deletePendingWrite(row.id);
        return;
      }
      // 5xx is transient; anything else is a hard failure.
      if (status >= 500) {
        await _scheduleRetry(row, error: 'HTTP $status');
      } else {
        await _db.deletePendingWrite(row.id);
        _notify(
          'Dropped offline write after server rejected it',
          context: {'id': row.id, 'endpoint': row.endpoint, 'status': status},
        );
      }
    } on DioException catch (e) {
      if (_isTransient(e)) {
        await _scheduleRetry(row, error: _summariseError(e));
      } else {
        await _db.deletePendingWrite(row.id);
        _notify(
          'Dropped offline write: ${e.response?.statusCode ?? "rejected"}',
          context: {'id': row.id, 'endpoint': row.endpoint},
        );
      }
    } on SocketException catch (e) {
      await _scheduleRetry(row, error: e.message);
    }
  }

  Future<void> _scheduleRetry(PendingWrite row, {String? error}) async {
    final newCount = row.retryCount + 1;
    if (newCount >= kSyncMaxRetries) {
      await _db.deletePendingWrite(row.id);
      _notify(
        'Couldn\'t sync ${row.method} ${row.endpoint} after '
        '$kSyncMaxRetries attempts',
        context: {'id': row.id, 'endpoint': row.endpoint, 'lastError': error},
      );
      return;
    }
    await _db.bumpRetry(
      id: row.id,
      newRetryCount: newCount,
      nextRetryAt: _now().add(_backoffFor(newCount)),
      error: error,
    );
  }

  /// Exponential backoff: 1s, 2s, 4s, 8s, 16s, 32s — capped at 60s.
  static Duration _backoffFor(int retryCount) {
    final exp = 1 << (retryCount - 1).clamp(0, 30);
    final candidate = Duration(seconds: exp);
    return candidate > kSyncBackoffCap ? kSyncBackoffCap : candidate;
  }

  Future<bool> _isOffline() => _offlineProbe();

  bool _isTransient(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      return true;
    }
    final status = e.response?.statusCode ?? 0;
    return status >= 500 && status < 600;
  }

  String _summariseError(DioException e) {
    final status = e.response?.statusCode;
    if (status != null) return 'HTTP $status';
    return e.message ?? e.type.name;
  }

  T? _parseResponse<T>(
    dynamic data,
    T Function(Map<String, dynamic> json)? parser,
  ) {
    if (parser == null) return null;
    if (data is Map<String, dynamic>) return parser(data);
    return null;
  }
}

// ─── Riverpod handles + bootstrap ───────────────────────────────────────────

/// Provides the singleton [SyncService] for the running app.
final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(radhaDatabaseProvider);
  final dio = ref.watch(dioProvider);
  final notifier = ref.watch(syncNotifierProvider);
  return SyncService(db: db, dio: dio, notifier: notifier);
});

/// Wires connectivity events to the sync service. The bootstrap controller
/// (Task 5) reads this once at cold start to:
///
///   * fire an initial `processQueue()` (so anything stale is drained on
///     launch)
///   * subscribe to `connectivity_plus` and re-fire `processQueue()` every
///     time we transition from offline → online
///
/// Returns a `void` — the side-effect is the subscription.
final syncBootstrapProvider = Provider<SyncBootstrap>((ref) {
  final service = ref.watch(syncServiceProvider);
  final boot = SyncBootstrap(service: service);
  ref.onDispose(boot.dispose);
  // Fire-and-forget the initial drain. Failures inside the service surface
  // via the notifier, so we don't need to await here.
  // ignore: discarded_futures
  boot.start();
  return boot;
});

/// Owns the lifecycle of the connectivity-driven re-sync loop.
class SyncBootstrap {
  SyncBootstrap({
    required SyncService service,
    ConnectivityChanges? connectivityChanges,
  }) : _service = service,
       _connectivityChanges = connectivityChanges ?? defaultConnectivityChanges;

  final SyncService _service;
  final ConnectivityChanges _connectivityChanges;
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    // Initial drain — anything queued from a previous session.
    await _service.processQueue();

    // Listen for connectivity changes. The plugin emits a fresh value on
    // every transition; we only care about offline→online (i.e. a result
    // that contains anything other than `none`).
    try {
      _sub = _connectivityChanges().listen((event) async {
        final online =
            event.isNotEmpty && event.any((r) => r != ConnectivityResult.none);
        if (online) {
          // ignore: discarded_futures
          _service.processQueue();
        }
      });
    } catch (_) {
      // Test harness without a platform binding — the bootstrap still
      // runs the initial drain above, which is what unit tests care about.
    }
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
    _started = false;
  }
}

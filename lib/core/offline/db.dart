// Drift database for the offline-first queue + product cache.
//
// Two tables:
//   * `pending_writes` — durable journal of state-changing API requests that
//     either failed (network / 5xx) or were enqueued while offline. Each
//     row carries the endpoint, HTTP method, JSON body, retry counter,
//     last-seen error, and a `next_retry_at` watermark used by
//     [SyncService.processQueue] to gate exponential backoff.
//   * `cached_products` — short-lived product-lookup cache keyed by EAN.
//     The mobile app reads this when offline so previously-seen products
//     still render their detail card. `evictExpiredProductCache` drops
//     entries older than the configured TTL (24h by default).
//
// Both tables persist in `radha.db` inside the app documents directory on
// device. Tests pass an in-memory `NativeDatabase.memory()` directly via
// the [RadhaDatabase.forTesting] constructor — the production opener is
// only consulted when no executor is supplied.

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'db.g.dart';

// ─── Tables ─────────────────────────────────────────────────────────────────

/// Durable journal of API writes that need to be (re)attempted.
@DataClassName('PendingWrite')
class PendingWrites extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Path-only endpoint, e.g. `/api/v1/scans`. Combined with the Dio base
  /// URL at flush time so we don't bake the host into persisted rows.
  TextColumn get endpoint => text()();

  /// HTTP verb in upper-case (`POST`, `PATCH`, `PUT`, `DELETE`).
  TextColumn get method => text()();

  /// JSON-serialised request body. Empty string means no body.
  TextColumn get bodyJson => text()();

  /// Wall-clock millis at enqueue time. Used for FIFO ordering when
  /// `next_retry_at` ties.
  IntColumn get createdAt => integer()();

  /// Number of failed attempts so far. Starts at 0; bumped each time the
  /// queue runner hits a transient error.
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  /// Last error message (truncated). Surfaced in the SyncStatusBanner once
  /// the row has exhausted its retry budget.
  TextColumn get lastError => text().nullable()();

  /// Earliest wall-clock millis at which the row is eligible for retry.
  /// `null` means "ready immediately" (the value at enqueue time, before
  /// the first failure).
  IntColumn get nextRetryAt => integer().nullable()();
}

/// Local copy of `GET /products/ean/:ean` responses keyed by EAN, so the
/// scanner can render a previously-seen product while offline.
@DataClassName('CachedProduct')
class CachedProducts extends Table {
  TextColumn get ean => text()();
  TextColumn get payloadJson => text()();
  IntColumn get fetchedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {ean};
}

// ─── Database ───────────────────────────────────────────────────────────────

@DriftDatabase(tables: [PendingWrites, CachedProducts])
class RadhaDatabase extends _$RadhaDatabase {
  /// Production opener — resolves the docs dir lazily so the database is
  /// only opened once (and only when a Drift query actually runs).
  RadhaDatabase() : super(_openConnection());

  /// Test/override constructor. Pass `NativeDatabase.memory()` for hermetic
  /// unit tests, or a custom `LazyDatabase` for migration tests.
  RadhaDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  // ── Pending writes queries ────────────────────────────────────────────

  /// Inserts a new pending write and returns its auto-incremented id.
  Future<int> enqueueWrite({
    required String endpoint,
    required String method,
    required String bodyJson,
    required DateTime createdAt,
    DateTime? nextRetryAt,
    String? lastError,
    int retryCount = 0,
  }) {
    return into(pendingWrites).insert(
      PendingWritesCompanion.insert(
        endpoint: endpoint,
        method: method,
        bodyJson: bodyJson,
        createdAt: createdAt.millisecondsSinceEpoch,
        retryCount: Value(retryCount),
        lastError: Value(lastError),
        nextRetryAt: Value(nextRetryAt?.millisecondsSinceEpoch),
      ),
    );
  }

  /// Returns every queued write ordered by `(nextRetryAt ASC NULLS FIRST,
  /// createdAt ASC)` — i.e. the earliest-eligible row first, with FIFO as
  /// the tiebreaker. Rows whose `nextRetryAt` is in the future are still
  /// returned; the caller filters by `now`.
  Future<List<PendingWrite>> getAllPendingWrites() {
    final query = select(pendingWrites)
      ..orderBy([
        (t) => OrderingTerm.asc(t.nextRetryAt),
        (t) => OrderingTerm.asc(t.createdAt),
      ]);
    return query.get();
  }

  /// Reads only the rows that are eligible to run *right now* — i.e. either
  /// they have never failed (`next_retry_at IS NULL`) or their backoff
  /// window has elapsed.
  Future<List<PendingWrite>> getDuePendingWrites(DateTime now) {
    final cutoff = now.millisecondsSinceEpoch;
    final query = select(pendingWrites)
      ..where(
        (t) =>
            t.nextRetryAt.isNull() |
            t.nextRetryAt.isSmallerOrEqualValue(cutoff),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query.get();
  }

  /// Lightweight count used by [pendingWriteCountStreamProvider] to drive
  /// the [SyncStatusBanner].
  Stream<int> watchPendingWriteCount() {
    final query = selectOnly(pendingWrites)
      ..addColumns([pendingWrites.id.count()]);
    return query
        .map((row) => row.read(pendingWrites.id.count()) ?? 0)
        .watchSingle();
  }

  /// Bumps the retry counter and writes the next backoff watermark.
  Future<int> bumpRetry({
    required int id,
    required int newRetryCount,
    required DateTime nextRetryAt,
    String? error,
  }) {
    return (update(pendingWrites)..where((t) => t.id.equals(id))).write(
      PendingWritesCompanion(
        retryCount: Value(newRetryCount),
        nextRetryAt: Value(nextRetryAt.millisecondsSinceEpoch),
        lastError: Value(error),
      ),
    );
  }

  /// Removes a row that has either succeeded or exhausted its retry budget.
  Future<int> deletePendingWrite(int id) {
    return (delete(pendingWrites)..where((t) => t.id.equals(id))).go();
  }

  /// Test/diagnostic helper.
  Future<int> deleteAllPendingWrites() => delete(pendingWrites).go();

  // ── Cached products queries ───────────────────────────────────────────

  /// Upserts the product payload for [ean] with `fetchedAt = now`.
  Future<void> cacheProduct({
    required String ean,
    required String payloadJson,
    required DateTime fetchedAt,
  }) {
    return into(cachedProducts).insertOnConflictUpdate(
      CachedProductsCompanion.insert(
        ean: ean,
        payloadJson: payloadJson,
        fetchedAt: fetchedAt.millisecondsSinceEpoch,
      ),
    );
  }

  /// Returns the cached row for [ean] if any.
  Future<CachedProduct?> getCachedProduct(String ean) {
    return (select(
      cachedProducts,
    )..where((t) => t.ean.equals(ean))).getSingleOrNull();
  }

  /// Drops cached rows whose `fetched_at` predates [cutoff].
  Future<int> evictCachedProductsBefore(DateTime cutoff) {
    return (delete(cachedProducts)..where(
          (t) => t.fetchedAt.isSmallerThanValue(cutoff.millisecondsSinceEpoch),
        ))
        .go();
  }
}

/// Production database opener. Delegates to `drift_flutter`'s cross-platform
/// `driftDatabase` helper which uses:
///   * native SQLite via `dart:ffi` on Android / iOS / desktop,
///   * a WASM build of sqlite3 via `package:drift/wasm.dart` on the web.
///
/// This indirection keeps `dart:ffi` and `dart:io` out of the web bundle —
/// `drift_flutter` switches implementations at compile time using the
/// standard `dart.library.*` conditional-import mechanism.
QueryExecutor _openConnection() {
  return driftDatabase(name: 'radha');
}

// ─── Riverpod handles ───────────────────────────────────────────────────────

/// Provides the singleton [RadhaDatabase] for the running app. Tests can
/// override this with `RadhaDatabase.forTesting(NativeDatabase.memory())`.
final radhaDatabaseProvider = Provider<RadhaDatabase>((ref) {
  final db = RadhaDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Streams the live count of pending writes from Drift. Watched by the
/// [SyncStatusBanner] so the UI updates the moment a row is enqueued or
/// drained.
final pendingWriteCountStreamProvider = StreamProvider<int>((ref) {
  final db = ref.watch(radhaDatabaseProvider);
  return db.watchPendingWriteCount();
});

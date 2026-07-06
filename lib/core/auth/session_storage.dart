import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../network/token_provider.dart';
import 'auth_session.dart';

/// Wraps [FlutterSecureStorage] with the seven keys the auth task spec calls
/// out. All reads/writes are async and go through the platform's hardware-
/// backed keystore (Android EncryptedSharedPreferences, iOS Keychain).
class SessionStorage {
  SessionStorage({FlutterSecureStorage? secureStorage, Uuid? uuid})
    : _storage =
          secureStorage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          ),
      _uuid = uuid ?? const Uuid();

  final FlutterSecureStorage _storage;
  final Uuid _uuid;

  // Storage keys — the seven from the task spec.
  static const String kAccessToken = 'access_token';
  static const String kRefreshToken = 'refresh_token';
  static const String kUserId = 'user_id';
  static const String kTenantId = 'tenant_id';
  static const String kRolesJson = 'roles_json';
  static const String kSelectedStoreId = 'selected_store_id';
  static const String kDeviceId = 'device_id';

  // Extra (not in the seven, but needed to round-trip an [AuthSession]).
  static const String kStoresJson = 'stores_json';

  // Onboarding flag — read by the router to gate `/onboarding`.
  static const String kOnboardingComplete = 'onboarding_complete';

  // Pending onboarding segment captured during the pre-auth onboarding flow
  // (Task 6). The user picks one of six segments before they sign in, but
  // the backend's `POST /onboarding/segment` endpoint requires JWT auth. We
  // park the wire value here and Task 7 reads it after the OTP login
  // succeeds, posts it, then clears this key.
  static const String kPendingOnboardingSegment = 'pending_onboarding_segment';

  // ─── readers ────────────────────────────────────────────────────────────

  Future<String?> readAccessToken() => _storage.read(key: kAccessToken);
  Future<String?> readRefreshToken() => _storage.read(key: kRefreshToken);
  Future<String?> readUserId() => _storage.read(key: kUserId);
  Future<String?> readTenantId() => _storage.read(key: kTenantId);
  Future<String?> readSelectedStoreId() => _storage.read(key: kSelectedStoreId);

  Future<List<String>> readRoles() async {
    final raw = await _storage.read(key: kRolesJson);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded.cast<String>();
  }

  Future<List<StoreAccess>> readStores() async {
    final raw = await _storage.read(key: kStoresJson);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .cast<Map<String, dynamic>>()
        .map(StoreAccess.fromJson)
        .toList(growable: false);
  }

  /// Returns the device id, generating a UUIDv4 the first time it's read and
  /// persisting it for subsequent calls. The id is stable across app launches
  /// but rotates if the user clears storage or reinstalls.
  Future<String> getOrCreateDeviceId() async {
    final existing = await _storage.read(key: kDeviceId);
    if (existing != null && existing.isNotEmpty) return existing;
    final fresh = _uuid.v4();
    await _storage.write(key: kDeviceId, value: fresh);
    return fresh;
  }

  Future<String?> readDeviceId() => _storage.read(key: kDeviceId);

  /// Reads whether the user has completed onboarding. Persisted as `'true'`
  /// after the user finishes the onboarding flow (Task 6); the router uses
  /// this to gate redirects to `/onboarding`.
  Future<bool> readOnboardingComplete() async {
    final raw = await _storage.read(key: kOnboardingComplete);
    return raw == 'true';
  }

  /// Marks onboarding as done (or resets it). Called from the onboarding
  /// flow's "Get started" CTA.
  Future<void> setOnboardingComplete(bool value) async {
    if (value) {
      await _storage.write(key: kOnboardingComplete, value: 'true');
    } else {
      await _storage.delete(key: kOnboardingComplete);
    }
  }

  /// Reads the segment the user picked on the onboarding screen but hasn't
  /// yet posted to the backend (because they weren't logged in at the time).
  /// Returns the snake_case wire value, e.g. `'business_owner'`. Returns
  /// `null` if no pending segment is stored.
  Future<String?> readPendingOnboardingSegment() =>
      _storage.read(key: kPendingOnboardingSegment);

  /// Persists the pending onboarding segment wire value. Pass `null` to
  /// clear it (Task 7 calls this after `POST /onboarding/segment` succeeds).
  Future<void> setPendingOnboardingSegment(String? value) async {
    if (value == null || value.isEmpty) {
      await _storage.delete(key: kPendingOnboardingSegment);
    } else {
      await _storage.write(key: kPendingOnboardingSegment, value: value);
    }
  }

  // ─── writers ────────────────────────────────────────────────────────────

  /// Persists every field of [session] to its dedicated key. Roles and stores
  /// are JSON-encoded so we don't have to invent a delimiter. `tenantId` is
  /// nullable for users who have authenticated but haven't joined a tenant
  /// yet (consumer onboarding path or pending invite).
  Future<void> writeSession(AuthSession session) async {
    await Future.wait<void>([
      _storage.write(key: kAccessToken, value: session.accessToken),
      _storage.write(key: kRefreshToken, value: session.refreshToken),
      _storage.write(key: kUserId, value: session.userId),
      if (session.tenantId != null)
        _storage.write(key: kTenantId, value: session.tenantId)
      else
        _storage.delete(key: kTenantId),
      _storage.write(key: kRolesJson, value: jsonEncode(session.roles)),
      _storage.write(
        key: kStoresJson,
        value: jsonEncode(session.stores.map((s) => s.toJson()).toList()),
      ),
      if (session.selectedStoreId != null)
        _storage.write(key: kSelectedStoreId, value: session.selectedStoreId)
      else
        _storage.delete(key: kSelectedStoreId),
    ]);
  }

  /// Updates only the access + refresh tokens. Used by `AuthRepository.refresh`
  /// so we don't rewrite the entire session payload on every rotation.
  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait<void>([
      _storage.write(key: kAccessToken, value: accessToken),
      _storage.write(key: kRefreshToken, value: refreshToken),
    ]);
  }

  /// Persists the user's chosen store. Pass `null` to clear it (e.g. on
  /// store-switcher reset).
  Future<void> selectStore(String? storeId) async {
    if (storeId == null || storeId.isEmpty) {
      await _storage.delete(key: kSelectedStoreId);
    } else {
      await _storage.write(key: kSelectedStoreId, value: storeId);
    }
  }

  /// Reconstructs the [AuthSession] from secure storage. Returns `null` when
  /// any required field is missing — i.e. there is no usable session.
  /// `tenantId` is intentionally not part of the required-set; consumer-only
  /// users authenticate without a tenant.
  Future<AuthSession?> readSession() async {
    final access = await readAccessToken();
    final refresh = await readRefreshToken();
    final userId = await readUserId();
    final tenantId = await readTenantId();
    if (access == null || refresh == null || userId == null) {
      return null;
    }
    final roles = await readRoles();
    final stores = await readStores();
    final selectedStoreId = await readSelectedStoreId();
    return AuthSession(
      accessToken: access,
      refreshToken: refresh,
      userId: userId,
      tenantId: tenantId,
      roles: roles,
      stores: stores,
      selectedStoreId: selectedStoreId,
    );
  }

  /// Wipes every key this class owns. The `device_id` is **preserved** so
  /// re-login on the same install registers as the same device — matches the
  /// backend's `users.device_id` audit trail expectation. The
  /// `pending_onboarding_segment` is also preserved: it's set during the
  /// pre-auth onboarding flow and read by Task 7 *after* the user's first
  /// successful login, so wiping it on logout would lose that signal.
  Future<void> clear() async {
    await Future.wait<void>([
      _storage.delete(key: kAccessToken),
      _storage.delete(key: kRefreshToken),
      _storage.delete(key: kUserId),
      _storage.delete(key: kTenantId),
      _storage.delete(key: kRolesJson),
      _storage.delete(key: kStoresJson),
      _storage.delete(key: kSelectedStoreId),
      // device_id intentionally retained.
      // pending_onboarding_segment intentionally retained — Task 7 owns it.
    ]);
  }
}

/// Riverpod handle for the global [SessionStorage]. Override in tests with
/// an in-memory fake.
final sessionStorageProvider = Provider<SessionStorage>((ref) {
  return SessionStorage();
});

/// Adapter that exposes [SessionStorage] as the [TokenStore] the networking
/// layer (Task 2) consumes. Wire this in `main.dart` like:
///
/// ```dart
/// ProviderScope(
///   overrides: [
///     tokenStoreProvider.overrideWith((ref) => ref.watch(sessionStorageTokenStoreProvider)),
///   ],
///   child: const RadhaApp(),
/// )
/// ```
final sessionStorageTokenStoreProvider = Provider<TokenStore>((ref) {
  return _SessionStorageTokenStore(ref.watch(sessionStorageProvider));
});

class _SessionStorageTokenStore implements TokenStore {
  _SessionStorageTokenStore(this._storage);

  final SessionStorage _storage;

  @override
  Future<String?> readAccessToken() => _storage.readAccessToken();

  @override
  Future<String?> readRefreshToken() => _storage.readRefreshToken();

  @override
  Future<void> persistTokens({
    required String access,
    required String refresh,
  }) => _storage.updateTokens(accessToken: access, refreshToken: refresh);

  @override
  Future<void> clear() => _storage.clear();
}

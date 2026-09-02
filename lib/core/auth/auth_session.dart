import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_session.freezed.dart';
part 'auth_session.g.dart';

/// In-memory representation of the authenticated user's session. Persisted
/// piece-by-piece to `flutter_secure_storage` by [SessionStorage]; rehydrated
/// on cold start via `AuthRepository.currentSession()`.
@freezed
class AuthSession with _$AuthSession {
  const factory AuthSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    String? tenantId,
    required List<String> roles,
    required List<StoreAccess> stores,
    String? selectedStoreId,
    // The auth session previously only carried `userId` (a UUID), so the
    // Profile screen and Home greeting had nothing better to display and
    // fell back to showing the raw UUID — which reads as a broken/demo
    // placeholder rather than "you're signed in as yourself". `/auth/me`
    // has always returned `mobile` + `name`; these were just never
    // threaded through into the persisted session. Both nullable since
    // `name` is often unset and older stored sessions won't have them.
    String? mobile,
    String? name,
    // Phase 13 (Google Sign-In): set for Google-linked accounts, null for
    // legacy phone-only OTP accounts. Threaded through so the Profile
    // screen can show it instead of the raw user-id UUID.
    String? email,
  }) = _AuthSession;

  factory AuthSession.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionFromJson(json);
}

/// One row from `/auth/me`'s `storeAccess[]`. Carries the role the user holds
/// at that specific store — a user may be `manager` at one store and `staff`
/// at another within the same tenant.
@freezed
class StoreAccess with _$StoreAccess {
  const factory StoreAccess({
    required String storeId,
    required String storeName,
    required String role,
  }) = _StoreAccess;

  factory StoreAccess.fromJson(Map<String, dynamic> json) =>
      _$StoreAccessFromJson(json);
}

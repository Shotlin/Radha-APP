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

import 'package:json_annotation/json_annotation.dart';

part 'auth_dto.g.dart';

// ─── Request DTOs ─────────────────────────────────────────────────────────

@JsonSerializable(createFactory: false)
class OtpRequestRequestDto {
  const OtpRequestRequestDto({required this.mobile});
  final String mobile;

  Map<String, dynamic> toJson() => _$OtpRequestRequestDtoToJson(this);
}

@JsonSerializable(createFactory: false)
class VerifyOtpRequestDto {
  const VerifyOtpRequestDto({
    required this.mobile,
    required this.otp,
    required this.requestId,
  });

  final String mobile;
  final String otp;
  final String requestId;

  Map<String, dynamic> toJson() => _$VerifyOtpRequestDtoToJson(this);
}

@JsonSerializable(createFactory: false)
class AdminLoginRequestDto {
  const AdminLoginRequestDto({required this.email, required this.password});
  final String email;
  final String password;

  Map<String, dynamic> toJson() => _$AdminLoginRequestDtoToJson(this);
}

@JsonSerializable(createFactory: false)
class RefreshTokenRequestDto {
  const RefreshTokenRequestDto({required this.refreshToken});
  final String refreshToken;

  Map<String, dynamic> toJson() => _$RefreshTokenRequestDtoToJson(this);
}

// ─── Response DTOs ────────────────────────────────────────────────────────

@JsonSerializable(createToJson: false)
class OtpRequestResponse {
  const OtpRequestResponse({
    required this.requestId,
    required this.expiresIn,
    this.rateLimitRemaining,
    this.devOtp,
  });

  final String requestId;
  final int expiresIn;
  final int? rateLimitRemaining;

  /// Dev/test only — the plaintext OTP echoed back by a development server so
  /// the app can show/fill it without tailing server logs. The backend strips
  /// this in staging/production (`AuthService.requestOtp` is strictly gated),
  /// so it is `null` in any real environment.
  final String? devOtp;

  factory OtpRequestResponse.fromJson(Map<String, dynamic> json) =>
      _$OtpRequestResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class LoginResponse {
  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final UserSummary user;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class MeResponse {
  const MeResponse({
    required this.user,
    required this.roles,
    required this.storeAccess,
  });

  final UserSummary user;
  final List<String> roles;
  final List<StoreAccessDto> storeAccess;

  /// Accepts BOTH shapes the server may return for `/auth/me`:
  ///
  /// NESTED (richer) shape:
  ///   { "user": { id, tenantId, ... }, "roles": [...],
  ///     "storeAccess": [ { storeId, storeName, role } ] }
  ///
  /// FLAT `UserMeResponse` shape:
  ///   { id, mobile, name, role, tenantId, storeIds, permissions,
  ///     isVerified, bypassOnboarding, createdAt }
  /// — there is no `user` wrapper, `role` is a single string, and the
  /// store access is just a list of ids (`storeIds`). We adapt either
  /// shape to the client's richer model here so the repository/session
  /// layer stays unchanged.
  factory MeResponse.fromJson(Map<String, dynamic> json) {
    final nestedUser = json['user'];
    if (nestedUser is Map<String, dynamic>) {
      return MeResponse(
        user: UserSummary.fromJson(nestedUser),
        roles: (json['roles'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<String>()
            .toList(growable: false),
        storeAccess: (json['storeAccess'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(StoreAccessDto.fromJson)
            .toList(growable: false),
      );
    }

    final role = json['role'] as String?;
    final storeIds = (json['storeIds'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<String>()
        .toList(growable: false);
    return MeResponse(
      user: UserSummary.fromJson(json),
      roles: (role == null || role.isEmpty) ? const <String>[] : <String>[role],
      storeAccess: storeIds
          .map(
            (id) => StoreAccessDto(storeId: id, storeName: id, role: role ?? ''),
          )
          .toList(growable: false),
    );
  }
}

@JsonSerializable()
class UserSummary {
  const UserSummary({
    required this.id,
    this.tenantId,
    this.mobile,
    this.email,
    this.name,
    this.role,
    this.isVerified,
    this.bypassOnboarding,
  });

  final String id;
  final String? tenantId;
  final String? mobile;
  final String? email;
  final String? name;
  final String? role;
  final bool? isVerified;
  final bool? bypassOnboarding;

  /// Convenience for older callsites that read `displayName`.
  String? get displayName => name;

  factory UserSummary.fromJson(Map<String, dynamic> json) =>
      _$UserSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$UserSummaryToJson(this);
}

@JsonSerializable()
class StoreAccessDto {
  const StoreAccessDto({
    required this.storeId,
    required this.storeName,
    required this.role,
  });

  final String storeId;
  final String storeName;
  final String role;

  factory StoreAccessDto.fromJson(Map<String, dynamic> json) =>
      _$StoreAccessDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StoreAccessDtoToJson(this);
}

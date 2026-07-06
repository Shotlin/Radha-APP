// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$OtpRequestRequestDtoToJson(
  OtpRequestRequestDto instance,
) => <String, dynamic>{'mobile': instance.mobile};

Map<String, dynamic> _$VerifyOtpRequestDtoToJson(
  VerifyOtpRequestDto instance,
) => <String, dynamic>{
  'mobile': instance.mobile,
  'otp': instance.otp,
  'requestId': instance.requestId,
};

Map<String, dynamic> _$AdminLoginRequestDtoToJson(
  AdminLoginRequestDto instance,
) => <String, dynamic>{'email': instance.email, 'password': instance.password};

Map<String, dynamic> _$RefreshTokenRequestDtoToJson(
  RefreshTokenRequestDto instance,
) => <String, dynamic>{'refreshToken': instance.refreshToken};

OtpRequestResponse _$OtpRequestResponseFromJson(Map<String, dynamic> json) =>
    OtpRequestResponse(
      requestId: json['requestId'] as String,
      expiresIn: (json['expiresIn'] as num).toInt(),
      rateLimitRemaining: (json['rateLimitRemaining'] as num?)?.toInt(),
      devOtp: json['devOtp'] as String?,
    );

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: UserSummary.fromJson(json['user'] as Map<String, dynamic>),
    );

MeResponse _$MeResponseFromJson(Map<String, dynamic> json) => MeResponse(
  user: UserSummary.fromJson(json['user'] as Map<String, dynamic>),
  roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
  storeAccess: (json['storeAccess'] as List<dynamic>)
      .map((e) => StoreAccessDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

UserSummary _$UserSummaryFromJson(Map<String, dynamic> json) => UserSummary(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String?,
  mobile: json['mobile'] as String?,
  email: json['email'] as String?,
  name: json['name'] as String?,
  role: json['role'] as String?,
  isVerified: json['isVerified'] as bool?,
  bypassOnboarding: json['bypassOnboarding'] as bool?,
);

Map<String, dynamic> _$UserSummaryToJson(UserSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'mobile': instance.mobile,
      'email': instance.email,
      'name': instance.name,
      'role': instance.role,
      'isVerified': instance.isVerified,
      'bypassOnboarding': instance.bypassOnboarding,
    };

StoreAccessDto _$StoreAccessDtoFromJson(Map<String, dynamic> json) =>
    StoreAccessDto(
      storeId: json['storeId'] as String,
      storeName: json['storeName'] as String,
      role: json['role'] as String,
    );

Map<String, dynamic> _$StoreAccessDtoToJson(StoreAccessDto instance) =>
    <String, dynamic>{
      'storeId': instance.storeId,
      'storeName': instance.storeName,
      'role': instance.role,
    };

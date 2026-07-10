// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterFcmTokenDto _$RegisterFcmTokenDtoFromJson(Map<String, dynamic> json) =>
    RegisterFcmTokenDto(
      token: json['token'] as String,
      platform: json['platform'] as String,
    );

Map<String, dynamic> _$RegisterFcmTokenDtoToJson(
  RegisterFcmTokenDto instance,
) => <String, dynamic>{'token': instance.token, 'platform': instance.platform};

UnregisterFcmTokenDto _$UnregisterFcmTokenDtoFromJson(
  Map<String, dynamic> json,
) => UnregisterFcmTokenDto(token: json['token'] as String);

Map<String, dynamic> _$UnregisterFcmTokenDtoToJson(
  UnregisterFcmTokenDto instance,
) => <String, dynamic>{'token': instance.token};

import 'package:json_annotation/json_annotation.dart';

part 'notification_dto.g.dart';

@JsonSerializable()
class RegisterFcmTokenDto {
  const RegisterFcmTokenDto({required this.token, required this.platform});

  final String token;
  final String platform; // 'android' | 'ios'

  Map<String, dynamic> toJson() => _$RegisterFcmTokenDtoToJson(this);
}

@JsonSerializable()
class UnregisterFcmTokenDto {
  const UnregisterFcmTokenDto({required this.token});

  final String token;

  Map<String, dynamic> toJson() => _$UnregisterFcmTokenDtoToJson(this);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionPlanInfo _$SubscriptionPlanInfoFromJson(
  Map<String, dynamic> json,
) => SubscriptionPlanInfo(
  code: json['code'] as String,
  name: json['name'] as String,
);

SubscriptionResponse _$SubscriptionResponseFromJson(
  Map<String, dynamic> json,
) => SubscriptionResponse(
  isActive: json['isActive'] as bool,
  status: json['status'] as String,
  plan: SubscriptionPlanInfo.fromJson(json['plan'] as Map<String, dynamic>),
  trialDaysRemaining: (json['trialDaysRemaining'] as num?)?.toInt(),
);

Map<String, dynamic> _$CreateSubscriptionDtoToJson(
  CreateSubscriptionDto instance,
) => <String, dynamic>{'plan': instance.plan};

SubscriptionPlanCatalogEntry _$SubscriptionPlanCatalogEntryFromJson(
  Map<String, dynamic> json,
) => SubscriptionPlanCatalogEntry(
  id: json['id'] as String,
  code: json['code'] as String,
);

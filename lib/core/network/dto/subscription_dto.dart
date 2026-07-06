import 'package:json_annotation/json_annotation.dart';

part 'subscription_dto.g.dart';

/// Plan info nested inside [SubscriptionResponse].
@JsonSerializable(createToJson: false)
class SubscriptionPlanInfo {
  const SubscriptionPlanInfo({required this.code, required this.name});

  final String code;
  final String name;

  factory SubscriptionPlanInfo.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPlanInfoFromJson(json);
}

/// Subscription status returned by `GET /api/v1/subscriptions/status`.
@JsonSerializable(createToJson: false)
class SubscriptionResponse {
  const SubscriptionResponse({
    required this.isActive,
    required this.status,
    required this.plan,
    this.trialDaysRemaining,
  });

  final bool isActive;
  final String status;
  final SubscriptionPlanInfo plan;
  final int? trialDaysRemaining;

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionResponseFromJson(json);
}

@JsonSerializable(createFactory: false)
class CreateSubscriptionDto {
  const CreateSubscriptionDto({required this.plan});
  final String plan;

  Map<String, dynamic> toJson() => _$CreateSubscriptionDtoToJson(this);
}

/// One entry from `GET /api/v1/subscriptions/plans` (public, no auth).
///
/// The checkout DTO (`CreateCheckoutDto.planId`) must be the backend's real
/// plan UUID, not the plan *code* (`'starter'`/`'growth'`/`'pro'`) the
/// mobile app's local `kRadhaPlans` catalogue uses as its id. This entry is
/// the only source of that UUID — see `SubscriptionService.resolvePlanId`.
/// Only the two fields checkout needs are modelled; the backend response
/// carries pricing/entitlements too but the app has its own copy of those
/// for the pricing UI (`plan_model.dart`).
@JsonSerializable(createToJson: false)
class SubscriptionPlanCatalogEntry {
  const SubscriptionPlanCatalogEntry({required this.id, required this.code});

  final String id;
  final String code;

  factory SubscriptionPlanCatalogEntry.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPlanCatalogEntryFromJson(json);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'misc_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AllergenResponse _$AllergenResponseFromJson(Map<String, dynamic> json) =>
    AllergenResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      severity: json['severity'] as String?,
    );

RecallResponse _$RecallResponseFromJson(Map<String, dynamic> json) =>
    RecallResponse(
      id: json['id'] as String,
      productId: json['productId'] as String,
      reason: json['reason'] as String?,
      severity: json['severity'] as String?,
      productName: json['productName'] as String?,
      productEan: json['productEan'] as String?,
      recalledAt: json['recalledAt'] as String?,
    );

IngredientExplainerResponse _$IngredientExplainerResponseFromJson(
  Map<String, dynamic> json,
) => IngredientExplainerResponse(explanation: json['explanation'] as String);

HealthyAlternativesResponse _$HealthyAlternativesResponseFromJson(
  Map<String, dynamic> json,
) => HealthyAlternativesResponse(
  alternatives: (json['alternatives'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
);

Map<String, dynamic> _$CreateReferralDtoToJson(CreateReferralDto instance) =>
    <String, dynamic>{'code': instance.code};

ReferralResponse _$ReferralResponseFromJson(Map<String, dynamic> json) =>
    ReferralResponse(
      id: json['id'] as String,
      code: json['code'] as String,
      status: json['status'] as String?,
    );

ReferralStatsResponse _$ReferralStatsResponseFromJson(
  Map<String, dynamic> json,
) => ReferralStatsResponse(
  referralCode: json['code'] as String,
  inviteeCount: (json['totalReferrals'] as num).toInt(),
  rewardsEarned: json['rewardsEarned'] as num,
);

Map<String, dynamic> _$RedeemReferralDtoToJson(RedeemReferralDto instance) =>
    <String, dynamic>{'code': instance.code};

Map<String, dynamic> _$UpdateLanguageDtoToJson(UpdateLanguageDto instance) =>
    <String, dynamic>{'language': instance.language};

Map<String, dynamic> _$SyncPushDtoToJson(SyncPushDto instance) =>
    <String, dynamic>{'changes': instance.changes};

SyncPullResponse _$SyncPullResponseFromJson(Map<String, dynamic> json) =>
    SyncPullResponse(
      changes: (json['changes'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      serverTimestamp: json['serverTimestamp'] as String?,
    );

OcrFallbackResponse _$OcrFallbackResponseFromJson(Map<String, dynamic> json) =>
    OcrFallbackResponse(
      text: json['text'] as String,
      confidence: (json['confidence'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ShoppingListItemDtoToJson(
  ShoppingListItemDto instance,
) => <String, dynamic>{
  'item': instance.item,
  if (instance.quantity case final value?) 'quantity': value,
};

Map<String, dynamic> _$UpdateShoppingListItemDtoToJson(
  UpdateShoppingListItemDto instance,
) => <String, dynamic>{
  if (instance.isPurchased case final value?) 'isPurchased': value,
  if (instance.quantity case final value?) 'quantity': value,
};

Map<String, dynamic> _$CreateShoppingListDtoToJson(
  CreateShoppingListDto instance,
) => <String, dynamic>{if (instance.name case final value?) 'name': value};

ShoppingListSummary _$ShoppingListSummaryFromJson(Map<String, dynamic> json) =>
    ShoppingListSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      archivedAt: json['archivedAt'] as String?,
    );

ShoppingListDetail _$ShoppingListDetailFromJson(Map<String, dynamic> json) =>
    ShoppingListDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      items: (json['items'] as List<dynamic>)
          .map(
            (e) => ShoppingListItemResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

ShoppingListItemResponse _$ShoppingListItemResponseFromJson(
  Map<String, dynamic> json,
) => ShoppingListItemResponse(
  id: json['id'] as String,
  name: json['item'] as String,
  checked: json['isPurchased'] as bool,
  quantity: _shoppingQtyFromJson(json['quantity']),
  createdAt: json['createdAt'] as String?,
);

PublicProductResponse _$PublicProductResponseFromJson(
  Map<String, dynamic> json,
) => PublicProductResponse(
  id: json['id'] as String,
  name: json['name'] as String,
  ean: json['ean'] as String?,
);

WeeklyDigestTopCategory _$WeeklyDigestTopCategoryFromJson(
  Map<String, dynamic> json,
) => WeeklyDigestTopCategory(
  category: json['category'] as String,
  count: (json['count'] as num).toInt(),
);

WeeklyDigestResponse _$WeeklyDigestResponseFromJson(
  Map<String, dynamic> json,
) => WeeklyDigestResponse(
  weekIso: json['weekIso'] as String?,
  weekStartDate: json['weekStartDate'] as String?,
  weekEndDate: json['weekEndDate'] as String?,
  scansCount: (json['scansCount'] as num?)?.toInt() ?? 0,
  savedProductsCount: (json['savedProductsCount'] as num?)?.toInt() ?? 0,
  expiringSoonCount: (json['expiringSoonCount'] as num?)?.toInt() ?? 0,
  recallAlertsCount: (json['recallAlertsCount'] as num?)?.toInt() ?? 0,
  estimatedSavingsInr: json['estimatedSavingsInr'] as num? ?? 0,
  topCategories:
      (json['topCategories'] as List<dynamic>?)
          ?.map(
            (e) => WeeklyDigestTopCategory.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const <WeeklyDigestTopCategory>[],
  healthHighlights:
      (json['healthHighlights'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  summary: json['summary'] as String?,
  highlights: (json['highlights'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

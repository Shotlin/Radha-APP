import 'package:json_annotation/json_annotation.dart';

part 'misc_dto.g.dart';

// ─── Allergen ─────────────────────────────────────────────────────────────

@JsonSerializable(createToJson: false)
class AllergenResponse {
  const AllergenResponse({required this.id, required this.name, this.severity});

  final String id;
  final String name;
  final String? severity;

  factory AllergenResponse.fromJson(Map<String, dynamic> json) =>
      _$AllergenResponseFromJson(json);
}

// ─── Recall ───────────────────────────────────────────────────────────────

@JsonSerializable(createToJson: false)
class RecallResponse {
  const RecallResponse({
    required this.id,
    required this.productId,
    this.reason,
    this.severity,
    this.productName,
    this.productEan,
    this.recalledAt,
  });

  final String id;
  final String productId;
  final String? reason;

  /// Severity bucket — `critical`, `high`, `medium`, `low`. Lower-cased
  /// canonical strings; the UI maps these to badges.
  final String? severity;

  /// Display name of the recalled product, populated when the backend joins
  /// the product table for a list view.
  final String? productName;

  /// EAN of the recalled product, used to deep-link into product detail.
  final String? productEan;

  /// ISO-8601 date string the recall was issued / observed.
  final String? recalledAt;

  factory RecallResponse.fromJson(Map<String, dynamic> json) =>
      _$RecallResponseFromJson(json);
}

// ─── Ingredient Explainer ─────────────────────────────────────────────────

@JsonSerializable(createToJson: false)
class IngredientExplainerResponse {
  const IngredientExplainerResponse({required this.explanation});

  final String explanation;

  factory IngredientExplainerResponse.fromJson(Map<String, dynamic> json) =>
      _$IngredientExplainerResponseFromJson(json);
}

// ─── Healthy Alternatives ─────────────────────────────────────────────────

@JsonSerializable(createToJson: false)
class HealthyAlternativesResponse {
  const HealthyAlternativesResponse({required this.alternatives});

  final List<Map<String, dynamic>> alternatives;

  factory HealthyAlternativesResponse.fromJson(Map<String, dynamic> json) =>
      _$HealthyAlternativesResponseFromJson(json);
}

// ─── Referrals ────────────────────────────────────────────────────────────

@JsonSerializable(createFactory: false)
class CreateReferralDto {
  const CreateReferralDto({required this.code});
  final String code;

  Map<String, dynamic> toJson() => _$CreateReferralDtoToJson(this);
}

@JsonSerializable(createToJson: false)
class ReferralResponse {
  const ReferralResponse({required this.id, required this.code, this.status});

  final String id;
  final String code;
  final String? status;

  factory ReferralResponse.fromJson(Map<String, dynamic> json) =>
      _$ReferralResponseFromJson(json);
}

/// Aggregate stats for the signed-in user's referral programme. Surfaced by
/// `GET /api/v1/referrals/me` (BE-43): the user's stable referral code,
/// number of accepted invitees, and rewards already earned in rupees.
@JsonSerializable(createToJson: false)
class ReferralStatsResponse {
  const ReferralStatsResponse({
    required this.referralCode,
    required this.inviteeCount,
    required this.rewardsEarned,
  });

  /// Stable, monospace-friendly code the user shares with prospects.
  /// Backend field is `code` (BE-43 response shape), not `referralCode`.
  @JsonKey(name: 'code')
  final String referralCode;

  /// Number of invitees who completed redemption.
  /// Backend field is `totalReferrals`, not `inviteeCount`.
  @JsonKey(name: 'totalReferrals')
  final int inviteeCount;

  /// Total rewards earned by the user, in INR (₹).
  final num rewardsEarned;

  /// Hand-written, shape-tolerant parser. The backend's `GET /referrals/me`
  /// returns `{ code, totalReferrals, rewardsEarned, recentRewards }`, while
  /// older/aggregate shapes used `{ referralCode, inviteeCount, rewardsEarned }`.
  /// We accept either so a contract drift never dead-ends the screen.
  factory ReferralStatsResponse.fromJson(Map<String, dynamic> json) {
    final code = (json['referralCode'] ?? json['code'] ?? '') as String;
    final invitees =
        (json['inviteeCount'] ?? json['totalReferrals'] ?? 0) as num;
    final rewards = (json['rewardsEarned'] ?? 0) as num;
    return ReferralStatsResponse(
      referralCode: code,
      inviteeCount: invitees.toInt(),
      rewardsEarned: rewards,
    );
  }
}

/// Body for `POST /api/v1/referrals/redeem` — the redeeming user supplies
/// the referrer's code.
@JsonSerializable(createFactory: false)
class RedeemReferralDto {
  const RedeemReferralDto({required this.code});
  final String code;

  Map<String, dynamic> toJson() => _$RedeemReferralDtoToJson(this);
}

/// Body for `PUT /api/v1/user/language` (BE-42). One of `en`, `hi`, `ta`,
/// `te`, `bn`, `mr` — the BCP-47 language subtag.
@JsonSerializable(createFactory: false)
class UpdateLanguageDto {
  const UpdateLanguageDto({required this.language});
  final String language;

  Map<String, dynamic> toJson() => _$UpdateLanguageDtoToJson(this);
}

// ─── Sync ─────────────────────────────────────────────────────────────────

@JsonSerializable(createFactory: false)
class SyncPushDto {
  const SyncPushDto({required this.changes});
  final List<Map<String, dynamic>> changes;

  Map<String, dynamic> toJson() => _$SyncPushDtoToJson(this);
}

@JsonSerializable(createToJson: false)
class SyncPullResponse {
  const SyncPullResponse({required this.changes, this.serverTimestamp});

  final List<Map<String, dynamic>> changes;
  final String? serverTimestamp;

  factory SyncPullResponse.fromJson(Map<String, dynamic> json) =>
      _$SyncPullResponseFromJson(json);
}

// ─── OCR Fallback ─────────────────────────────────────────────────────────

@JsonSerializable(createToJson: false)
class OcrFallbackResponse {
  const OcrFallbackResponse({required this.text, this.confidence});

  final String text;
  final double? confidence;

  factory OcrFallbackResponse.fromJson(Map<String, dynamic> json) =>
      _$OcrFallbackResponseFromJson(json);
}

// ─── Family Sharing (BE-36) ───────────────────────────────────────────────
//
// Hand-written (not @JsonSerializable): backend rows are tolerant of a
// missing display name, falling back to the mobile number then a generic
// label — codegen would only do a straight field copy, not this chain.
class FamilyMemberDto {
  const FamilyMemberDto({
    required this.id,
    required this.mobile,
    required this.name,
    required this.status,
    required this.role,
  });

  final String id;
  final String mobile;
  final String name;
  final String status;
  final String role;

  factory FamilyMemberDto.fromJson(Map<String, dynamic> json) {
    return FamilyMemberDto(
      id: json['id']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      name: json['name']?.toString() ?? json['mobile']?.toString() ?? 'Member',
      status: json['status']?.toString() ?? 'pending',
      role: json['role']?.toString() ?? 'member',
    );
  }
}

// ─── Shopping List ────────────────────────────────────────────────────────

/// Request DTO for `POST /api/v1/shopping-lists/:listId/items`.
/// Backend field name is `item` (not `name`); quantity is a free-form string.
@JsonSerializable(createFactory: false, includeIfNull: false)
class ShoppingListItemDto {
  const ShoppingListItemDto({required this.item, this.quantity});

  final String item;
  final String? quantity;

  Map<String, dynamic> toJson() => _$ShoppingListItemDtoToJson(this);
}

/// Request DTO for `PATCH /api/v1/shopping-lists/:listId/items/:itemId`.
/// Backend uses `isPurchased` (not `checked`); quantity is a free-form string.
@JsonSerializable(createFactory: false, includeIfNull: false)
class UpdateShoppingListItemDto {
  const UpdateShoppingListItemDto({this.isPurchased, this.quantity});

  final bool? isPurchased;
  final String? quantity;

  Map<String, dynamic> toJson() => _$UpdateShoppingListItemDtoToJson(this);
}

/// Request DTO for `POST /api/v1/shopping-lists` (create a new list).
@JsonSerializable(createFactory: false, includeIfNull: false)
class CreateShoppingListDto {
  const CreateShoppingListDto({this.name});
  final String? name;
  Map<String, dynamic> toJson() => _$CreateShoppingListDtoToJson(this);
}

/// Summary row returned by `GET /api/v1/shopping-lists` (no items).
@JsonSerializable(createToJson: false)
class ShoppingListSummary {
  const ShoppingListSummary({required this.id, required this.name, this.archivedAt});
  final String id;
  final String name;
  final String? archivedAt;
  factory ShoppingListSummary.fromJson(Map<String, dynamic> json) =>
      _$ShoppingListSummaryFromJson(json);
}

/// Detail row returned by `GET /api/v1/shopping-lists/:id` (includes items).
@JsonSerializable(createToJson: false)
class ShoppingListDetail {
  const ShoppingListDetail({required this.id, required this.name, required this.items});
  final String id;
  final String name;
  final List<ShoppingListItemResponse> items;
  factory ShoppingListDetail.fromJson(Map<String, dynamic> json) =>
      _$ShoppingListDetailFromJson(json);
}

/// Single shopping list item row returned by the backend.
/// Backend sends `item` for the name and `isPurchased` for the checked state;
/// both are remapped via @JsonKey so the rest of the app keeps `.name`/`.checked`.
@JsonSerializable(createToJson: false)
class ShoppingListItemResponse {
  const ShoppingListItemResponse({
    required this.id,
    required this.name,
    required this.checked,
    this.quantity,
    this.createdAt,
  });

  final String id;
  @JsonKey(name: 'item')
  final String name;
  @JsonKey(name: 'isPurchased')
  final bool checked;
  @JsonKey(fromJson: _shoppingQtyFromJson)
  final int? quantity;
  final String? createdAt;

  factory ShoppingListItemResponse.fromJson(Map<String, dynamic> json) =>
      _$ShoppingListItemResponseFromJson(json);
}

int? _shoppingQtyFromJson(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

/// View-model assembled by [shoppingListProvider] from the multi-list API.
/// Not deserialized directly — constructed manually by the provider.
class ShoppingListResponse {
  const ShoppingListResponse({required this.listId, required this.items});
  final String listId;
  final List<ShoppingListItemResponse> items;
}

// ─── Public Product ───────────────────────────────────────────────────────

@JsonSerializable(createToJson: false)
class PublicProductResponse {
  const PublicProductResponse({required this.id, required this.name, this.ean});

  final String id;
  final String name;
  final String? ean;

  factory PublicProductResponse.fromJson(Map<String, dynamic> json) =>
      _$PublicProductResponseFromJson(json);
}

// ─── Weekly Digest ────────────────────────────────────────────────────────

/// Single row in the "What you're scanning" bar chart on the digest screen.
///
/// `category` is a short human-readable label (e.g. "Snacks", "Beverages").
/// `count` is the number of scans the user made in that category for the
/// reported week.
@JsonSerializable(createToJson: false)
class WeeklyDigestTopCategory {
  const WeeklyDigestTopCategory({
    required this.category,
    required this.count,
  });

  final String category;
  final int count;

  factory WeeklyDigestTopCategory.fromJson(Map<String, dynamic> json) =>
      _$WeeklyDigestTopCategoryFromJson(json);
}

/// Response for `GET /api/v1/weekly-digest` (BE-24).
///
/// Drives the FE-24 "Your week with RADHA" landing screen. The shape is
/// deliberately tolerant: every aggregate counter has a sane default so a
/// trimmed-down server payload (or the legacy `{summary, highlights}` shape
/// the cron originally emitted) renders without throwing. Server-side the
/// canonical builder is `DigestPayloadBuilderService` — fields the backend
/// doesn't populate yet remain zero / empty until the analytics rollups
/// (BE-29) light them up.
@JsonSerializable(createToJson: false)
class WeeklyDigestResponse {
  const WeeklyDigestResponse({
    this.weekIso,
    this.weekStartDate,
    this.weekEndDate,
    this.scansCount = 0,
    this.savedProductsCount = 0,
    this.expiringSoonCount = 0,
    this.recallAlertsCount = 0,
    this.estimatedSavingsInr = 0,
    this.topCategories = const <WeeklyDigestTopCategory>[],
    this.healthHighlights = const <String>[],
    this.summary,
    this.highlights,
  });

  /// ISO week label, e.g. `2026-W21`. Optional — when null the screen
  /// falls back to formatting the week range from `weekStartDate`.
  final String? weekIso;

  /// ISO-8601 date for the Monday (or week-start) the digest covers.
  final String? weekStartDate;

  /// ISO-8601 date for the Sunday (or week-end) the digest covers.
  final String? weekEndDate;

  /// Total scans the user made in the reported week.
  final int scansCount;

  /// Products the user bookmarked / saved in the week.
  final int savedProductsCount;

  /// Items in the user's expiry tracker that fall due in the next 7 days.
  final int expiringSoonCount;

  /// Number of recall alerts flagged for products the user scanned.
  final int recallAlertsCount;

  /// Estimated INR saved by following healthier-alternative suggestions.
  final num estimatedSavingsInr;

  /// Top categories the user scanned, sorted desc by `count`.
  final List<WeeklyDigestTopCategory> topCategories;

  /// Short health-tips bullets surfaced for the week. Up to ~4 items.
  final List<String> healthHighlights;

  /// Legacy / future-compat free-form summary string. Surfaced today as a
  /// fallback when the rollup counters are all zero (the empty state still
  /// has something to render).
  final String? summary;

  /// Legacy / future-compat plain-string highlights, used as a fallback
  /// when `healthHighlights` is empty.
  final List<String>? highlights;

  factory WeeklyDigestResponse.fromJson(Map<String, dynamic> json) =>
      _$WeeklyDigestResponseFromJson(json);
}

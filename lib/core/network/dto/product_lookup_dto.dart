import 'package:json_annotation/json_annotation.dart';

part 'product_lookup_dto.g.dart';

/// Real nutrition for the rich product detail, from
/// `GET /api/v1/products/lookup/{ean}?includeNutrition=true`
/// (`ProductLookupService.lookupByEan`).
///
/// The lookup returns catalog fields + a nested `nutrition` row; it does NOT
/// carry the health score (that comes from the catalog item joined in
/// `/catalog/products`). All numeric nutrition values are Postgres decimals
/// serialised as strings, so we parse tolerantly via [_toDouble].

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

List<String>? _toStringList(dynamic v) {
  if (v == null) return null;
  if (v is List) {
    return v.map((item) => item.toString()).where((s) => s.isNotEmpty).toList();
  }
  if (v is bool) return v ? const ['declared'] : const [];
  final text = v.toString().trim();
  if (text.isEmpty) return const [];
  return text.split(',').map((item) => item.trim()).where((s) => s.isNotEmpty).toList();
}

String? _toStringOrNull(dynamic v) {
  if (v == null) return null;
  final text = v.toString().trim();
  return text.isEmpty ? null : text;
}

/// Per-serving / per-100g nutrition. Every field is nullable — a product may
/// have partial or no nutrition, which the UI renders as "—" (never zero-faked).
@JsonSerializable(createToJson: false)
class ProductNutrition {
  const ProductNutrition({
    this.servingSize,
    this.servingUnit,
    this.calories,
    this.protein,
    this.carbohydrates,
    this.sugars,
    this.fat,
    this.saturatedFat,
    this.transFat,
    this.fiber,
    this.sodium,
    this.containsAllergens,
    this.isProcessed,
  });

  @JsonKey(fromJson: _toDouble)
  final double? servingSize;
  final String? servingUnit;
  @JsonKey(fromJson: _toDouble)
  final double? calories;
  @JsonKey(fromJson: _toDouble)
  final double? protein;
  @JsonKey(fromJson: _toDouble)
  final double? carbohydrates;
  @JsonKey(fromJson: _toDouble)
  final double? sugars;
  @JsonKey(fromJson: _toDouble)
  final double? fat;
  @JsonKey(fromJson: _toDouble)
  final double? saturatedFat;
  @JsonKey(fromJson: _toDouble)
  final double? transFat;
  @JsonKey(fromJson: _toDouble)
  final double? fiber;
  @JsonKey(fromJson: _toDouble)
  final double? sodium;
  @JsonKey(fromJson: _toStringList)
  final List<String>? containsAllergens;
  @JsonKey(fromJson: _toStringOrNull)
  final String? isProcessed;

  /// True when at least one macronutrient value is present — lets the UI decide
  /// between the real nutrient panel and the honest "scan to unlock" state.
  bool get hasAnyValue =>
      calories != null ||
      protein != null ||
      carbohydrates != null ||
      sugars != null ||
      fat != null ||
      sodium != null;

  bool? get hasAllergenSignal => containsAllergens?.isNotEmpty;

  bool get isMinimallyProcessed => isProcessed == 'not';

  bool get isUltraProcessed => isProcessed == 'ultra';

  factory ProductNutrition.fromJson(Map<String, dynamic> json) =>
      _$ProductNutritionFromJson(json);
}

/// The product row returned by the lookup (subset we render).
@JsonSerializable(createToJson: false)
class ProductLookupItem {
  const ProductLookupItem({
    required this.id,
    required this.ean,
    required this.name,
    this.brand,
    this.imageUrl,
    this.subCategory,
    this.description,
    this.nutrition,
  });

  final String id;
  final String ean;
  final String name;
  final String? brand;
  final String? imageUrl;
  final String? subCategory;
  final String? description;
  final ProductNutrition? nutrition;

  factory ProductLookupItem.fromJson(Map<String, dynamic> json) =>
      _$ProductLookupItemFromJson(json);
}

/// Envelope from `lookupByEan` — `found` is false when neither the local
/// catalog nor OFF could resolve the barcode.
@JsonSerializable(createToJson: false)
class ProductLookupResult {
  const ProductLookupResult({required this.found, this.product, this.source});

  final bool found;
  final ProductLookupItem? product;
  final String? source;

  factory ProductLookupResult.fromJson(Map<String, dynamic> json) =>
      _$ProductLookupResultFromJson(json);
}

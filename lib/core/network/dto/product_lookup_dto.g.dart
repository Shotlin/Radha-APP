// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_lookup_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductNutrition _$ProductNutritionFromJson(Map<String, dynamic> json) =>
    ProductNutrition(
      servingSize: _toDouble(json['servingSize']),
      servingUnit: json['servingUnit'] as String?,
      calories: _toDouble(json['calories']),
      protein: _toDouble(json['protein']),
      carbohydrates: _toDouble(json['carbohydrates']),
      sugars: _toDouble(json['sugars']),
      fat: _toDouble(json['fat']),
      saturatedFat: _toDouble(json['saturatedFat']),
      transFat: _toDouble(json['transFat']),
      fiber: _toDouble(json['fiber']),
      sodium: _toDouble(json['sodium']),
      containsAllergens: _toStringList(json['containsAllergens']),
      isProcessed: _toStringOrNull(json['isProcessed']),
    );

ProductLookupItem _$ProductLookupItemFromJson(Map<String, dynamic> json) =>
    ProductLookupItem(
      id: json['id'] as String,
      ean: json['ean'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String?,
      imageUrl: json['imageUrl'] as String?,
      subCategory: json['subCategory'] as String?,
      description: json['description'] as String?,
      nutrition: json['nutrition'] == null
          ? null
          : ProductNutrition.fromJson(
              json['nutrition'] as Map<String, dynamic>,
            ),
    );

ProductLookupResult _$ProductLookupResultFromJson(Map<String, dynamic> json) =>
    ProductLookupResult(
      found: json['found'] as bool,
      product: json['product'] == null
          ? null
          : ProductLookupItem.fromJson(json['product'] as Map<String, dynamic>),
      source: json['source'] as String?,
    );

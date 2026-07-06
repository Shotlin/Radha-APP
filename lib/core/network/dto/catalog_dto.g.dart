// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CatalogCategory _$CatalogCategoryFromJson(Map<String, dynamic> json) =>
    CatalogCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      sortOrder: (json['sortOrder'] as num).toInt(),
    );

CatalogProductItem _$CatalogProductItemFromJson(Map<String, dynamic> json) =>
    CatalogProductItem(
      id: json['id'] as String,
      ean: json['ean'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String?,
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String?,
      healthScore: json['healthScore'] as num?,
      healthGrade: json['healthGrade'] as String?,
      healthStatus: json['healthStatus'] as String?,
    );

CatalogBrowsePage _$CatalogBrowsePageFromJson(Map<String, dynamic> json) =>
    CatalogBrowsePage(
      items: (json['items'] as List<dynamic>)
          .map((e) => CatalogProductItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
    );

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductResponse _$ProductResponseFromJson(Map<String, dynamic> json) =>
    ProductResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      ean: json['ean'] as String?,
      brand: json['brand'] as String?,
      category: json['category'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );

PaginatedProducts _$PaginatedProductsFromJson(Map<String, dynamic> json) =>
    PaginatedProducts(
      items: (json['items'] as List<dynamic>)
          .map((e) => ProductResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      cursor: json['cursor'] as String?,
    );

Map<String, dynamic> _$CreateProductDtoToJson(CreateProductDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'ean': instance.ean,
      'brand': instance.brand,
      'category': instance.category,
    };

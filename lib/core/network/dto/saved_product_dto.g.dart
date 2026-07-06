// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_product_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SavedProductDto _$SavedProductDtoFromJson(Map<String, dynamic> json) =>
    SavedProductDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      productName: json['productName'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      productId: json['productId'] as String?,
      barcode: json['barcode'] as String?,
      expiresAt: json['expiresAt'] as String?,
      markedConsumedAt: json['markedConsumedAt'] as String?,
      notes: json['notes'] as String?,
    );

ListSavedProductsResponse _$ListSavedProductsResponseFromJson(
  Map<String, dynamic> json,
) => ListSavedProductsResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => SavedProductDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  nextCursor: json['nextCursor'] as String?,
);

Map<String, dynamic> _$CreateSavedProductDtoToJson(
  CreateSavedProductDto instance,
) => <String, dynamic>{
  'productName': instance.productName,
  if (instance.productId case final value?) 'productId': value,
  if (instance.barcode case final value?) 'barcode': value,
  if (instance.expiresAt case final value?) 'expiresAt': value,
  if (instance.notes case final value?) 'notes': value,
};

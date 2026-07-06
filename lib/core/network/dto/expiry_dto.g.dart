// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expiry_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$CreateExpiryDtoToJson(CreateExpiryDto instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'storeId': instance.storeId,
      'expiryDate': instance.expiryDate,
      'manufactureDate': instance.manufactureDate,
      'batchNumber': instance.batchNumber,
      'quantity': instance.quantity,
      'source': instance.source,
      'shelfLocation': instance.shelfLocation,
    };

ExpiryResponse _$ExpiryResponseFromJson(Map<String, dynamic> json) =>
    ExpiryResponse(
      id: json['id'] as String,
      productId: json['productId'] as String,
      expiryDate: json['expiryDate'] as String,
      batchNumber: json['batchNumber'] as String?,
      quantity: (json['quantity'] as num?)?.toInt(),
      status: json['status'] as String?,
    );

PaginatedExpiries _$PaginatedExpiriesFromJson(Map<String, dynamic> json) =>
    PaginatedExpiries(
      items: (json['items'] as List<dynamic>)
          .map((e) => ExpiryResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      cursor: json['cursor'] as String?,
    );

ExpiryCalendarResponse _$ExpiryCalendarResponseFromJson(
  Map<String, dynamic> json,
) => ExpiryCalendarResponse(
  entries: (json['entries'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
);

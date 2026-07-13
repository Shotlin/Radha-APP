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
      if (instance.manufactureDate case final value?) 'manufactureDate': value,
      if (instance.batchNumber case final value?) 'batchNumber': value,
      if (instance.quantity case final value?) 'quantity': value,
      'source': instance.source,
      if (instance.shelfLocation case final value?) 'shelfLocation': value,
    };

ExpiryResponse _$ExpiryResponseFromJson(Map<String, dynamic> json) =>
    ExpiryResponse(
      id: json['id'] as String,
      productId: json['productId'] as String,
      expiryDate: json['expiryDate'] as String,
      productName: json['productName'] as String?,
      manufactureDate: json['manufactureDate'] as String?,
      batchNumber: json['batchNumber'] as String?,
      quantity: (json['quantity'] as num?)?.toInt(),
      remainingQuantity: (json['remainingQuantity'] as num?)?.toInt(),
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grn_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$CreateGrnDtoToJson(CreateGrnDto instance) =>
    <String, dynamic>{
      'supplierId': instance.supplierId,
      'invoiceNumber': instance.invoiceNumber,
      'invoiceDate': instance.invoiceDate,
      'expectedDeliveryDate': instance.expectedDeliveryDate,
      'items': instance.items,
    };

GrnResponse _$GrnResponseFromJson(Map<String, dynamic> json) => GrnResponse(
  id: json['id'] as String,
  supplierId: json['supplierId'] as String,
  supplierName: json['supplierName'] as String?,
  invoiceNumber: json['invoiceNumber'] as String?,
  invoiceDate: json['invoiceDate'] as String?,
  status: json['status'] as String?,
  totalItems: (json['totalItems'] as num?)?.toInt(),
  totalQuantity: (json['totalQuantity'] as num?)?.toInt(),
  totalValue: (json['totalValue'] as num?)?.toDouble(),
  createdAt: json['createdAt'] as String?,
);

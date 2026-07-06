// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$CreateScanSessionDtoToJson(
  CreateScanSessionDto instance,
) => <String, dynamic>{
  'storeId': instance.storeId,
  'type': instance.type,
  if (instance.eanListId case final value?) 'eanListId': value,
};

Map<String, dynamic> _$EndScanSessionDtoToJson(EndScanSessionDto instance) =>
    <String, dynamic>{if (instance.notes case final value?) 'notes': value};

Map<String, dynamic> _$RecordScanItemDtoToJson(RecordScanItemDto instance) =>
    <String, dynamic>{
      'ean': instance.ean,
      'scannedAt': instance.scannedAt,
      'quantity': instance.quantity,
      if (instance.clientId case final value?) 'clientId': value,
      if (instance.expiryDate case final value?) 'expiryDate': value,
      if (instance.batchNumber case final value?) 'batchNumber': value,
      if (instance.notes case final value?) 'notes': value,
    };

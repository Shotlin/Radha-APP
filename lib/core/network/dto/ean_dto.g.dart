// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ean_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$ValidateEanDtoToJson(ValidateEanDto instance) =>
    <String, dynamic>{'ean': instance.ean, 'storeId': instance.storeId};

Map<String, dynamic> _$ValidateEanBatchDtoToJson(
  ValidateEanBatchDto instance,
) => <String, dynamic>{'eans': instance.eans, 'storeId': instance.storeId};

Map<String, dynamic> _$CreateEanListDtoToJson(CreateEanListDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      if (instance.description case final value?) 'description': value,
      if (instance.storeId case final value?) 'storeId': value,
    };

Map<String, dynamic> _$ImportEanInlineDtoToJson(ImportEanInlineDto instance) =>
    <String, dynamic>{
      'fileType': instance.fileType,
      'fileName': instance.fileName,
      'fileBase64': instance.fileBase64,
    };

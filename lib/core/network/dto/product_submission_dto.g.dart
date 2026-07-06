// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_submission_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$NutritionPanelPayloadToJson(
  NutritionPanelPayload instance,
) => <String, dynamic>{
  if (instance.servingSize case final value?) 'servingSize': value,
  if (instance.servingUnit case final value?) 'servingUnit': value,
  if (instance.calories case final value?) 'calories': value,
  if (instance.protein case final value?) 'protein': value,
  if (instance.carbohydrates case final value?) 'carbohydrates': value,
  if (instance.sugars case final value?) 'sugars': value,
  if (instance.fat case final value?) 'fat': value,
  if (instance.saturatedFat case final value?) 'saturatedFat': value,
  if (instance.transFat case final value?) 'transFat': value,
  if (instance.fiber case final value?) 'fiber': value,
  if (instance.sodium case final value?) 'sodium': value,
  'isEmpty': instance.isEmpty,
};

Map<String, dynamic> _$SubmissionPresignRequestDtoToJson(
  SubmissionPresignRequestDto instance,
) => <String, dynamic>{
  'contentType': instance.contentType,
  'contentLength': instance.contentLength,
  'filename': instance.filename,
};

SubmissionPresignResponseDto _$SubmissionPresignResponseDtoFromJson(
  Map<String, dynamic> json,
) => SubmissionPresignResponseDto(
  mediaId: json['mediaId'] as String,
  uploadUrl: json['uploadUrl'] as String,
  uploadFields: json['uploadFields'] as Map<String, dynamic>,
  expiresIn: (json['expiresIn'] as num).toInt(),
  cdnUrl: json['cdnUrl'] as String,
  s3Key: json['s3Key'] as String,
);

ConfirmedMediaDto _$ConfirmedMediaDtoFromJson(Map<String, dynamic> json) =>
    ConfirmedMediaDto(
      id: json['id'] as String,
      status: json['status'] as String,
      s3Key: json['s3Key'] as String,
    );

Map<String, dynamic> _$SubmitProductRequestDtoToJson(
  SubmitProductRequestDto instance,
) => <String, dynamic>{
  'ean': instance.ean,
  if (instance.brand case final value?) 'brand': value,
  if (instance.name case final value?) 'name': value,
  if (instance.category case final value?) 'category': value,
  if (instance.ingredients case final value?) 'ingredients': value,
  if (instance.s3ObjectKeys case final value?) 's3ObjectKeys': value,
  if (instance.nutrition?.toJson() case final value?) 'nutrition': value,
};

SubmissionResponseDto _$SubmissionResponseDtoFromJson(
  Map<String, dynamic> json,
) => SubmissionResponseDto(
  id: json['id'] as String,
  status: json['status'] as String,
  ean: json['ean'] as String,
);

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_dates_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BatchSummary _$BatchSummaryFromJson(Map<String, dynamic> json) => BatchSummary(
  batchCode: json['batchCode'] as String,
  status: json['status'] as String,
  confirmations: (json['confirmations'] as num).toInt(),
  expiryDate: json['expiryDate'] as String?,
);

BatchListResponse _$BatchListResponseFromJson(Map<String, dynamic> json) =>
    BatchListResponse(
      batches: (json['batches'] as List<dynamic>)
          .map((e) => BatchSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

BatchDateSuggestion _$BatchDateSuggestionFromJson(Map<String, dynamic> json) =>
    BatchDateSuggestion(
      distinctUsers: (json['distinctUsers'] as num).toInt(),
      expiryDate: json['expiryDate'] as String?,
      mfgDate: json['mfgDate'] as String?,
    );

BatchDatesResponse _$BatchDatesResponseFromJson(Map<String, dynamic> json) =>
    BatchDatesResponse(
      ean: json['ean'] as String,
      batchCode: json['batchCode'] as String,
      status: json['status'] as String,
      confirmations: (json['confirmations'] as num).toInt(),
      distinctUsers: (json['distinctUsers'] as num).toInt(),
      confidence: (json['confidence'] as num).toDouble(),
      suggestions: (json['suggestions'] as List<dynamic>)
          .map((e) => BatchDateSuggestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      expiryDate: json['expiryDate'] as String?,
      mfgDate: json['mfgDate'] as String?,
    );

Map<String, dynamic> _$CreateObservationDtoToJson(
  CreateObservationDto instance,
) => <String, dynamic>{
  'expiryDate': instance.expiryDate,
  'mfgDate': instance.mfgDate,
  'capturedVia': instance.capturedVia,
  'extractorConfidence': instance.extractorConfidence,
};

ObservationResponse _$ObservationResponseFromJson(Map<String, dynamic> json) =>
    ObservationResponse(
      consensus: BatchDatesResponse.fromJson(
        json['consensus'] as Map<String, dynamic>,
      ),
    );

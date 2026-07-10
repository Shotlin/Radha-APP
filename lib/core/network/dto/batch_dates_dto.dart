import 'package:json_annotation/json_annotation.dart';

part 'batch_dates_dto.g.dart';

// ─── Batch summary (GET /products/{ean}/batches) ────────────────────────────

@JsonSerializable(createToJson: false)
class BatchSummary {
  const BatchSummary({
    required this.batchCode,
    required this.status,
    required this.confirmations,
    this.expiryDate,
  });

  final String batchCode;

  /// 'candidate' | 'trusted' | 'disputed'
  final String status;
  final int confirmations;

  /// ISO date string, null when status is 'disputed'.
  final String? expiryDate;

  factory BatchSummary.fromJson(Map<String, dynamic> json) =>
      _$BatchSummaryFromJson(json);
}

@JsonSerializable(createToJson: false)
class BatchListResponse {
  const BatchListResponse({required this.batches});
  final List<BatchSummary> batches;
  factory BatchListResponse.fromJson(Map<String, dynamic> json) =>
      _$BatchListResponseFromJson(json);
}

// ─── Batch dates detail (GET /products/{ean}/batches/{batchCode}/dates) ─────

@JsonSerializable(createToJson: false)
class BatchDateSuggestion {
  const BatchDateSuggestion({
    required this.distinctUsers,
    this.expiryDate,
    this.mfgDate,
  });
  final int distinctUsers;
  final String? expiryDate;
  final String? mfgDate;
  factory BatchDateSuggestion.fromJson(Map<String, dynamic> json) =>
      _$BatchDateSuggestionFromJson(json);
}

@JsonSerializable(createToJson: false)
class BatchDatesResponse {
  const BatchDatesResponse({
    required this.ean,
    required this.batchCode,
    required this.status,
    required this.confirmations,
    required this.distinctUsers,
    required this.confidence,
    required this.suggestions,
    this.expiryDate,
    this.mfgDate,
  });

  final String ean;
  final String batchCode;

  /// 'candidate' | 'trusted' | 'disputed'
  final String status;
  final int confirmations;
  final int distinctUsers;
  final double confidence;
  final List<BatchDateSuggestion> suggestions;

  /// ISO date string; null when status is 'disputed'.
  final String? expiryDate;
  final String? mfgDate;

  bool get isTrusted => status == 'trusted';
  bool get isCandidate => status == 'candidate';
  bool get isDisputed => status == 'disputed';

  factory BatchDatesResponse.fromJson(Map<String, dynamic> json) =>
      _$BatchDatesResponseFromJson(json);
}

// ─── Observation (POST /products/{ean}/batches/{batchCode}/observations) ────

@JsonSerializable(createFactory: false)
class CreateObservationDto {
  const CreateObservationDto({
    required this.expiryDate,
    required this.capturedVia,
    this.mfgDate,
    this.extractorConfidence,
  });

  final String expiryDate;
  final String? mfgDate;

  /// 'live_scan' | 'manual'
  final String capturedVia;
  final double? extractorConfidence;

  Map<String, dynamic> toJson() => _$CreateObservationDtoToJson(this);
}

@JsonSerializable(createToJson: false)
class ObservationResponse {
  const ObservationResponse({required this.consensus});
  final BatchDatesResponse consensus;
  factory ObservationResponse.fromJson(Map<String, dynamic> json) =>
      _$ObservationResponseFromJson(json);
}

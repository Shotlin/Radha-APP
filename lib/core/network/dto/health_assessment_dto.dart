import 'package:json_annotation/json_annotation.dart';

part 'health_assessment_dto.g.dart';

/// One rule hit from the backend's `ScoringEngineService` — e.g. "sugar is
/// 28g/100g, over the 22.5g high-sugar threshold". Message is already
/// human-readable server-side; the client only needs `type` to pick an
/// icon/chip and `message` to show it.
@JsonSerializable(createToJson: false)
class HealthWarning {
  const HealthWarning({required this.type, required this.severity, required this.message});

  final String type;
  final String severity;
  final String message;

  factory HealthWarning.fromJson(Map<String, dynamic> json) => _$HealthWarningFromJson(json);
}

@JsonSerializable(createToJson: false)
class HealthPositive {
  const HealthPositive({required this.type, required this.message});

  final String type;
  final String message;

  factory HealthPositive.fromJson(Map<String, dynamic> json) => _$HealthPositiveFromJson(json);
}

@JsonSerializable(createToJson: false)
class ChildSafetyResult {
  const ChildSafetyResult({required this.status, required this.reasons});

  /// 'suitable' | 'caution' | 'unsuitable' | 'unknown'
  final String status;
  final List<String> reasons;

  factory ChildSafetyResult.fromJson(Map<String, dynamic> json) =>
      _$ChildSafetyResultFromJson(json);
}

/// `GET /api/v1/products/{productId}/health` response — BE-12 Health
/// Scoring Engine output. Computed on demand (or served from cache) so a
/// product with no cached assessment yet still resolves here rather than
/// 404ing; the scan result screen therefore always gets *something*
/// (possibly `data_unavailable`) rather than needing a separate "not
/// computed yet" branch.
@JsonSerializable(createToJson: false)
class HealthAssessmentDto {
  const HealthAssessmentDto({
    required this.productId,
    required this.overallGrade,
    required this.overallScore,
    required this.healthStatus,
    required this.childSafety,
    required this.warnings,
    required this.positives,
    required this.isProcessed,
  });

  final String productId;

  /// 'A' | 'B' | 'C' | 'D' | 'E' | 'U'
  final String overallGrade;

  /// 0..100
  final int overallScore;

  /// 'green' | 'yellow' | 'red' | 'data_unavailable'
  final String healthStatus;
  final ChildSafetyResult childSafety;
  final List<HealthWarning> warnings;
  final List<HealthPositive> positives;

  /// 'not' | 'lightly' | 'ultra' | 'unknown'
  final String isProcessed;

  bool warningOfType(String type) => warnings.any((w) => w.type == type);
  bool positiveOfType(String type) => positives.any((p) => p.type == type);

  factory HealthAssessmentDto.fromJson(Map<String, dynamic> json) =>
      _$HealthAssessmentDtoFromJson(json);
}

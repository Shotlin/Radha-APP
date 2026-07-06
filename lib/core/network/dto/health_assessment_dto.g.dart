// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_assessment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthWarning _$HealthWarningFromJson(Map<String, dynamic> json) =>
    HealthWarning(
      type: json['type'] as String,
      severity: json['severity'] as String,
      message: json['message'] as String,
    );

HealthPositive _$HealthPositiveFromJson(Map<String, dynamic> json) =>
    HealthPositive(
      type: json['type'] as String,
      message: json['message'] as String,
    );

ChildSafetyResult _$ChildSafetyResultFromJson(Map<String, dynamic> json) =>
    ChildSafetyResult(
      status: json['status'] as String,
      reasons: (json['reasons'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

HealthAssessmentDto _$HealthAssessmentDtoFromJson(Map<String, dynamic> json) =>
    HealthAssessmentDto(
      productId: json['productId'] as String,
      overallGrade: json['overallGrade'] as String,
      overallScore: (json['overallScore'] as num).toInt(),
      healthStatus: json['healthStatus'] as String,
      childSafety: ChildSafetyResult.fromJson(
        json['childSafety'] as Map<String, dynamic>,
      ),
      warnings: (json['warnings'] as List<dynamic>)
          .map((e) => HealthWarning.fromJson(e as Map<String, dynamic>))
          .toList(),
      positives: (json['positives'] as List<dynamic>)
          .map((e) => HealthPositive.fromJson(e as Map<String, dynamic>))
          .toList(),
      isProcessed: json['isProcessed'] as String,
    );

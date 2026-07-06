import 'package:json_annotation/json_annotation.dart';

part 'product_submission_dto.g.dart';

/// Nutrition panel values read off a label by the live scanner, sent
/// with a community product submission. Field names mirror the
/// backend's `NutritionPanelSchema`
/// (`radha_backend/src/modules/barcode-learning/dto/nutrition-panel.dto.ts`).
/// Every field optional — a submission may carry only a subset of
/// what the scanner confirmed.
@JsonSerializable(createFactory: false, includeIfNull: false)
class NutritionPanelPayload {
  const NutritionPanelPayload({
    this.servingSize,
    this.servingUnit,
    this.calories,
    this.protein,
    this.carbohydrates,
    this.sugars,
    this.fat,
    this.saturatedFat,
    this.transFat,
    this.fiber,
    this.sodium,
  });

  final double? servingSize;
  final String? servingUnit;
  final double? calories;
  final double? protein;
  final double? carbohydrates;
  final double? sugars;
  final double? fat;
  final double? saturatedFat;
  final double? transFat;
  final double? fiber;
  final double? sodium;

  /// True when every field is null — callers should omit the whole
  /// `nutrition` object rather than send an empty one.
  bool get isEmpty =>
      servingSize == null &&
      servingUnit == null &&
      calories == null &&
      protein == null &&
      carbohydrates == null &&
      sugars == null &&
      fat == null &&
      saturatedFat == null &&
      transFat == null &&
      fiber == null &&
      sodium == null;

  Map<String, dynamic> toJson() => _$NutritionPanelPayloadToJson(this);
}

/// `POST /api/v1/products/learn/presign` request body.
@JsonSerializable(createFactory: false)
class SubmissionPresignRequestDto {
  const SubmissionPresignRequestDto({
    required this.contentType,
    required this.contentLength,
    this.filename,
  });

  final String contentType;
  final int contentLength;
  final String? filename;

  Map<String, dynamic> toJson() => _$SubmissionPresignRequestDtoToJson(this);
}

/// `POST /api/v1/products/learn/presign` response — an S3 presigned
/// POST policy. `uploadFields` must be sent as-is, alongside the file
/// bytes, in a multipart POST directly to `uploadUrl` (not through
/// the authenticated API client — see `product_submission_repository.dart`).
@JsonSerializable(createToJson: false)
class SubmissionPresignResponseDto {
  const SubmissionPresignResponseDto({
    required this.mediaId,
    required this.uploadUrl,
    required this.uploadFields,
    required this.expiresIn,
    required this.cdnUrl,
    required this.s3Key,
  });

  final String mediaId;
  final String uploadUrl;
  final Map<String, dynamic> uploadFields;
  final int expiresIn;
  final String cdnUrl;
  final String s3Key;

  factory SubmissionPresignResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SubmissionPresignResponseDtoFromJson(json);
}

/// `POST /api/v1/products/learn/media/{mediaId}/confirm` response.
/// Only the fields the submission flow actually needs.
@JsonSerializable(createToJson: false)
class ConfirmedMediaDto {
  const ConfirmedMediaDto({required this.id, required this.status, required this.s3Key});

  final String id;
  final String status;
  final String s3Key;

  factory ConfirmedMediaDto.fromJson(Map<String, dynamic> json) =>
      _$ConfirmedMediaDtoFromJson(json);
}

/// `POST /api/v1/products/learn` request body.
@JsonSerializable(createFactory: false, includeIfNull: false)
class SubmitProductRequestDto {
  const SubmitProductRequestDto({
    required this.ean,
    this.brand,
    this.name,
    this.category,
    this.ingredients,
    this.s3ObjectKeys,
    this.nutrition,
  });

  final String ean;
  final String? brand;
  final String? name;
  final String? category;
  /// The label's INGREDIENTS list (OCR'd, then user-editable before submit).
  final String? ingredients;
  final List<String>? s3ObjectKeys;
  final NutritionPanelPayload? nutrition;

  Map<String, dynamic> toJson() => _$SubmitProductRequestDtoToJson(this);
}

/// `POST /api/v1/products/learn` response — the created submission,
/// pending moderator review.
@JsonSerializable(createToJson: false)
class SubmissionResponseDto {
  const SubmissionResponseDto({required this.id, required this.status, required this.ean});

  final String id;
  final String status;
  final String ean;

  factory SubmissionResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SubmissionResponseDtoFromJson(json);
}

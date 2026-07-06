import 'package:json_annotation/json_annotation.dart';

part 'ean_dto.g.dart';

/// Coerces a JSON numeric (which may arrive as `int` or `double`) into a
/// nullable `int`. Returns `null` when the value is absent or not numeric.
int? _asIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

// ─── Request DTOs ────────────────────────────────────────────────────────

/// Body for `POST /api/v1/ean-lists/validate`.
@JsonSerializable(createFactory: false)
class ValidateEanDto {
  const ValidateEanDto({required this.ean, required this.storeId});

  final String ean;
  final String storeId;

  Map<String, dynamic> toJson() => _$ValidateEanDtoToJson(this);
}

/// Body for `POST /api/v1/ean-lists/validate/batch`.
@JsonSerializable(createFactory: false)
class ValidateEanBatchDto {
  const ValidateEanBatchDto({required this.eans, required this.storeId});

  final List<String> eans;
  final String storeId;

  Map<String, dynamic> toJson() => _$ValidateEanBatchDtoToJson(this);
}

/// Body for `POST /api/v1/ean-lists`.
@JsonSerializable(createFactory: false, includeIfNull: false)
class CreateEanListDto {
  const CreateEanListDto({required this.name, this.description, this.storeId});

  final String name;
  final String? description;
  final String? storeId;

  Map<String, dynamic> toJson() => _$CreateEanListDtoToJson(this);
}

/// Body for `POST /api/v1/ean-lists/:id/import` — inline base64 upload.
@JsonSerializable(createFactory: false)
class ImportEanInlineDto {
  const ImportEanInlineDto({
    required this.fileType,
    required this.fileName,
    required this.fileBase64,
  });

  final String fileType;
  final String fileName;
  final String fileBase64;

  Map<String, dynamic> toJson() => _$ImportEanInlineDtoToJson(this);
}

// ─── Response DTOs ───────────────────────────────────────────────────────

/// Result of validating a single EAN against the store's approved list.
/// Hand-rolled and tolerant of missing fields — `valid`/`matched` default
/// to `false`.
class EanValidationResult {
  const EanValidationResult({
    required this.valid,
    required this.ean,
    required this.matched,
    this.reason,
    this.validatedAt,
  });

  final bool valid;
  final String ean;
  final bool matched;

  /// `not_in_list` | `list_inactive` | `no_active_list` | `invalid_format`
  /// | `no_store`. Absent when [matched] is true.
  final String? reason;
  final String? validatedAt;

  factory EanValidationResult.fromJson(Map<String, dynamic> json) {
    return EanValidationResult(
      valid: json['valid'] == true,
      ean: (json['ean'] ?? '').toString(),
      matched: json['matched'] == true,
      reason: json['reason'] as String?,
      validatedAt: json['validatedAt'] as String?,
    );
  }
}

/// One EAN list row from `GET /api/v1/ean-lists`. Treated loosely — only the
/// fields the UI surfaces are modelled.
class EanListSummary {
  const EanListSummary({
    required this.id,
    required this.name,
    this.status,
    this.storeId,
    this.description,
  });

  final String id;
  final String name;
  final String? status;
  final String? storeId;
  final String? description;

  factory EanListSummary.fromJson(Map<String, dynamic> json) {
    return EanListSummary(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      status: json['status'] as String?,
      storeId: json['storeId'] as String?,
      description: json['description'] as String?,
    );
  }
}

/// 202 response from kicking off an inline import.
class EanImportInitResponse {
  const EanImportInitResponse({
    required this.batchId,
    required this.status,
    this.estimatedRows,
    this.estimatedDurationSeconds,
  });

  final String batchId;
  final String status;
  final int? estimatedRows;
  final int? estimatedDurationSeconds;

  factory EanImportInitResponse.fromJson(Map<String, dynamic> json) {
    return EanImportInitResponse(
      batchId: (json['batchId'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      estimatedRows: _asIntOrNull(json['estimatedRows']),
      estimatedDurationSeconds: _asIntOrNull(json['estimatedDurationSeconds']),
    );
  }
}

/// Import progress for `GET /api/v1/ean-lists/imports/:batchId`. The
/// percentage + row counters live under a nested `progress` object; this
/// hand-rolled factory flattens them.
class EanImportStatusResponse {
  const EanImportStatusResponse({
    required this.batchId,
    required this.status,
    this.percentage,
    this.totalRows,
    this.processedRows,
    this.validRows,
    this.invalidRows,
    this.errorMessage,
  });

  final String batchId;
  final String status;
  final int? percentage;
  final int? totalRows;
  final int? processedRows;
  final int? validRows;
  final int? invalidRows;
  final String? errorMessage;

  factory EanImportStatusResponse.fromJson(Map<String, dynamic> json) {
    final progress = json['progress'] is Map<String, dynamic>
        ? json['progress'] as Map<String, dynamic>
        : const <String, dynamic>{};
    return EanImportStatusResponse(
      batchId: (json['batchId'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      percentage: _asIntOrNull(progress['percentage']),
      totalRows: _asIntOrNull(progress['totalRows']),
      processedRows: _asIntOrNull(progress['processedRows']),
      validRows: _asIntOrNull(progress['validRows']),
      invalidRows: _asIntOrNull(progress['invalidRows']),
      errorMessage: json['errorMessage'] as String?,
    );
  }
}

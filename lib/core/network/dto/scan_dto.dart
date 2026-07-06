import 'package:json_annotation/json_annotation.dart';

part 'scan_dto.g.dart';

/// Coerces a JSON numeric (which may arrive as `int` or `double`) into a
/// nullable `int`. Returns `null` when the value is absent or not numeric.
int? _asIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

// ─── Request DTOs ────────────────────────────────────────────────────────

/// Body for `POST /api/v1/scan-sessions` — opens a new scan session of the
/// given [type] (default `audit`), optionally bound to an approved EAN list.
@JsonSerializable(createFactory: false, includeIfNull: false)
class CreateScanSessionDto {
  const CreateScanSessionDto({
    required this.storeId,
    this.type = 'audit',
    this.eanListId,
  });

  final String storeId;
  final String type;
  final String? eanListId;

  Map<String, dynamic> toJson() => _$CreateScanSessionDtoToJson(this);
}

/// Body for `POST /api/v1/scan-sessions/:id/end`.
@JsonSerializable(createFactory: false, includeIfNull: false)
class EndScanSessionDto {
  const EndScanSessionDto({this.notes});

  final String? notes;

  Map<String, dynamic> toJson() => _$EndScanSessionDtoToJson(this);
}

/// Body for `POST /api/v1/scan-sessions/:id/items` — records a single scanned
/// item against the session.
@JsonSerializable(createFactory: false, includeIfNull: false)
class RecordScanItemDto {
  const RecordScanItemDto({
    required this.ean,
    required this.scannedAt,
    this.quantity = 1,
    this.clientId,
    this.expiryDate,
    this.batchNumber,
    this.notes,
  });

  final String ean;
  final String scannedAt;
  final int quantity;
  final String? clientId;
  final String? expiryDate;
  final String? batchNumber;
  final String? notes;

  Map<String, dynamic> toJson() => _$RecordScanItemDtoToJson(this);
}

// ─── Response DTOs ───────────────────────────────────────────────────────

/// A scan session row. Counters are tolerant of `num`/missing values so a
/// trimmed-down server payload still parses.
class ScanSessionResponse {
  const ScanSessionResponse({
    required this.id,
    this.storeId,
    this.type,
    this.status,
    this.totalScans,
    this.matchedEans,
    this.unmatchedEans,
  });

  final String id;
  final String? storeId;
  final String? type;
  final String? status;
  final int? totalScans;
  final int? matchedEans;
  final int? unmatchedEans;

  factory ScanSessionResponse.fromJson(Map<String, dynamic> json) {
    return ScanSessionResponse(
      id: (json['id'] ?? '').toString(),
      storeId: json['storeId'] as String?,
      type: json['type'] as String?,
      status: json['status'] as String?,
      totalScans: _asIntOrNull(json['totalScans']),
      matchedEans: _asIntOrNull(json['matchedEans']),
      unmatchedEans: _asIntOrNull(json['unmatchedEans']),
    );
  }
}

/// Aggregate summary for a session (`GET /scan-sessions/:id/summary`).
class ScanSessionSummary {
  const ScanSessionSummary({
    required this.sessionId,
    required this.totalScans,
    required this.uniqueProducts,
    required this.matchedEans,
    required this.unmatchedEans,
    required this.expiredItems,
    required this.nearExpiryItems,
    required this.warningsCount,
  });

  final String sessionId;
  final int totalScans;
  final int uniqueProducts;
  final int matchedEans;
  final int unmatchedEans;
  final int expiredItems;
  final int nearExpiryItems;
  final int warningsCount;

  factory ScanSessionSummary.fromJson(Map<String, dynamic> json) {
    return ScanSessionSummary(
      sessionId: (json['sessionId'] ?? '').toString(),
      totalScans: _asIntOrNull(json['totalScans']) ?? 0,
      uniqueProducts: _asIntOrNull(json['uniqueProducts']) ?? 0,
      matchedEans: _asIntOrNull(json['matchedEans']) ?? 0,
      unmatchedEans: _asIntOrNull(json['unmatchedEans']) ?? 0,
      expiredItems: _asIntOrNull(json['expiredItems']) ?? 0,
      nearExpiryItems: _asIntOrNull(json['nearExpiryItems']) ?? 0,
      warningsCount: _asIntOrNull(json['warningsCount']) ?? 0,
    );
  }
}

/// A single warning attached to a scan-item result.
class ScanWarningDto {
  const ScanWarningDto({
    required this.type,
    required this.message,
    required this.severity,
  });

  final String type;
  final String message;
  final String severity;

  factory ScanWarningDto.fromJson(Map<String, dynamic> json) {
    return ScanWarningDto(
      type: (json['type'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      severity: (json['severity'] ?? 'info').toString(),
    );
  }
}

/// Projection over the `POST /scan-sessions/:id/items` result. The server
/// returns a nested `{ scanItem, product, eanValidation, warnings, ... }`
/// envelope — this flattens the fields the UI actually needs. Hand-rolled
/// (not generated) because it digs into the nested `scanItem` map.
class ScanItemResultResponse {
  const ScanItemResultResponse({
    required this.ean,
    required this.eanMatchStatus,
    required this.matched,
    this.productName,
    this.brand,
    this.expiryStatus,
    this.isDuplicate = false,
    this.warnings = const <ScanWarningDto>[],
  });

  final String ean;

  /// `matched` | `unmatched` | `no_list` | `invalid` | `unchecked`.
  final String eanMatchStatus;

  /// Convenience flag derived from [eanMatchStatus] == `matched`.
  final bool matched;

  final String? productName;
  final String? brand;
  final String? expiryStatus;
  final bool isDuplicate;
  final List<ScanWarningDto> warnings;

  factory ScanItemResultResponse.fromJson(Map<String, dynamic> json) {
    final scanItem = json['scanItem'] is Map<String, dynamic>
        ? json['scanItem'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final product = json['product'] is Map<String, dynamic>
        ? json['product'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final ean = (scanItem['ean'] ?? json['ean'] ?? '').toString();
    final matchStatus =
        (scanItem['eanMatchStatus'] ?? json['eanMatchStatus'] ?? 'unchecked')
            .toString();
    final productName =
        scanItem['productNameSnapshot'] as String? ?? product['name'] as String?;
    final brand =
        scanItem['brandSnapshot'] as String? ?? product['brand'] as String?;
    final expiryStatus =
        json['expiryStatus'] as String? ?? scanItem['expiryStatus'] as String?;
    final isDuplicate = json['isDuplicate'] == true;

    final rawWarnings = json['warnings'];
    final warnings = rawWarnings is List
        ? rawWarnings
              .whereType<Map<String, dynamic>>()
              .map(ScanWarningDto.fromJson)
              .toList()
        : const <ScanWarningDto>[];

    return ScanItemResultResponse(
      ean: ean,
      eanMatchStatus: matchStatus,
      matched: matchStatus == 'matched',
      productName: productName,
      brand: brand,
      expiryStatus: expiryStatus,
      isDuplicate: isDuplicate,
      warnings: warnings,
    );
  }
}

import 'package:json_annotation/json_annotation.dart';

part 'expiry_dto.g.dart';

@JsonSerializable(createFactory: false, includeIfNull: false)
class CreateExpiryDto {
  const CreateExpiryDto({
    required this.productId,
    required this.storeId,
    required this.expiryDate,
    this.manufactureDate,
    this.batchNumber,
    this.quantity,
    this.source = 'manual',
    this.shelfLocation,
  });

  final String productId;
  final String storeId;
  final String expiryDate;
  final String? manufactureDate;
  final String? batchNumber;
  final int? quantity;
  final String source;
  final String? shelfLocation;

  Map<String, dynamic> toJson() => _$CreateExpiryDtoToJson(this);
}

@JsonSerializable(createToJson: false)
class ExpiryResponse {
  const ExpiryResponse({
    required this.id,
    required this.productId,
    required this.expiryDate,
    this.productName,
    this.batchNumber,
    this.quantity,
    this.status,
  });

  final String id;
  final String productId;

  /// Server-joined product name. Null when the join returns no row (e.g.
  /// offline-queued records that haven't synced yet) — fall back to the
  /// short ID token display in that case.
  final String? productName;
  final String expiryDate;
  final String? batchNumber;
  final int? quantity;
  final String? status;

  factory ExpiryResponse.fromJson(Map<String, dynamic> json) =>
      _$ExpiryResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class PaginatedExpiries {
  const PaginatedExpiries({
    required this.items,
    required this.total,
    this.cursor,
  });

  final List<ExpiryResponse> items;
  final int total;
  final String? cursor;

  factory PaginatedExpiries.fromJson(Map<String, dynamic> json) =>
      _$PaginatedExpiriesFromJson(json);
}

@JsonSerializable(createToJson: false)
class ExpiryCalendarResponse {
  const ExpiryCalendarResponse({required this.entries});

  final List<Map<String, dynamic>> entries;

  factory ExpiryCalendarResponse.fromJson(Map<String, dynamic> json) =>
      _$ExpiryCalendarResponseFromJson(json);
}

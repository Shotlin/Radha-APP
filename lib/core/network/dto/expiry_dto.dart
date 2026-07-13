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

@JsonSerializable(includeIfNull: false)
class ExpiryResponse {
  const ExpiryResponse({
    required this.id,
    required this.productId,
    required this.expiryDate,
    this.productName,
    this.manufactureDate,
    this.batchNumber,
    this.quantity,
    this.remainingQuantity,
    this.status,
  });

  final String id;
  final String productId;

  /// Server-joined product name. Null when the join returns no row (e.g.
  /// offline-queued records that haven't synced yet) — fall back to the
  /// short ID token display in that case.
  final String? productName;
  final String expiryDate;
  final String? manufactureDate;
  final String? batchNumber;

  /// Quantity originally received — set once at creation, never updated
  /// after. Distinct from [remainingQuantity], the current stock level.
  final int? quantity;

  /// Current stock level — what the Quick Audit scan mode reads/writes via
  /// `PATCH /api/v1/expiry-records/:id`. `NOT NULL` on the server (set to
  /// `quantity` at creation); nullable here only as defensive JSON parsing.
  final int? remainingQuantity;
  final String? status;

  factory ExpiryResponse.fromJson(Map<String, dynamic> json) =>
      _$ExpiryResponseFromJson(json);

  /// Round-trips a fetched record back to JSON for the offline list cache
  /// (`expiry_list_screen.dart`) — not used for any outgoing API call.
  Map<String, dynamic> toJson() => _$ExpiryResponseToJson(this);
}

@JsonSerializable(createToJson: false)
class PaginatedExpiries {
  const PaginatedExpiries({
    required this.items,
    required this.total,
    this.cursor,
    this.isFromCache = false,
  });

  final List<ExpiryResponse> items;
  final int total;
  final String? cursor;

  /// True when this result was served from the on-device offline cache
  /// (`expiry_list_screen.dart`'s fetch-with-fallback) rather than a live
  /// server response — never set by the JSON parser, only by that fallback
  /// path constructing this object directly.
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isFromCache;

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

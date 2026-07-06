import 'package:json_annotation/json_annotation.dart';

part 'saved_product_dto.g.dart';

// ─── Saved Products (FE-16) ───────────────────────────────────────────────
//
// Mirrors the shared-types contract at
// `packages/shared-types/src/saved-products.ts`. The server emits camelCase
// keys for this resource (NestJS class-transformer default), so the Dart
// field names match 1:1 with the JSON wire format.
//
// Date fields stay as `String?` on the DTO. The screen layer parses /
// formats them on demand — eagerly converting to `DateTime` here would
// throw away the server's exact serialisation and complicate round-tripping.

/// Single saved-product row returned by `GET /api/v1/saved-products` and
/// `POST /api/v1/saved-products`.
@JsonSerializable(createToJson: false)
class SavedProductDto {
  const SavedProductDto({
    required this.id,
    required this.userId,
    required this.productName,
    required this.createdAt,
    required this.updatedAt,
    this.productId,
    this.barcode,
    this.expiresAt,
    this.markedConsumedAt,
    this.notes,
  });

  /// UUID of the saved-product row.
  final String id;

  /// UUID of the owning user.
  final String userId;

  /// Display name. 1..200 chars on the server side.
  final String productName;

  /// Optional reference to a `products.id` row when the user saved a
  /// product the catalog already knows about.
  final String? productId;

  /// Optional barcode (8..14 digits on the server side).
  final String? barcode;

  /// ISO date `YYYY-MM-DD`. `null` when no expiry was captured.
  final String? expiresAt;

  /// ISO datetime — set when the user marks the product as consumed.
  final String? markedConsumedAt;

  /// Free-form notes (≤500 chars on the server side).
  final String? notes;

  /// ISO datetime row was created.
  final String createdAt;

  /// ISO datetime row was last updated.
  final String updatedAt;

  factory SavedProductDto.fromJson(Map<String, dynamic> json) =>
      _$SavedProductDtoFromJson(json);
}

/// Response envelope for `GET /api/v1/saved-products?cursor=&limit=`.
///
/// Cursor pagination — `nextCursor` is `null` on the last page.
@JsonSerializable(createToJson: false)
class ListSavedProductsResponse {
  const ListSavedProductsResponse({
    required this.items,
    this.nextCursor,
  });

  final List<SavedProductDto> items;

  /// Opaque cursor pointing at the next page, or `null` when exhausted.
  final String? nextCursor;

  factory ListSavedProductsResponse.fromJson(Map<String, dynamic> json) =>
      _$ListSavedProductsResponseFromJson(json);
}

/// Body for `POST /api/v1/saved-products`. Optional fields are only
/// serialised when set so the server's `class-validator` `@IsOptional()`
/// fields aren't tripped by `null` literals.
@JsonSerializable(createFactory: false, includeIfNull: false)
class CreateSavedProductDto {
  const CreateSavedProductDto({
    required this.productName,
    this.productId,
    this.barcode,
    this.expiresAt,
    this.notes,
  });

  /// Display name. 1..200 chars (server-validated).
  final String productName;

  /// Optional reference to a `products.id` row.
  final String? productId;

  /// Optional barcode (8..14 digits server-validated).
  final String? barcode;

  /// ISO date `YYYY-MM-DD` (server-validated format).
  final String? expiresAt;

  /// Free-form notes (≤500 chars server-validated).
  final String? notes;

  Map<String, dynamic> toJson() => _$CreateSavedProductDtoToJson(this);
}

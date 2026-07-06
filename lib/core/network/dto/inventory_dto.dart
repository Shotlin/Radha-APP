import 'package:json_annotation/json_annotation.dart';

part 'inventory_dto.g.dart';

@JsonSerializable(createFactory: false)
class StockAdjustmentDto {
  const StockAdjustmentDto({
    required this.productId,
    required this.quantity,
    required this.type,
  });

  final String productId;
  final int quantity;
  final String type; // 'in' | 'out'

  Map<String, dynamic> toJson() => _$StockAdjustmentDtoToJson(this);
}

@JsonSerializable(createToJson: false)
class InventoryItemResponse {
  const InventoryItemResponse({
    required this.id,
    required this.productId,
    required this.quantity,
    this.lowStockThreshold,
  });

  final String id;
  final String productId;
  final int quantity;
  final int? lowStockThreshold;

  factory InventoryItemResponse.fromJson(Map<String, dynamic> json) =>
      _$InventoryItemResponseFromJson(json);
}

@JsonSerializable(createToJson: false, createFactory: false)
class PaginatedInventory {
  const PaginatedInventory({
    required this.items,
    required this.total,
    this.cursor,
  });

  final List<InventoryItemResponse> items;
  final int total;
  final String? cursor;

  /// The live backend's `PaginatedResult<T>` envelope is
  /// `{ data: T[], nextCursor: string | null, hasMore: boolean }` — not the
  /// `{items, total, cursor}` shape this DTO used to deserialize directly via
  /// json_serializable, which silently crashed every inventory list load.
  factory PaginatedInventory.fromJson(Map<String, dynamic> json) {
    final items = (json['data'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(InventoryItemResponse.fromJson)
        .toList(growable: false);
    return PaginatedInventory(
      items: items,
      total: json['total'] as int? ?? items.length,
      cursor: json['nextCursor'] as String?,
    );
  }
}

/// Store inventory roll-up from `GET /api/v1/inventory/summary`.
///
/// One cheap call that returns the headline counters the dashboard and home
/// KPIs need — no need to page through items and filter client-side. Hand-
/// written parser (no codegen) and tolerant: every counter defaults to 0 so a
/// partial server payload never throws.
class InventorySummaryResponse {
  const InventorySummaryResponse({
    required this.totalProducts,
    required this.totalQuantity,
    required this.lowStockCount,
    required this.expiringSoonCount,
    required this.expiredCount,
  });

  final int totalProducts;
  final int totalQuantity;
  final int lowStockCount;
  final int expiringSoonCount;
  final int expiredCount;

  factory InventorySummaryResponse.fromJson(Map<String, dynamic> json) {
    int asInt(Object? v) => v is num ? v.toInt() : 0;
    return InventorySummaryResponse(
      totalProducts: asInt(json['totalProducts']),
      totalQuantity: asInt(json['totalQuantity']),
      lowStockCount: asInt(json['lowStockCount']),
      expiringSoonCount: asInt(json['expiringSoonCount']),
      expiredCount: asInt(json['expiredCount']),
    );
  }
}

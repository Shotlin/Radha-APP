import 'package:json_annotation/json_annotation.dart';

part 'catalog_dto.g.dart';

/// Mirrors `server/.../dto/consumer-catalog.dto.ts`.
///
/// The consumer "browse-without-scan" surface: global-catalog categories and a
/// health-sorted, cursor-paginated product list. Health fields are null when a
/// product has no cached assessment yet — the client renders a neutral/unknown
/// state, never a fabricated rating.

/// A browsable global category (the "Top Categories" rail).
@JsonSerializable(createToJson: false)
class CatalogCategory {
  const CatalogCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final String slug;
  final int sortOrder;

  factory CatalogCategory.fromJson(Map<String, dynamic> json) =>
      _$CatalogCategoryFromJson(json);
}

/// One row in a catalog product list.
@JsonSerializable(createToJson: false)
class CatalogProductItem {
  const CatalogProductItem({
    required this.id,
    required this.ean,
    required this.name,
    this.brand,
    this.imageUrl,
    this.category,
    this.healthScore,
    this.healthGrade,
    this.healthStatus,
  });

  final String id;
  final String ean;
  final String name;
  final String? brand;
  final String? imageUrl;
  final String? category;

  /// 0..100 health score, or null when not yet assessed.
  final num? healthScore;

  /// Letter grade (A..E) when assessed.
  final String? healthGrade;

  /// 'green' | 'yellow' | 'red' style status when assessed.
  final String? healthStatus;

  factory CatalogProductItem.fromJson(Map<String, dynamic> json) =>
      _$CatalogProductItemFromJson(json);
}

/// Cursor-paginated catalog browse response.
@JsonSerializable(createToJson: false)
class CatalogBrowsePage {
  const CatalogBrowsePage({required this.items, this.nextCursor});

  final List<CatalogProductItem> items;
  final String? nextCursor;

  factory CatalogBrowsePage.fromJson(Map<String, dynamic> json) =>
      _$CatalogBrowsePageFromJson(json);
}

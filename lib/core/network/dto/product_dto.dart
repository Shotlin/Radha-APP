import 'package:json_annotation/json_annotation.dart';

part 'product_dto.g.dart';

@JsonSerializable(createToJson: false)
class ProductResponse {
  const ProductResponse({
    required this.id,
    required this.name,
    this.ean,
    this.brand,
    this.category,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String? ean;
  final String? brand;
  final String? category;
  final String? imageUrl;

  factory ProductResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class PaginatedProducts {
  const PaginatedProducts({
    required this.items,
    required this.total,
    this.cursor,
  });

  final List<ProductResponse> items;
  final int total;
  final String? cursor;

  factory PaginatedProducts.fromJson(Map<String, dynamic> json) =>
      _$PaginatedProductsFromJson(json);
}

@JsonSerializable(createFactory: false)
class CreateProductDto {
  const CreateProductDto({
    required this.name,
    this.ean,
    this.brand,
    this.category,
  });

  final String name;
  final String? ean;
  final String? brand;
  final String? category;

  Map<String, dynamic> toJson() => _$CreateProductDtoToJson(this);
}

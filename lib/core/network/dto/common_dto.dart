// Cross-cutting DTOs shared by every paginated endpoint group. Cursor +
// limit semantics match the backend's `(created_at desc, id desc)` cursor
// pagination convention.

/// Generic paginated envelope.
///
/// Retrofit needs a concrete `fromJson` for generics; we expose a static
/// helper factory and the generated client passes the inner type's
/// `fromJson` through.
class PaginatedDto<T> {
  const PaginatedDto({required this.items, this.nextCursor});

  final List<T> items;
  final String? nextCursor;

  factory PaginatedDto.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return PaginatedDto<T>(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => fromJsonT(e))
              .toList(growable: false) ??
          const [],
      nextCursor: json['nextCursor'] as String?,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) => {
    'items': items.map(toJsonT).toList(),
    if (nextCursor != null) 'nextCursor': nextCursor,
  };
}

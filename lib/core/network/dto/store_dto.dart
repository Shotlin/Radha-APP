import 'package:json_annotation/json_annotation.dart';

part 'store_dto.g.dart';

/// `GET /api/v1/stores/{storeId}` response. Only the fields the app
/// currently renders (Profile screen's store header) are modelled here —
/// extend as needed rather than mirroring the full backend row.
@JsonSerializable(createToJson: false)
class StoreResponse {
  const StoreResponse({
    required this.id,
    required this.name,
    this.shortCode,
  });

  final String id;
  final String name;

  /// Short, globally-unique, human-shareable store identifier (e.g.
  /// `Q7K2M9XT`) shown in place of the raw [id] UUID. Null for stores
  /// created before this field existed and not yet backfilled.
  final String? shortCode;

  factory StoreResponse.fromJson(Map<String, dynamic> json) =>
      _$StoreResponseFromJson(json);
}

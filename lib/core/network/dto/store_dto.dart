import 'package:json_annotation/json_annotation.dart';

part 'store_dto.g.dart';

/// One day's business hours. `open: false` means closed that day, in which
/// case [opensAt]/[closesAt] are null. Times are "HH:mm" 24h strings.
@JsonSerializable()
class DayHours {
  const DayHours({required this.open, this.opensAt, this.closesAt});

  final bool open;
  final String? opensAt;
  final String? closesAt;

  DayHours copyWith({bool? open, String? opensAt, String? closesAt}) {
    return DayHours(
      open: open ?? this.open,
      opensAt: opensAt ?? this.opensAt,
      closesAt: closesAt ?? this.closesAt,
    );
  }

  factory DayHours.fromJson(Map<String, dynamic> json) =>
      _$DayHoursFromJson(json);

  Map<String, dynamic> toJson() => _$DayHoursToJson(this);
}

const List<String> kBusinessHoursDays = [
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday',
];

/// `GET /api/v1/stores/{storeId}` response.
@JsonSerializable(createToJson: false)
class StoreResponse {
  const StoreResponse({
    required this.id,
    required this.name,
    this.shortCode,
    this.addressLine1,
    this.city,
    this.state,
    this.pincode,
    this.gstin,
    this.businessHours,
  });

  final String id;
  final String name;

  /// Short, globally-unique, human-shareable store identifier (e.g.
  /// `Q7K2M9XT`) shown in place of the raw [id] UUID. Null for stores
  /// created before this field existed and not yet backfilled.
  final String? shortCode;

  final String? addressLine1;
  final String? city;
  final String? state;
  final String? pincode;

  /// 15-char Indian GST identification number. Optional.
  final String? gstin;

  /// Keyed by lowercase day name (`monday`..`sunday`). Null until the
  /// owner configures it via the Store Details screen.
  final Map<String, DayHours>? businessHours;

  factory StoreResponse.fromJson(Map<String, dynamic> json) =>
      _$StoreResponseFromJson(json);
}

/// `PATCH /api/v1/stores/{storeId}` request body — Store Details screen.
/// Name + full address are mandatory (enforced by the backend's Zod
/// schema too); GSTIN and business hours are optional.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class UpdateStoreDto {
  const UpdateStoreDto({
    required this.name,
    required this.addressLine1,
    required this.city,
    required this.state,
    required this.pincode,
    this.gstin,
    this.businessHours,
  });

  final String name;
  final String addressLine1;
  final String city;
  final String state;
  final String pincode;
  final String? gstin;
  final Map<String, DayHours>? businessHours;

  Map<String, dynamic> toJson() => _$UpdateStoreDtoToJson(this);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DayHours _$DayHoursFromJson(Map<String, dynamic> json) => DayHours(
  open: json['open'] as bool,
  opensAt: json['opensAt'] as String?,
  closesAt: json['closesAt'] as String?,
);

Map<String, dynamic> _$DayHoursToJson(DayHours instance) => <String, dynamic>{
  'open': instance.open,
  'opensAt': instance.opensAt,
  'closesAt': instance.closesAt,
};

StoreResponse _$StoreResponseFromJson(Map<String, dynamic> json) =>
    StoreResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      shortCode: json['shortCode'] as String?,
      addressLine1: json['addressLine1'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      gstin: json['gstin'] as String?,
      businessHours: (json['businessHours'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, DayHours.fromJson(e as Map<String, dynamic>)),
      ),
    );

UpdateStoreDto _$UpdateStoreDtoFromJson(Map<String, dynamic> json) =>
    UpdateStoreDto(
      name: json['name'] as String,
      addressLine1: json['addressLine1'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      pincode: json['pincode'] as String,
      gstin: json['gstin'] as String?,
      businessHours: (json['businessHours'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, DayHours.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$UpdateStoreDtoToJson(UpdateStoreDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'addressLine1': instance.addressLine1,
      'city': instance.city,
      'state': instance.state,
      'pincode': instance.pincode,
      if (instance.gstin case final value?) 'gstin': value,
      if (instance.businessHours?.map((k, e) => MapEntry(k, e.toJson()))
          case final value?)
        'businessHours': value,
    };

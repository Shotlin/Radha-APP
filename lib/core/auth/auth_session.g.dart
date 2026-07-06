// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthSessionImpl _$$AuthSessionImplFromJson(Map<String, dynamic> json) =>
    _$AuthSessionImpl(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      userId: json['userId'] as String,
      tenantId: json['tenantId'] as String?,
      roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
      stores: (json['stores'] as List<dynamic>)
          .map((e) => StoreAccess.fromJson(e as Map<String, dynamic>))
          .toList(),
      selectedStoreId: json['selectedStoreId'] as String?,
    );

Map<String, dynamic> _$$AuthSessionImplToJson(_$AuthSessionImpl instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'userId': instance.userId,
      'tenantId': instance.tenantId,
      'roles': instance.roles,
      'stores': instance.stores.map((e) => e.toJson()).toList(),
      'selectedStoreId': instance.selectedStoreId,
    };

_$StoreAccessImpl _$$StoreAccessImplFromJson(Map<String, dynamic> json) =>
    _$StoreAccessImpl(
      storeId: json['storeId'] as String,
      storeName: json['storeName'] as String,
      role: json['role'] as String,
    );

Map<String, dynamic> _$$StoreAccessImplToJson(_$StoreAccessImpl instance) =>
    <String, dynamic>{
      'storeId': instance.storeId,
      'storeName': instance.storeName,
      'role': instance.role,
    };

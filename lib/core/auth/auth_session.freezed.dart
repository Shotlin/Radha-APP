// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AuthSession _$AuthSessionFromJson(Map<String, dynamic> json) {
  return _AuthSession.fromJson(json);
}

/// @nodoc
mixin _$AuthSession {
  String get accessToken => throw _privateConstructorUsedError;
  String get refreshToken => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get tenantId => throw _privateConstructorUsedError;
  List<String> get roles => throw _privateConstructorUsedError;
  List<StoreAccess> get stores => throw _privateConstructorUsedError;
  String? get selectedStoreId => throw _privateConstructorUsedError;

  /// Serializes this AuthSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthSessionCopyWith<AuthSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthSessionCopyWith<$Res> {
  factory $AuthSessionCopyWith(
    AuthSession value,
    $Res Function(AuthSession) then,
  ) = _$AuthSessionCopyWithImpl<$Res, AuthSession>;
  @useResult
  $Res call({
    String accessToken,
    String refreshToken,
    String userId,
    String? tenantId,
    List<String> roles,
    List<StoreAccess> stores,
    String? selectedStoreId,
  });
}

/// @nodoc
class _$AuthSessionCopyWithImpl<$Res, $Val extends AuthSession>
    implements $AuthSessionCopyWith<$Res> {
  _$AuthSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? userId = null,
    Object? tenantId = freezed,
    Object? roles = null,
    Object? stores = null,
    Object? selectedStoreId = freezed,
  }) {
    return _then(
      _value.copyWith(
            accessToken: null == accessToken
                ? _value.accessToken
                : accessToken // ignore: cast_nullable_to_non_nullable
                      as String,
            refreshToken: null == refreshToken
                ? _value.refreshToken
                : refreshToken // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            tenantId: freezed == tenantId
                ? _value.tenantId
                : tenantId // ignore: cast_nullable_to_non_nullable
                      as String?,
            roles: null == roles
                ? _value.roles
                : roles // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            stores: null == stores
                ? _value.stores
                : stores // ignore: cast_nullable_to_non_nullable
                      as List<StoreAccess>,
            selectedStoreId: freezed == selectedStoreId
                ? _value.selectedStoreId
                : selectedStoreId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AuthSessionImplCopyWith<$Res>
    implements $AuthSessionCopyWith<$Res> {
  factory _$$AuthSessionImplCopyWith(
    _$AuthSessionImpl value,
    $Res Function(_$AuthSessionImpl) then,
  ) = __$$AuthSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String accessToken,
    String refreshToken,
    String userId,
    String? tenantId,
    List<String> roles,
    List<StoreAccess> stores,
    String? selectedStoreId,
  });
}

/// @nodoc
class __$$AuthSessionImplCopyWithImpl<$Res>
    extends _$AuthSessionCopyWithImpl<$Res, _$AuthSessionImpl>
    implements _$$AuthSessionImplCopyWith<$Res> {
  __$$AuthSessionImplCopyWithImpl(
    _$AuthSessionImpl _value,
    $Res Function(_$AuthSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? userId = null,
    Object? tenantId = freezed,
    Object? roles = null,
    Object? stores = null,
    Object? selectedStoreId = freezed,
  }) {
    return _then(
      _$AuthSessionImpl(
        accessToken: null == accessToken
            ? _value.accessToken
            : accessToken // ignore: cast_nullable_to_non_nullable
                  as String,
        refreshToken: null == refreshToken
            ? _value.refreshToken
            : refreshToken // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        tenantId: freezed == tenantId
            ? _value.tenantId
            : tenantId // ignore: cast_nullable_to_non_nullable
                  as String?,
        roles: null == roles
            ? _value._roles
            : roles // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        stores: null == stores
            ? _value._stores
            : stores // ignore: cast_nullable_to_non_nullable
                  as List<StoreAccess>,
        selectedStoreId: freezed == selectedStoreId
            ? _value.selectedStoreId
            : selectedStoreId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthSessionImpl implements _AuthSession {
  const _$AuthSessionImpl({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    this.tenantId,
    required final List<String> roles,
    required final List<StoreAccess> stores,
    this.selectedStoreId,
  }) : _roles = roles,
       _stores = stores;

  factory _$AuthSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthSessionImplFromJson(json);

  @override
  final String accessToken;
  @override
  final String refreshToken;
  @override
  final String userId;
  @override
  final String? tenantId;
  final List<String> _roles;
  @override
  List<String> get roles {
    if (_roles is EqualUnmodifiableListView) return _roles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_roles);
  }

  final List<StoreAccess> _stores;
  @override
  List<StoreAccess> get stores {
    if (_stores is EqualUnmodifiableListView) return _stores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stores);
  }

  @override
  final String? selectedStoreId;

  @override
  String toString() {
    return 'AuthSession(accessToken: $accessToken, refreshToken: $refreshToken, userId: $userId, tenantId: $tenantId, roles: $roles, stores: $stores, selectedStoreId: $selectedStoreId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthSessionImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            const DeepCollectionEquality().equals(other._roles, _roles) &&
            const DeepCollectionEquality().equals(other._stores, _stores) &&
            (identical(other.selectedStoreId, selectedStoreId) ||
                other.selectedStoreId == selectedStoreId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    accessToken,
    refreshToken,
    userId,
    tenantId,
    const DeepCollectionEquality().hash(_roles),
    const DeepCollectionEquality().hash(_stores),
    selectedStoreId,
  );

  /// Create a copy of AuthSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthSessionImplCopyWith<_$AuthSessionImpl> get copyWith =>
      __$$AuthSessionImplCopyWithImpl<_$AuthSessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthSessionImplToJson(this);
  }
}

abstract class _AuthSession implements AuthSession {
  const factory _AuthSession({
    required final String accessToken,
    required final String refreshToken,
    required final String userId,
    final String? tenantId,
    required final List<String> roles,
    required final List<StoreAccess> stores,
    final String? selectedStoreId,
  }) = _$AuthSessionImpl;

  factory _AuthSession.fromJson(Map<String, dynamic> json) =
      _$AuthSessionImpl.fromJson;

  @override
  String get accessToken;
  @override
  String get refreshToken;
  @override
  String get userId;
  @override
  String? get tenantId;
  @override
  List<String> get roles;
  @override
  List<StoreAccess> get stores;
  @override
  String? get selectedStoreId;

  /// Create a copy of AuthSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthSessionImplCopyWith<_$AuthSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StoreAccess _$StoreAccessFromJson(Map<String, dynamic> json) {
  return _StoreAccess.fromJson(json);
}

/// @nodoc
mixin _$StoreAccess {
  String get storeId => throw _privateConstructorUsedError;
  String get storeName => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;

  /// Serializes this StoreAccess to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StoreAccess
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StoreAccessCopyWith<StoreAccess> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoreAccessCopyWith<$Res> {
  factory $StoreAccessCopyWith(
    StoreAccess value,
    $Res Function(StoreAccess) then,
  ) = _$StoreAccessCopyWithImpl<$Res, StoreAccess>;
  @useResult
  $Res call({String storeId, String storeName, String role});
}

/// @nodoc
class _$StoreAccessCopyWithImpl<$Res, $Val extends StoreAccess>
    implements $StoreAccessCopyWith<$Res> {
  _$StoreAccessCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StoreAccess
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? storeId = null,
    Object? storeName = null,
    Object? role = null,
  }) {
    return _then(
      _value.copyWith(
            storeId: null == storeId
                ? _value.storeId
                : storeId // ignore: cast_nullable_to_non_nullable
                      as String,
            storeName: null == storeName
                ? _value.storeName
                : storeName // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StoreAccessImplCopyWith<$Res>
    implements $StoreAccessCopyWith<$Res> {
  factory _$$StoreAccessImplCopyWith(
    _$StoreAccessImpl value,
    $Res Function(_$StoreAccessImpl) then,
  ) = __$$StoreAccessImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String storeId, String storeName, String role});
}

/// @nodoc
class __$$StoreAccessImplCopyWithImpl<$Res>
    extends _$StoreAccessCopyWithImpl<$Res, _$StoreAccessImpl>
    implements _$$StoreAccessImplCopyWith<$Res> {
  __$$StoreAccessImplCopyWithImpl(
    _$StoreAccessImpl _value,
    $Res Function(_$StoreAccessImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StoreAccess
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? storeId = null,
    Object? storeName = null,
    Object? role = null,
  }) {
    return _then(
      _$StoreAccessImpl(
        storeId: null == storeId
            ? _value.storeId
            : storeId // ignore: cast_nullable_to_non_nullable
                  as String,
        storeName: null == storeName
            ? _value.storeName
            : storeName // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StoreAccessImpl implements _StoreAccess {
  const _$StoreAccessImpl({
    required this.storeId,
    required this.storeName,
    required this.role,
  });

  factory _$StoreAccessImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoreAccessImplFromJson(json);

  @override
  final String storeId;
  @override
  final String storeName;
  @override
  final String role;

  @override
  String toString() {
    return 'StoreAccess(storeId: $storeId, storeName: $storeName, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoreAccessImpl &&
            (identical(other.storeId, storeId) || other.storeId == storeId) &&
            (identical(other.storeName, storeName) ||
                other.storeName == storeName) &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, storeId, storeName, role);

  /// Create a copy of StoreAccess
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StoreAccessImplCopyWith<_$StoreAccessImpl> get copyWith =>
      __$$StoreAccessImplCopyWithImpl<_$StoreAccessImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoreAccessImplToJson(this);
  }
}

abstract class _StoreAccess implements StoreAccess {
  const factory _StoreAccess({
    required final String storeId,
    required final String storeName,
    required final String role,
  }) = _$StoreAccessImpl;

  factory _StoreAccess.fromJson(Map<String, dynamic> json) =
      _$StoreAccessImpl.fromJson;

  @override
  String get storeId;
  @override
  String get storeName;
  @override
  String get role;

  /// Create a copy of StoreAccess
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoreAccessImplCopyWith<_$StoreAccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

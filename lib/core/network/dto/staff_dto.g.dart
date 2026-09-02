// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserLookupResponse _$UserLookupResponseFromJson(Map<String, dynamic> json) =>
    UserLookupResponse(
      exists: json['exists'] as bool,
      userId: json['userId'] as String?,
      displayName: json['displayName'] as String?,
      alreadyMember: json['alreadyMember'] as bool?,
    );

StaffMemberResponse _$StaffMemberResponseFromJson(Map<String, dynamic> json) =>
    StaffMemberResponse(
      userId: json['userId'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      mobile: json['mobile'] as String?,
      role: json['role'] as String,
      accessLevel: json['accessLevel'] as String,
    );

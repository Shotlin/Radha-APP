import 'package:json_annotation/json_annotation.dart';

part 'staff_dto.g.dart';

/// `GET /api/v1/stores/{storeId}/access/lookup-user?email=` response —
/// the staff invite sheet's live "does this email match an existing
/// user" checkmark.
@JsonSerializable(createToJson: false)
class UserLookupResponse {
  const UserLookupResponse({
    required this.exists,
    this.userId,
    this.displayName,
    this.alreadyMember,
  });

  final bool exists;
  final String? userId;
  final String? displayName;
  final bool? alreadyMember;

  factory UserLookupResponse.fromJson(Map<String, dynamic> json) =>
      _$UserLookupResponseFromJson(json);
}

/// One row of `GET /api/v1/stores/{storeId}/access` — the Staff & roles
/// team list and the Create Task assignee picker.
@JsonSerializable(createToJson: false)
class StaffMemberResponse {
  const StaffMemberResponse({
    required this.userId,
    this.name,
    this.email,
    this.mobile,
    required this.role,
    required this.accessLevel,
  });

  final String userId;
  final String? name;
  final String? email;
  final String? mobile;
  final String role;
  final String accessLevel;

  factory StaffMemberResponse.fromJson(Map<String, dynamic> json) =>
      _$StaffMemberResponseFromJson(json);
}

// Referral DTOs — projection of `/referrals/*`.

class ReferralStatusDto {
  const ReferralStatusDto({
    required this.code,
    required this.invites,
    required this.successfulInvites,
    this.rewardCredits,
    this.expiresAt,
  });

  final String code;
  final int invites;
  final int successfulInvites;
  final int? rewardCredits;
  final DateTime? expiresAt;

  factory ReferralStatusDto.fromJson(Map<String, dynamic> json) =>
      ReferralStatusDto(
        code: json['code'] as String,
        invites: (json['invites'] as num).toInt(),
        successfulInvites: (json['successfulInvites'] as num).toInt(),
        rewardCredits: (json['rewardCredits'] as num?)?.toInt(),
        expiresAt: json['expiresAt'] == null
            ? null
            : DateTime.parse(json['expiresAt'] as String),
      );

  Map<String, dynamic> toJson() => {
    'code': code,
    'invites': invites,
    'successfulInvites': successfulInvites,
    if (rewardCredits != null) 'rewardCredits': rewardCredits,
    if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
  };
}

class RedeemReferralRequest {
  const RedeemReferralRequest({required this.code});
  final String code;
  Map<String, dynamic> toJson() => {'code': code};
}

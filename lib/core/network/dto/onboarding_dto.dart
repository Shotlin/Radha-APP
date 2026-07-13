// BE-34 — Onboarding self-selection DTOs.
//
// Mirrors the server contract at `server/src/modules/onboarding/`:
//
//   POST /api/v1/onboarding/segment
//     body  : { segment: 'personal' | 'parent' | 'business_owner' |
//                        'pharmacy' | 'institution' | 'auditor_invited' }
//     auth  : JwtAuthGuard (must be authenticated)
//     return: OnboardingRoutingDto — { segment, nextScreen,
//                                      presetForBusinessActivation?,
//                                      bypassedOnboarding }
//
// Wire values are snake_case (backend Zod enum); Dart enums are camelCase.
// `wireValue` is the canonical way to flatten an enum to its backend string,
// used both by the codegen path (via `@JsonValue`) and by callers that need
// to persist the value directly to secure storage.

import 'package:json_annotation/json_annotation.dart';

part 'onboarding_dto.g.dart';

/// Six possible self-selected onboarding segments. Order matches the
/// 2×3 tap-card grid rendered on Page 3 of the onboarding flow.
enum OnboardingSegmentDto {
  @JsonValue('personal')
  personal,
  @JsonValue('parent')
  parent,
  @JsonValue('business_owner')
  businessOwner,
  @JsonValue('pharmacy')
  pharmacy,
  @JsonValue('institution')
  institution,
  @JsonValue('auditor_invited')
  auditorInvited,
}

/// Snake-case backend wire value for a [OnboardingSegmentDto], e.g.
/// `business_owner`. Stable contract — also persisted to secure storage as
/// the `pending_onboarding_segment` value, so screen code can re-hydrate it
/// after login (Task 7).
extension OnboardingSegmentDtoWire on OnboardingSegmentDto {
  String get wireValue {
    switch (this) {
      case OnboardingSegmentDto.personal:
        return 'personal';
      case OnboardingSegmentDto.parent:
        return 'parent';
      case OnboardingSegmentDto.businessOwner:
        return 'business_owner';
      case OnboardingSegmentDto.pharmacy:
        return 'pharmacy';
      case OnboardingSegmentDto.institution:
        return 'institution';
      case OnboardingSegmentDto.auditorInvited:
        return 'auditor_invited';
    }
  }
}

/// Inverse of [OnboardingSegmentDtoWire.wireValue] — returns `null` when the
/// stored string is unknown (e.g. the backend introduced a new segment that
/// this client doesn't understand yet).
OnboardingSegmentDto? onboardingSegmentDtoFromWire(String? wire) {
  if (wire == null) return null;
  for (final s in OnboardingSegmentDto.values) {
    if (s.wireValue == wire) return s;
  }
  return null;
}

/// Possible `nextScreen` routing targets returned by the backend.
enum OnboardingNextScreenDto {
  @JsonValue('consumer_home')
  consumerHome,
  @JsonValue('consumer_home_with_allergen_setup')
  consumerHomeWithAllergenSetup,
  @JsonValue('business_activation_flow')
  businessActivationFlow,
  @JsonValue('auditor_invitation_token_entry')
  auditorInvitationTokenEntry,
}

/// `presetForBusinessActivation` field — only sent for the three B2B segments.
enum BusinessActivationPresetDto {
  @JsonValue('business_owner')
  businessOwner,
  @JsonValue('pharmacy')
  pharmacy,
  @JsonValue('institution')
  institution,
}

/// Request body for `POST /api/v1/account/activate-business`.
@JsonSerializable(createFactory: false, includeIfNull: false)
class ActivateBusinessRequest {
  const ActivateBusinessRequest({
    required this.businessName,
    required this.storeName,
    required this.acceptTrialPro,
    this.storeCity,
    this.storePincode,
    this.preset,
  });

  final String businessName;
  final String storeName;
  final bool acceptTrialPro;
  final String? storeCity;
  final String? storePincode;
  final BusinessActivationPresetDto? preset;

  Map<String, dynamic> toJson() => _$ActivateBusinessRequestToJson(this);
}

/// Request body for `POST /api/v1/onboarding/segment`.
@JsonSerializable(createFactory: false)
class SelectSegmentRequestDto {
  const SelectSegmentRequestDto({required this.segment});

  final OnboardingSegmentDto segment;

  Map<String, dynamic> toJson() => _$SelectSegmentRequestDtoToJson(this);
}

/// Response payload for `POST /api/v1/onboarding/segment` — i.e. the
/// `OnboardingRoutingDto` shape on the backend.
@JsonSerializable(createToJson: false)
class OnboardingRoutingResponse {
  const OnboardingRoutingResponse({
    required this.segment,
    required this.nextScreen,
    required this.bypassedOnboarding,
    this.presetForBusinessActivation,
  });

  final OnboardingSegmentDto segment;
  final OnboardingNextScreenDto nextScreen;
  final BusinessActivationPresetDto? presetForBusinessActivation;
  final bool bypassedOnboarding;

  factory OnboardingRoutingResponse.fromJson(Map<String, dynamic> json) =>
      _$OnboardingRoutingResponseFromJson(json);
}

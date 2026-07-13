// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$ActivateBusinessRequestToJson(
  ActivateBusinessRequest instance,
) => <String, dynamic>{
  'businessName': instance.businessName,
  'storeName': instance.storeName,
  'acceptTrialPro': instance.acceptTrialPro,
  if (instance.storeCity case final value?) 'storeCity': value,
  if (instance.storePincode case final value?) 'storePincode': value,
  if (_$BusinessActivationPresetDtoEnumMap[instance.preset] case final value?)
    'preset': value,
};

const _$BusinessActivationPresetDtoEnumMap = {
  BusinessActivationPresetDto.businessOwner: 'business_owner',
  BusinessActivationPresetDto.pharmacy: 'pharmacy',
  BusinessActivationPresetDto.institution: 'institution',
};

Map<String, dynamic> _$SelectSegmentRequestDtoToJson(
  SelectSegmentRequestDto instance,
) => <String, dynamic>{
  'segment': _$OnboardingSegmentDtoEnumMap[instance.segment]!,
};

const _$OnboardingSegmentDtoEnumMap = {
  OnboardingSegmentDto.personal: 'personal',
  OnboardingSegmentDto.parent: 'parent',
  OnboardingSegmentDto.businessOwner: 'business_owner',
  OnboardingSegmentDto.pharmacy: 'pharmacy',
  OnboardingSegmentDto.institution: 'institution',
  OnboardingSegmentDto.auditorInvited: 'auditor_invited',
};

OnboardingRoutingResponse _$OnboardingRoutingResponseFromJson(
  Map<String, dynamic> json,
) => OnboardingRoutingResponse(
  segment: $enumDecode(_$OnboardingSegmentDtoEnumMap, json['segment']),
  nextScreen: $enumDecode(_$OnboardingNextScreenDtoEnumMap, json['nextScreen']),
  bypassedOnboarding: json['bypassedOnboarding'] as bool,
  presetForBusinessActivation: $enumDecodeNullable(
    _$BusinessActivationPresetDtoEnumMap,
    json['presetForBusinessActivation'],
  ),
);

const _$OnboardingNextScreenDtoEnumMap = {
  OnboardingNextScreenDto.consumerHome: 'consumer_home',
  OnboardingNextScreenDto.consumerHomeWithAllergenSetup:
      'consumer_home_with_allergen_setup',
  OnboardingNextScreenDto.businessActivationFlow: 'business_activation_flow',
  OnboardingNextScreenDto.auditorInvitationTokenEntry:
      'auditor_invitation_token_entry',
};

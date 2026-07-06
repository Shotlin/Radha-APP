// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$CreateCheckoutDtoToJson(CreateCheckoutDto instance) =>
    <String, dynamic>{
      'planId': instance.planId,
      'billingCycle': instance.billingCycle,
      'packType': instance.packType,
    };

CheckoutPrefill _$CheckoutPrefillFromJson(Map<String, dynamic> json) =>
    CheckoutPrefill(
      name: json['name'] as String?,
      email: json['email'] as String?,
      contact: json['contact'] as String?,
    );

CheckoutResponse _$CheckoutResponseFromJson(Map<String, dynamic> json) =>
    CheckoutResponse(
      razorpayOrderId: json['razorpayOrderId'] as String,
      keyId: json['keyId'] as String,
      amountPaise: (json['amountPaise'] as num).toInt(),
      currency: json['currency'] as String,
      prefill: CheckoutPrefill.fromJson(
        json['prefill'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$VerifyPaymentDtoToJson(VerifyPaymentDto instance) =>
    <String, dynamic>{
      'razorpayOrderId': instance.razorpayOrderId,
      'razorpayPaymentId': instance.razorpayPaymentId,
      'razorpaySignature': instance.razorpaySignature,
    };

VerifyPaymentResponse _$VerifyPaymentResponseFromJson(
  Map<String, dynamic> json,
) => VerifyPaymentResponse(
  success: json['success'] as bool,
  subscriptionStatus: json['subscriptionStatus'] as String,
);

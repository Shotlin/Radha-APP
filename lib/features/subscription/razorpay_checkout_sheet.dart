// Razorpay Standard Checkout entrypoint.
//
// Opens the native Razorpay sheet for a plan upgrade and resolves to `true`
// only once the server has verified the payment signature. The public
// signature is consumed by subscription_screen.dart and must stay stable:
//
//   Future<bool> openRazorpayCheckout({ context, ref, planId, billingCycle })
//
// Flow:
//   1. POST /payments/checkout  → CheckoutResponse (order id, key, amount, prefill)
//   2. Razorpay().open(options) → native sheet, await one terminal event
//   3. on success  → POST /payments/verify → bool from VerifyPaymentResponse
//      on error / external wallet → false
// The Razorpay instance is always cleared/disposed before returning.
//
// SECURITY: the Razorpay Key ID is supplied by the server in the checkout
// response (`checkout.keyId`) — it is never compiled into the app, and the
// Key *Secret* lives only on the server (it signs order creation + verifies
// the payment signature). Rotating keys is a server-only env change.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../core/network/api_client.dart';
import '../../core/network/dto/payment_dto.dart';
import '../../l10n/generated/app_localizations.dart';

Future<bool> openRazorpayCheckout({
  required BuildContext context,
  required WidgetRef ref,
  required String planId,
  required String billingCycle,
  String packType = 'monthly',
}) async {
  final api = ref.read(apiClientProvider);
  final messenger = ScaffoldMessenger.maybeOf(context);
  // Capture localizations before any async gap so we never touch a stale
  // context across awaits.
  final l10n = AppLocalizations.of(context);

  // 1. Ask the server to create the Razorpay order and hand back the metadata
  //    the native sheet needs.
  CheckoutResponse checkout;
  try {
    checkout = await api.createCheckout(
      CreateCheckoutDto(
        planId: planId,
        billingCycle: billingCycle,
        packType: packType,
      ),
    );
  } catch (_) {
    messenger?.showSnackBar(
      SnackBar(content: Text(l10n.checkoutStartError)),
    );
    return false;
  }

  // 2. Drive the native sheet. A Completer lets us await the (callback-based)
  //    Razorpay events as if they were a Future.
  final razorpay = Razorpay();
  final completer = Completer<bool>();

  void finish(bool result) {
    if (!completer.isCompleted) completer.complete(result);
  }

  Future<void> handleSuccess(PaymentSuccessResponse response) async {
    final orderId = response.orderId;
    final paymentId = response.paymentId;
    final signature = response.signature;
    if (orderId == null || paymentId == null || signature == null) {
      messenger?.showSnackBar(
        SnackBar(content: Text(l10n.paymentResponseIncomplete)),
      );
      finish(false);
      return;
    }
    try {
      final verification = await api.verifyPayment(
        VerifyPaymentDto(
          razorpayOrderId: orderId,
          razorpayPaymentId: paymentId,
          razorpaySignature: signature,
        ),
      );
      if (verification.success) {
        messenger?.showSnackBar(
          SnackBar(content: Text(l10n.paymentSuccessUpdated)),
        );
        finish(true);
      } else {
        messenger?.showSnackBar(
          SnackBar(content: Text(l10n.paymentNotVerified)),
        );
        finish(false);
      }
    } catch (_) {
      messenger?.showSnackBar(
        SnackBar(content: Text(l10n.paymentVerifyFailed)),
      );
      finish(false);
    }
  }

  void handleError(PaymentFailureResponse response) {
    final message = response.message?.trim();
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          message == null || message.isEmpty
              ? l10n.paymentCancelled
              : l10n.paymentFailed(message),
        ),
      ),
    );
    finish(false);
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    // External wallet selection is not a completed payment on its own — the
    // SDK still fires success/error afterwards, but we surface the choice and
    // treat the standalone event as non-success.
    final wallet = response.walletName;
    if (wallet != null && wallet.isNotEmpty) {
      messenger?.showSnackBar(
        SnackBar(content: Text(l10n.paymentOpeningWallet(wallet))),
      );
    }
    finish(false);
  }

  razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handleSuccess);
  razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handleError);
  razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);

  final prefill = <String, dynamic>{
    if (checkout.prefill.name != null) 'name': checkout.prefill.name,
    if (checkout.prefill.email != null) 'email': checkout.prefill.email,
    if (checkout.prefill.contact != null) 'contact': checkout.prefill.contact,
  };

  final options = <String, dynamic>{
    'key': checkout.keyId,
    'order_id': checkout.razorpayOrderId,
    'amount': checkout.amountPaise,
    'currency': checkout.currency,
    'name': 'RADHA',
    'description': packType == 'day_pass'
        ? '1-Day Pass · $planId'
        : 'Subscription · $planId ($billingCycle)',
    if (prefill.isNotEmpty) 'prefill': prefill,
  };

  try {
    razorpay.open(options);
  } catch (_) {
    messenger?.showSnackBar(
      SnackBar(content: Text(l10n.paymentSheetOpenError)),
    );
    finish(false);
  }

  try {
    return await completer.future;
  } finally {
    razorpay.clear();
  }
}

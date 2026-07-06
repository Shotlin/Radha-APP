// Subscription service.
//
// Central coordinator for plan resolution and checkout preparation. Keeps
// all plan-ID and billing-cycle logic out of UI widgets so the screen only
// needs to call [SubscriptionService.billingCycleLabel] and pass the result
// to openRazorpayCheckout.
//
// TODO(razorpay): once RAZORPAY_*_PLAN_ID dart-define values are populated,
// use [razorpayPlanId] to verify plan IDs are set before opening checkout.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../config/razorpay_config.dart';
import '../models/plan_model.dart';

class SubscriptionService {
  SubscriptionService._();

  /// All plans shown in the Monthly Plans view.
  static List<SubscriptionPlan> get monthlyPlans => kRadhaPlans;

  /// Plans that offer a 1-Day Pass (subset of [monthlyPlans]).
  static List<SubscriptionPlan> get dayPassPlans =>
      kRadhaPlans.where((p) => p.hasDayPass).toList();

  /// Resolves the Razorpay plan ID for [plan] at [period].
  /// Returns empty string until RAZORPAY_*_PLAN_ID dart-define values are set.
  static String razorpayPlanId(SubscriptionPlan plan, BillingPeriod period) =>
      RazorpayConfig.planIdFor(plan.idFor(period));

  /// Billing cycle string expected by the backend CreateCheckoutDto.
  /// The backend's `CheckoutSchema.billingCycle` only accepts
  /// `'monthly' | 'yearly'` — day-passes are distinguished by `packType`,
  /// not by this field. Once yearly plans exist, branch here; today every
  /// purchase (monthly or day-pass) sends `'monthly'` and the backend
  /// ignores this field entirely once `packType == 'day_pass'` (see
  /// `PaymentsService.createCheckout`'s pricing branch).
  static String billingCycleLabel() => 'monthly';

  /// packType string expected by the backend CreateCheckoutDto.
  static String packTypeLabel(BillingPeriod period) =>
      period == BillingPeriod.monthly ? 'monthly' : 'day_pass';
}

/// Maps a backend plan *code* (`'starter'`/`'growth'`/`'pro'`) to its real
/// UUID from `GET /subscriptions/plans` — the only value the checkout
/// endpoint accepts for `planId` (it's `@IsUUID`-validated server-side).
/// `kRadhaPlans[i].id` is a plan code, not a UUID, so every checkout call
/// must resolve through this map first. Cached for the provider's lifetime;
/// a subscription-screen visit is the only place that reads it.
final subscriptionPlanIdMapProvider = FutureProvider<Map<String, String>>((
  ref,
) async {
  final api = ref.watch(apiClientProvider);
  final plans = await api.getSubscriptionPlans();
  return {for (final p in plans) p.code: p.id};
});

// Subscription plan data model.
//
// Single source of truth for all plan metadata — pricing, highlights, and
// day-pass availability. Both the monthly and 1-day-pass views read from
// [kRadhaPlans]. To change a price or add a plan, edit this file only.

import 'package:flutter/foundation.dart';

/// Whether the user is buying a recurring monthly plan or a one-time day pass.
enum BillingPeriod { monthly, day }

/// A single subscription tier offered to users.
///
/// Holds pricing for both billing periods so one object drives both the
/// Monthly Plans and 1-Day Passes views. Plans without a [dayPrice] are
/// month-only and do not appear in the day-pass list.
@immutable
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.displayName,
    required this.tagline,
    required this.monthlyPrice,
    required this.highlights,
    this.dayPrice,
    this.isPopular = false,
  });

  /// Backend plan code — must match the server's subscription_plans seed.
  final String id;

  final String displayName;
  final String tagline;

  /// Recurring price in ₹ per month.
  final int monthlyPrice;

  /// One-time price in ₹ for a 24-hour pass. Null = no day pass for this tier.
  final int? dayPrice;

  final List<String> highlights;

  /// Whether this plan carries the "Popular" badge.
  final bool isPopular;

  bool get hasDayPass => dayPrice != null;

  /// App-level plan ID used in checkout requests for 24-hour passes.
  String get dayPassId => '${id}_day';

  String get dayPassDisplayName => '$displayName Day Pass';

  /// Resolves the price for the given billing period.
  int priceFor(BillingPeriod period) =>
      period == BillingPeriod.day && dayPrice != null ? dayPrice! : monthlyPrice;

  /// Resolves the plan ID to send in the checkout request.
  String idFor(BillingPeriod period) =>
      period == BillingPeriod.day ? dayPassId : id;

  /// Finds a plan by its monthly [id] or its [dayPassId].
  /// Returns null for 'trial' and other server-only plan codes.
  static SubscriptionPlan? findById(String planId) {
    for (final plan in kRadhaPlans) {
      if (plan.id == planId || plan.dayPassId == planId) return plan;
    }
    return null;
  }
}

/// Master plan catalogue. Order determines display order on the subscription
/// screen. Prices are in ₹ — change them here only; all UI reads from this list.
const List<SubscriptionPlan> kRadhaPlans = [
  SubscriptionPlan(
    id: 'starter',
    displayName: 'Starter',
    tagline: 'Scan, health & expiry',
    monthlyPrice: 49,
    dayPrice: 3,
    highlights: ['Inventory management', 'Unlimited scans'],
  ),
  SubscriptionPlan(
    id: 'growth',
    displayName: 'Growth',
    tagline: '+ Inventory & tasks',
    monthlyPrice: 99,
    dayPrice: 5,
    highlights: [
      'Everything in Starter',
      'GRN inward',
      'Advanced reports',
      'Bulk scan',
    ],
    isPopular: true,
  ),
  SubscriptionPlan(
    id: 'growth_plus',
    displayName: 'Growth Plus',
    tagline: '+ Alerts & multi-store',
    monthlyPrice: 149,
    highlights: [
      'Everything in Growth',
      'Allergen & recall alerts',
      'Multi-store management',
    ],
  ),
  SubscriptionPlan(
    id: 'pro',
    displayName: 'Premium',
    tagline: '+ Weekly digest & priority support',
    monthlyPrice: 199,
    dayPrice: 9,
    highlights: [
      'Everything in Growth Plus',
      'Weekly store digest',
      'All future features',
    ],
  ),
];

// Subscription entitlement provider.
//
// Fetches the tenant's subscription status from the backend and exposes
// helpers to check feature access and usage limits. All feature-gating
// in the app reads from this provider — no ad-hoc permission logic.

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mode/app_mode_provider.dart';
import '../network/api_client.dart';
import '../network/dto/subscription_dto.dart';

// ─── Domain types ─────────────────────────────────────────────────────────

/// Features that can be gated by subscription plan.
enum Feature {
  advancedReports,
  inventory,
  grn,
  allergenProfile,
  recallAlerts,
  weeklyDigest,
  healthyAlternatives,
  ingredientExplainer,
  bulkScan,
  multiStore,
}

/// Billing cadence for a subscription.
enum BillingCycle { monthly, yearly }

/// Usage info for metered features (current usage vs limit).
class UsageInfo {
  const UsageInfo({required this.current, required this.limit});
  final int current;
  final int limit;

  bool get exceeded => current >= limit;
  double get ratio => limit > 0 ? current / limit : 0;
}

/// Immutable snapshot of the tenant's entitlement state.
class EntitlementState {
  const EntitlementState({
    required this.planId,
    required this.billingCycle,
    required this.features,
    this.trialDaysRemaining,
    this.usage = const {},
  });

  final String planId;
  final int? trialDaysRemaining;
  final BillingCycle billingCycle;
  final Set<Feature> features;
  final Map<Feature, UsageInfo> usage;
}

// ─── Plan definitions ─────────────────────────────────────────────────────

/// Which features each plan includes. Free gets none of the gated features
/// (scan + product info are never gated); the 90-day trial gets everything.
///
/// Keyed by the real backend plan codes (`trial`/`starter`/`growth`/`pro`,
/// see `subscription_plans` seed) rather than the old placeholder names
/// (`free_trial`/`basic`/`standard`/`premium`) those codes never actually
/// matched, which silently resolved every real account to zero features.
/// The backend also returns a finer-grained `features`/`limits` map (e.g.
/// `ai_label_analysis`, `ean_lists`) that isn't wired through here yet —
/// this tier mapping is a reasonable approximation, not the long-term
/// per-feature entitlement source of truth.
const Map<String, Set<Feature>> _planFeatures = {
  // Free: barcode scan + product information only. Every `Feature` below is a
  // paid capability, so the free plan grants none of them.
  'free': <Feature>{},
  'trial': {
    Feature.advancedReports,
    Feature.inventory,
    Feature.grn,
    Feature.allergenProfile,
    Feature.recallAlerts,
    Feature.weeklyDigest,
    Feature.healthyAlternatives,
    Feature.ingredientExplainer,
    Feature.bulkScan,
    Feature.multiStore,
  },
  'starter': {Feature.inventory},
  'growth': {
    Feature.advancedReports,
    Feature.inventory,
    Feature.grn,
    Feature.bulkScan,
  },
  // Growth Plus: everything in Growth + allergen/recall alerts + multi-store.
  'growth_plus': {
    Feature.advancedReports,
    Feature.inventory,
    Feature.grn,
    Feature.bulkScan,
    Feature.allergenProfile,
    Feature.recallAlerts,
    Feature.multiStore,
  },
  // Day-pass variants inherit the same feature set as their base plan.
  'starter_day': {Feature.inventory},
  'growth_day': {
    Feature.advancedReports,
    Feature.inventory,
    Feature.grn,
    Feature.bulkScan,
  },
  'growth_plus_day': {
    Feature.advancedReports,
    Feature.inventory,
    Feature.grn,
    Feature.bulkScan,
    Feature.allergenProfile,
    Feature.recallAlerts,
    Feature.multiStore,
  },
  'pro': {
    Feature.advancedReports,
    Feature.inventory,
    Feature.grn,
    Feature.allergenProfile,
    Feature.recallAlerts,
    Feature.weeklyDigest,
    Feature.healthyAlternatives,
    Feature.ingredientExplainer,
    Feature.bulkScan,
    Feature.multiStore,
  },
  'pro_day': {
    Feature.advancedReports,
    Feature.inventory,
    Feature.grn,
    Feature.allergenProfile,
    Feature.recallAlerts,
    Feature.weeklyDigest,
    Feature.healthyAlternatives,
    Feature.ingredientExplainer,
    Feature.bulkScan,
    Feature.multiStore,
  },
};

/// Returns the minimum plan required to access the given feature.
String requiredPlanFor(Feature feature) {
  if (_planFeatures['starter']!.contains(feature)) return 'Starter';
  if (_planFeatures['growth']!.contains(feature)) return 'Growth';
  if (_planFeatures['growth_plus']!.contains(feature)) return 'Growth Plus';
  return 'Premium';
}

// ─── Provider ─────────────────────────────────────────────────────────────

/// Entitlement state for accounts with no (readable) subscription: the free
/// plan. Used for brand-new tenants whose subscription row is not there yet,
/// auditors (who aren't plan holders) and expired subscriptions.
const _freeState = EntitlementState(
  planId: 'free',
  billingCycle: BillingCycle.monthly,
  features: <Feature>{},
);

/// Async notifier that fetches subscription status and exposes entitlement
/// checks to any widget in the tree.
class EntitlementController extends AsyncNotifier<EntitlementState> {
  @override
  Future<EntitlementState> build() => _load();

  Future<EntitlementState> _load() async {
    // Auditors are invited staff, not plan holders.
    if (ref.read(appModeProvider) == AppMode.auditor) return _freeState;
    try {
      final response = await ref.read(apiClientProvider).getSubscription();
      return _mapResponse(response);
    } on DioException catch (e) {
      // 404 = the tenant has no subscription row yet -> free plan.
      if (e.response?.statusCode == 404) return _freeState;
      rethrow;
    }
  }

  /// Whether the current plan grants access to [feature].
  bool canAccess(Feature feature) {
    final state = this.state.valueOrNull;
    if (state == null) return false;
    return state.features.contains(feature);
  }

  /// Returns usage info for a metered [feature], or null if unmetered.
  UsageInfo? usageOf(Feature feature) {
    return state.valueOrNull?.usage[feature];
  }

  /// Force-refreshes entitlement state from the backend.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  EntitlementState _mapResponse(SubscriptionResponse response) {
    final planId = response.plan.code;
    // An expired / cancelled / unpaid subscription no longer grants its plan's
    // features: the account falls back to the free plan.
    final entitled = response.isActive;
    final features = entitled ? (_planFeatures[planId] ?? const <Feature>{}) : const <Feature>{};

    int? trialDays = response.trialDaysRemaining;
    if (trialDays != null && trialDays < 0) trialDays = 0;

    return EntitlementState(
      planId: planId,
      billingCycle: BillingCycle.monthly,
      features: features,
      trialDaysRemaining: entitled && planId == 'trial' ? trialDays : null,
    );
  }
}

/// The global entitlement provider. Watch this from any widget that needs to
/// check feature access.
final entitlementProvider =
    AsyncNotifierProvider<EntitlementController, EntitlementState>(
      EntitlementController.new,
    );

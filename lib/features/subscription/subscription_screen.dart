// Subscription management screen.
//
// Shows the current plan status, a billing-period toggle (Monthly / 1-Day),
// and a scrollable list of plan cards. Plan data comes from [kRadhaPlans] in
// models/plan_model.dart — adding or repricing plans requires only that file.
//
// Payment flow: _handleUpgrade → openRazorpayCheckout (razorpay_checkout_sheet.dart)
// Plan resolution: SubscriptionService (services/subscription_service.dart)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/entitlements/entitlement_provider.dart';
import '../../design/app_assets.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/widgets/brand_illustration.dart';
import '../../design/widgets/error_state.dart';
import '../../design/widgets/mor_companion.dart';
import '../../design/widgets/primary_button.dart';
import '../../l10n/generated/app_localizations.dart';
import 'models/plan_model.dart';
import 'razorpay_checkout_sheet.dart';
import 'services/subscription_service.dart';
import 'widgets/billing_period_toggle.dart';

// ─── Screen ───────────────────────────────────────────────────────────────

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final entitlement = ref.watch(entitlementProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          AppLocalizations.of(context).subscriptionTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: entitlement.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: RadhaColors.primary),
        ),
        error: (_, _) => Center(
          child: ErrorState(
            title: AppLocalizations.of(context).subscriptionLoadError,
            body: AppLocalizations.of(context).subscriptionLoadErrorBody,
            onRetry: () => ref.invalidate(entitlementProvider),
          ),
        ),
        data: (state) => _SubscriptionBody(state: state),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────

class _SubscriptionBody extends ConsumerStatefulWidget {
  const _SubscriptionBody({required this.state});
  final EntitlementState state;

  @override
  ConsumerState<_SubscriptionBody> createState() => _SubscriptionBodyState();
}

class _SubscriptionBodyState extends ConsumerState<_SubscriptionBody> {
  BillingPeriod _period = BillingPeriod.monthly;
  String? _busyPlanId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final state = widget.state;
    // Real backend plan UUIDs — checkout can't proceed until this resolves,
    // since `planId` must be a UUID, not the plan *code* `kRadhaPlans` uses
    // as its local id. See `subscriptionPlanIdMapProvider`.
    final planIdMap = ref.watch(subscriptionPlanIdMapProvider);

    final plans = _period == BillingPeriod.monthly
        ? SubscriptionService.monthlyPlans
        : SubscriptionService.dayPassPlans;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        RadhaSpacing.space20,
        RadhaSpacing.space16,
        RadhaSpacing.space20,
        RadhaSpacing.space48,
      ),
      children: [
        // Paywall hero — sets the "RADHA Plus" aspiration before plans.
        Center(
          child: BrandIllustration(
            RadhaAssets.paywallHero,
            size: 196,
            fallback: const MorCompanion(mood: MorMood.guard, size: 120),
          ),
        ),
        const SizedBox(height: RadhaSpacing.space8),
        Text(
          l10n.subscriptionHeadline,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: RadhaSpacing.space24),
        _CurrentPlanCard(state: state),
        const SizedBox(height: RadhaSpacing.space24),
        Text(
          l10n.subscriptionChooseAPlan,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: RadhaSpacing.space12),
        BillingPeriodToggle(
          selected: _period,
          onChanged: (p) {
            HapticFeedback.selectionClick();
            setState(() => _period = p);
          },
        ),
        const SizedBox(height: RadhaSpacing.space16),
        // AnimatedSwitcher cross-fades between the monthly and day-pass lists.
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Column(
            key: ValueKey(_period),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final plan in plans)
                Padding(
                  padding: const EdgeInsets.only(bottom: RadhaSpacing.space12),
                  child: _PlanCard(
                    plan: plan,
                    period: _period,
                    isCurrent: _period == BillingPeriod.monthly &&
                        plan.id == state.planId,
                    busy: _busyPlanId == plan.idFor(_period),
                    // Disabled while another purchase is in flight, or while
                    // the real plan UUID hasn't loaded yet (button would
                    // have nothing valid to send).
                    disabled: (_busyPlanId != null &&
                            _busyPlanId != plan.idFor(_period)) ||
                        !planIdMap.hasValue,
                    onUpgrade: () => _handleUpgrade(plan, planIdMap.value),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: RadhaSpacing.space12),
        Center(
          child: Text(
            _period == BillingPeriod.monthly
                ? l10n.subscriptionCancelAnytime
                : 'One-time payment · Valid for 24 hours · GST included',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleUpgrade(
    SubscriptionPlan plan,
    Map<String, String>? planIdMap,
  ) async {
    // `plan.id` is a plan *code* (e.g. 'starter'); the checkout endpoint
    // requires the backend's real UUID for that plan. The card is disabled
    // while `planIdMap` hasn't loaded, but guard again defensively in case
    // of a stale rebuild racing a tap.
    final realPlanId = planIdMap?[plan.id];
    if (realPlanId == null) {
      final message = planIdMap == null
          ? 'Still loading plan details — try again in a moment.'
          // planIdMap loaded but has no entry for this plan code — the
          // backend has no matching row (e.g. 'growth_plus' isn't seeded
          // yet). Retrying won't help; this needs a backend plan added.
          : "${plan.displayName} isn't available for purchase yet.";
      ScaffoldMessenger.maybeOf(
        context,
      )?.showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _busyPlanId = plan.idFor(_period));
    try {
      await openRazorpayCheckout(
        context: context,
        ref: ref,
        planId: realPlanId,
        billingCycle: SubscriptionService.billingCycleLabel(),
        packType: SubscriptionService.packTypeLabel(_period),
      );
    } finally {
      if (mounted) setState(() => _busyPlanId = null);
    }
  }
}

// ─── Current plan card ────────────────────────────────────────────────────

class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard({required this.state});
  final EntitlementState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trialDays = state.trialDaysRemaining;
    final onTrial = trialDays != null;

    // Resolve display info — trial is a special server-only plan not in kRadhaPlans.
    final plan = SubscriptionPlan.findById(state.planId);
    final planName = plan?.displayName ?? (onTrial ? 'Free Trial' : 'Unknown');
    final planPrice = plan?.monthlyPrice;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      padding: const EdgeInsets.all(RadhaSpacing.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Current plan',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (onTrial)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: RadhaSpacing.space12,
                    vertical: RadhaSpacing.space4,
                  ),
                  decoration: BoxDecoration(
                    color: RadhaColors.primaryTint.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
                  ),
                  child: Text(
                    '$trialDays days left',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: RadhaColors.primaryDeep,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: RadhaSpacing.space4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                planName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (planPrice != null && planPrice > 0) ...[
                Text(
                  '₹$planPrice',
                  style: radhaMonoStyle(
                    fontSize: 22,
                    weight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '/mo',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: RadhaSpacing.space4),
          Text(
            state.billingCycle == BillingCycle.yearly
                ? 'Yearly billing'
                : 'Monthly billing',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (onTrial) ...[
            const SizedBox(height: RadhaSpacing.space16),
            ClipRRect(
              borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
              child: LinearProgressIndicator(
                // 90-day trial; show elapsed fraction.
                value: ((90 - trialDays) / 90).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: RadhaColors.primary.withValues(alpha: 0.16),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  RadhaColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Plan card ────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.period,
    required this.isCurrent,
    required this.busy,
    required this.disabled,
    required this.onUpgrade,
  });

  final SubscriptionPlan plan;
  final BillingPeriod period;
  final bool isCurrent;
  final bool busy;
  final bool disabled;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final highlight = plan.isPopular && !isCurrent;
    final isDay = period == BillingPeriod.day;
    final price = plan.priceFor(period);
    final name = isDay ? plan.dayPassDisplayName : plan.displayName;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        border: Border.all(
          color: highlight || isCurrent
              ? RadhaColors.primary
              : theme.colorScheme.outline,
          width: highlight || isCurrent ? 2 : 1,
        ),
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: RadhaColors.primary.withValues(alpha: 0.14),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : const <BoxShadow>[],
      ),
      padding: const EdgeInsets.all(RadhaSpacing.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row: name, popular badge, price ────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: RadhaSpacing.space8),
              if (plan.isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: RadhaSpacing.space8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: RadhaColors.primary,
                    borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
                  ),
                  child: Text(
                    l10n.subscriptionPopular,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: RadhaColors.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const SizedBox(width: RadhaSpacing.space8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹$price',
                        style: radhaMonoStyle(
                          fontSize: 20,
                          weight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        isDay ? '/day' : l10n.subscriptionPerMonth,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (isDay)
                    Text(
                      '24-hour access',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: RadhaColors.primaryDeep,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: RadhaSpacing.space4),
          Text(
            plan.tagline,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: RadhaSpacing.space12),
          // ── Feature highlights ────────────────────────────────────────
          for (final h in plan.highlights)
            Padding(
              padding: const EdgeInsets.only(bottom: RadhaSpacing.space8),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: RadhaColors.success,
                  ),
                  const SizedBox(width: RadhaSpacing.space8),
                  Expanded(
                    child: Text(
                      h,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: RadhaSpacing.space8),
          // ── CTA button ────────────────────────────────────────────────
          if (isCurrent && !isDay)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: RadhaSpacing.space12,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: RadhaColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
                border: Border.all(color: RadhaColors.primary),
              ),
              child: Text(
                l10n.subscriptionCurrentPlan(plan.displayName),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: RadhaColors.primaryDeep,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else if (highlight || isDay && plan.isPopular)
            PrimaryButton(
              label: isDay
                  ? 'Get ${plan.displayName} for 1 day · ₹$price'
                  : l10n.subscriptionUpgradeTo(plan.displayName),
              expand: true,
              loading: busy,
              onPressed: disabled ? null : onUpgrade,
            )
          else
            OutlinedButton(
              onPressed: disabled || busy ? null : onUpgrade,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, kMinTouchTarget),
              ),
              child: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      isDay
                          ? 'Get ${plan.displayName} for 1 day · ₹$price'
                          : l10n.subscriptionChoosePlan(plan.displayName),
                    ),
            ),
        ],
      ),
    );
  }
}

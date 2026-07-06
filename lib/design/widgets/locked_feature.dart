// Locked-feature overlay widget.
//
// Wraps any child widget and, when the user's entitlement denies the feature,
// renders the child at reduced opacity with a centered upgrade prompt overlay.
// When access is granted the child renders normally with zero overhead.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/entitlements/entitlement_provider.dart';
import '../../core/router/app_router.dart';
import '../../l10n/generated/app_localizations.dart';
import '../tokens.dart';
import 'primary_button.dart';

/// Wraps [child] with an entitlement gate. If the current plan does not
/// include [feature], the child is dimmed and covered by an upgrade overlay.
class LockedFeature extends ConsumerWidget {
  const LockedFeature({required this.feature, required this.child, super.key});

  final Feature feature;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entitlement = ref.watch(entitlementProvider);

    return entitlement.when(
      loading: () => child,
      error: (_, _) => child,
      data: (state) {
        if (state.features.contains(feature)) return child;
        return _LockedOverlay(feature: feature, child: child);
      },
    );
  }
}

class _LockedOverlay extends StatelessWidget {
  const _LockedOverlay({required this.feature, required this.child});

  final Feature feature;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final planName = requiredPlanFor(feature);

    return Stack(
      children: [
        // Dimmed child — no interaction leaks through.
        AbsorbPointer(child: Opacity(opacity: 0.3, child: child)),

        // Overlay card.
        Positioned.fill(
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: RadhaSpacing.space32,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: RadhaSpacing.space24,
                vertical: RadhaSpacing.space32,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
                border: Border.all(color: theme.colorScheme.outline, width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: RadhaColors.primaryTint.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.lock_outlined,
                      size: 30,
                      color: RadhaColors.primaryDeep,
                    ),
                  ),
                  const SizedBox(height: RadhaSpacing.space16),
                  Text(
                    l10n.lockedFeatureUpgradeTo(planName),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: RadhaSpacing.space4),
                  Text(
                    l10n.lockedFeaturePlan(planName),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: RadhaSpacing.space24),
                  PrimaryButton(
                    label: l10n.lockedFeatureViewPlans,
                    icon: Icons.workspace_premium_outlined,
                    onPressed: () => context.push(AppRoute.subscription),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

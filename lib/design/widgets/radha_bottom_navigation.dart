import 'package:flutter/material.dart';

import '../theme.dart';
import '../tokens.dart';

/// One destination in [RadhaBottomNavigation].
///
/// [emphasized] marks the single primary action (Scan) — it renders as the one
/// orange element in the bar so the brand's "one primary orange action per
/// region" rule holds: the active *tab* is shown with a soft tint pill, never a
/// second full-orange fill that competes with Scan.
///
/// [badgeCount] is only rendered when `> 0`. It must be fed from a real provider
/// — never a placeholder — so the bar can never show a fabricated count.
@immutable
class RadhaNavDestination {
  const RadhaNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.emphasized = false,
    this.badgeCount,
    this.tooltip,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool emphasized;
  final int? badgeCount;
  final String? tooltip;
}

/// RADHA's bottom navigation grammar.
///
/// Replaces the generic Material [NavigationBar] with the authored brand
/// treatment: cream surface, 1px hairline top edge, a soft tint indicator pill
/// behind the active tab, and an emphasized orange Scan action that stays
/// connected to the bar (no detached floating ornament).
///
/// Behaviour parity with the previous `NavigationBar` is intentional — the
/// hosting shell still owns haptics, `goBranch`, and re-tap-to-root. This widget
/// only renders and reports taps via [onDestinationSelected].
///
/// Accessibility: every cell is a 48dp+ opaque target with `Semantics(button,
/// selected)`; the indicator animation honours `MediaQuery.disableAnimations`.
/// Reads colour only from the theme — no inline literals.
class RadhaBottomNavigation extends StatelessWidget {
  const RadhaBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.destinations,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final List<RadhaNavDestination> destinations;
  final ValueChanged<int> onDestinationSelected;

  /// Height of the icon zone — fixed so the emphasized Scan circle and the
  /// regular tint pills baseline-align their labels.
  static const double _iconZone = 44;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Material(
      color: theme.colorScheme.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: theme.colorScheme.outline, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: RadhaSpacing.space8,
              vertical: RadhaSpacing.space8,
            ),
            child: Row(
              children: [
                for (var i = 0; i < destinations.length; i++)
                  Expanded(
                    child: _NavCell(
                      destination: destinations[i],
                      selected: i == currentIndex,
                      reduceMotion: reduceMotion,
                      onTap: () => onDestinationSelected(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavCell extends StatelessWidget {
  const _NavCell({
    required this.destination,
    required this.selected,
    required this.reduceMotion,
    required this.onTap,
  });

  final RadhaNavDestination destination;
  final bool selected;
  final bool reduceMotion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.55);

    final iconZone = destination.emphasized
        ? _EmphasizedIcon(
            destination: destination,
            selected: selected,
            reduceMotion: reduceMotion,
          )
        : _TintPillIcon(
            destination: destination,
            selected: selected,
            reduceMotion: reduceMotion,
          );

    final labelColor = selected ? scheme.primary : muted;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      // Collapse the icon + visible label into one node so the tab announces
      // exactly once ("<label>, button, selected").
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 48,
        highlightShape: BoxShape.rectangle,
        containedInkWell: true,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        child: Tooltip(
          message: destination.tooltip ?? destination.label,
          preferBelow: false,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: kMinTouchTarget + 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                iconZone,
                const SizedBox(height: RadhaSpacing.space2),
                Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: labelColor,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Regular tab icon: a soft [primaryTint] pill fades in behind the icon when
/// the tab is active. The tint (not a full orange fill) keeps Scan as the sole
/// dominant orange.
class _TintPillIcon extends StatelessWidget {
  const _TintPillIcon({
    required this.destination,
    required this.selected,
    required this.reduceMotion,
  });

  final RadhaNavDestination destination;
  final bool selected;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.55);

    return SizedBox(
      height: RadhaBottomNavigation._iconZone,
      child: Center(
        child: AnimatedContainer(
          duration: reduceMotion ? Duration.zero : RadhaMotion.medium,
          curve: RadhaMotion.easeOut,
          width: 56,
          height: 32,
          decoration: BoxDecoration(
            color: selected
                ? scheme.primaryContainer.withValues(alpha: 0.5)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
          ),
          alignment: Alignment.center,
          child: _IconWithBadge(
            icon: selected ? destination.selectedIcon : destination.icon,
            color: selected ? scheme.primary : muted,
            badgeCount: destination.badgeCount,
          ),
        ),
      ),
    );
  }
}

/// Emphasized Scan action: the one full-orange element. A cream ring keeps it
/// reading as part of the bar rather than a detached floating button.
class _EmphasizedIcon extends StatelessWidget {
  const _EmphasizedIcon({
    required this.destination,
    required this.selected,
    required this.reduceMotion,
  });

  final RadhaNavDestination destination;
  final bool selected;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: RadhaBottomNavigation._iconZone,
      child: Center(
        child: AnimatedScale(
          scale: selected ? 1.0 : 0.94,
          duration: reduceMotion ? Duration.zero : RadhaMotion.fast,
          curve: RadhaMotion.easeOut,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
              border: Border.all(color: scheme.surface, width: 2),
            ),
            alignment: Alignment.center,
            child: _IconWithBadge(
              icon: selected ? destination.selectedIcon : destination.icon,
              color: scheme.onPrimary,
              badgeCount: destination.badgeCount,
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon with an optional count badge. The badge is rendered only for a real
/// positive count (numerics in mono per the brand contract).
class _IconWithBadge extends StatelessWidget {
  const _IconWithBadge({
    required this.icon,
    required this.color,
    this.badgeCount,
  });

  final IconData icon;
  final Color color;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final count = badgeCount;
    final iconWidget = Icon(icon, size: 24, color: color);

    if (count == null || count <= 0) return iconWidget;

    final label = count > 99 ? '99+' : '$count';
    return Stack(
      clipBehavior: Clip.none,
      children: [
        iconWidget,
        Positioned(
          top: -6,
          right: -10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            decoration: BoxDecoration(
              color: scheme.error,
              borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
              border: Border.all(color: scheme.surface, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: radhaMonoStyle(
                fontSize: 10,
                weight: FontWeight.w700,
                color: scheme.onError,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../tokens.dart';
import 'primary_button.dart';

/// Empty state composition. Accepts an optional illustration slot (kept
/// SVG-friendly), a title, supporting body copy, and a primary action.
///
/// When no [illustration] is supplied, a calm tonal icon badge is drawn from
/// [icon] (defaulting to a neutral inbox glyph) so every empty surface has a
/// visual anchor instead of bare text. The whole block fades + rises in on
/// first build, honouring the platform reduce-motion flag.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.illustration,
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    this.icon = Icons.inbox_outlined,
  });

  /// Illustration widget. Recommended size is around 96–160 logical pixels.
  /// Keep this calm — no animated effects, no heavy gradients. When provided
  /// it takes precedence over the default [icon] badge.
  final Widget? illustration;

  final String title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;

  /// Glyph rendered inside the default tonal badge when no [illustration] is
  /// supplied. Drawn in the orange accent on a 12%-alpha accent disc.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final content = Padding(
      padding: const EdgeInsets.all(RadhaSpacing.space32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (illustration != null) ...[
            illustration!,
            const SizedBox(height: RadhaSpacing.space24),
          ] else ...[
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
              ),
              child: Icon(icon, size: 28, color: scheme.primary),
            ),
            const SizedBox(height: RadhaSpacing.space24),
          ],
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (body != null) ...[
            const SizedBox(height: RadhaSpacing.space8),
            Text(
              body!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: RadhaSpacing.space24),
            PrimaryButton(
              label: actionLabel!,
              icon: actionIcon,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );

    if (reduceMotion) return content;
    return _FadeRiseIn(child: content);
  }
}

/// One-shot fade + rise used to soften the appearance of empty/error states.
class _FadeRiseIn extends StatefulWidget {
  const _FadeRiseIn({required this.child});

  final Widget child;

  @override
  State<_FadeRiseIn> createState() => _FadeRiseInState();
}

class _FadeRiseInState extends State<_FadeRiseIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: RadhaMotion.slow,
  )..forward();
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _c,
    curve: RadhaMotion.easeOut,
  );
  late final Animation<Offset> _offset = Tween<Offset>(
    begin: const Offset(0, 0.05),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _c, curve: RadhaMotion.easeOut));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}

import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../app_assets.dart';
import '../tokens.dart';
import 'brand_illustration.dart';
import 'mor_companion.dart';
import 'secondary_button.dart';

/// Error state composition. Renders a calm danger-tinted icon badge, a title,
/// an optional supporting body, and a single retry CTA.
///
/// The block fades + rises in on first build (reduce-motion aware) so a failed
/// load resolves into the error softly rather than snapping in.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.title,
    this.body,
    this.retryLabel,
    this.onRetry,
    this.illustration,
  });

  final String title;
  final String? body;

  /// Retry CTA label. Defaults to the localized "Try again" when null.
  final String? retryLabel;
  final VoidCallback? onRetry;

  /// Optional illustration. When null, Mor (concern) is shown so every error
  /// surface carries the companion without per-screen wiring.
  final Widget? illustration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final content = Padding(
      padding: const EdgeInsets.all(RadhaSpacing.space32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          illustration ??
              BrandIllustration(
                RadhaAssets.stateErrorRetry,
                size: 156,
                semanticLabel: l10n.errorGeneric,
                // Falls back to the companion if the asset can't decode.
                fallback: const MorCompanion(mood: MorMood.concern, size: 96),
              ),
          const SizedBox(height: RadhaSpacing.space24),
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
          if (onRetry != null) ...[
            const SizedBox(height: RadhaSpacing.space24),
            SecondaryButton(
              label: retryLabel ?? l10n.tryAgain,
              icon: Icons.refresh,
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );

    if (reduceMotion) return content;
    return _FadeRiseIn(child: content);
  }
}

/// One-shot fade + rise used to soften the appearance of the error state.
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

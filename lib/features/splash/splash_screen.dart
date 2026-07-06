// Splash screen.
//
// Owns the visual presentation only. The bootstrap work and routing decisions
// live elsewhere:
//
//   * `BootstrapController` runs the side-effecting startup sequence
//     (package_info, device_id, session hydration, optional /auth/me).
//   * The router's global `redirect` callback (Task 4) navigates the user
//     off `/splash` once auth + onboarding state has settled.
//
// This widget never calls `context.go` itself. It reads
// `bootstrapControllerProvider` for two reasons:
//   1. To kick off the bootstrap if it hasn't already started, and
//   2. To drive a thin progress strip while the work is in flight.
//
// Visual contract (anti-slop, orange brand):
//   * Warm cream surface from theme (no pure-black, no purple/blue gradient).
//   * A brand mark tile + wordmark, both introduced with a staggered entrance
//     (mark: fade + gentle scale-from-0.86; wordmark: fade + 12px rise). The
//     entrance is a one-shot ≤700 ms sequence on `Curves.easeOutCubic`.
//   * Single orange accent (#EA580C) on the mark, the progress strip, and a
//     short teal complement underline beneath the wordmark for a restrained
//     contrast cue.
//   * Decorative ambient motion (the loading pulse) is opacity-only — no
//     geometry moves once the entrance settles.
//   * Honors `MediaQuery.disableAnimations` (OS "reduce motion"): when set,
//     everything renders in its final resting state with no controllers.
//   * Responsive: mark + wordmark scale with available width via
//     `LayoutBuilder`, clamped so phones and tablets both read well.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/app_assets.dart';
import '../../design/tokens.dart';
import '../../design/widgets/brand_illustration.dart';
import '../../design/widgets/mor_companion.dart';
import 'bootstrap_controller.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watching the controller is the trigger that starts the bootstrap if
    // it hasn't run yet. We don't branch on its state for navigation — the
    // router's `refreshListenable` does that — but we gate the progress bar
    // on it so the user gets a visible "we're working" cue.
    final bootstrap = ref.watch(bootstrapControllerProvider);
    final theme = Theme.of(context);
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive mark size: ~28% of the shorter edge, clamped so it
            // never gets cramped on small phones or oversized on tablets.
            final shortEdge = constraints.biggest.shortestSide;
            final markSize = shortEdge.isFinite
                ? shortEdge.clamp(320.0, 1024.0) * 0.28
                : 112.0;

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: RadhaSpacing.space32,
                vertical: RadhaSpacing.space48,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  _SplashHero(
                    markSize: markSize.toDouble(),
                    reduceMotion: reduceMotion,
                  ),
                  const SizedBox(height: RadhaSpacing.space32),
                  _ProgressStrip(
                    isLoading: bootstrap.isLoading,
                    reduceMotion: reduceMotion,
                  ),
                  const Spacer(flex: 2),
                  _Footer(version: bootstrap.valueOrNull?.packageInfo.version),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The staggered entrance group: brand-mark tile, wordmark, and a short teal
/// complement underline. Drives a single one-shot controller and projects it
/// through three intervals. When `reduceMotion` is set, no controller is
/// created and everything paints in its resting state.
class _SplashHero extends StatefulWidget {
  const _SplashHero({required this.markSize, required this.reduceMotion});

  final double markSize;
  final bool reduceMotion;

  @override
  State<_SplashHero> createState() => _SplashHeroState();
}

class _SplashHeroState extends State<_SplashHero>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;

  late final Animation<double> _markFade;
  late final Animation<double> _markScale;
  late final Animation<double> _wordFade;
  late final Animation<Offset> _wordSlide;
  late final Animation<double> _underline;

  @override
  void initState() {
    super.initState();
    if (widget.reduceMotion) return;

    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _ctrl = ctrl;

    // Mark: 0–55% — fade in + scale from 0.86 to 1.0.
    _markFade = CurvedAnimation(
      parent: ctrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _markScale = Tween<double>(begin: 0.86, end: 1.0).animate(
      CurvedAnimation(
        parent: ctrl,
        curve: const Interval(0.0, 0.55, curve: RadhaMotion.spring),
      ),
    );

    // Wordmark: 35–80% — fade in + rise 12px.
    _wordFade = CurvedAnimation(
      parent: ctrl,
      curve: const Interval(0.35, 0.80, curve: Curves.easeOut),
    );
    _wordSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: ctrl,
            curve: const Interval(0.35, 0.80, curve: Curves.easeOutCubic),
          ),
        );

    // Underline: 70–100% — wipes in from 0 to full width.
    _underline = CurvedAnimation(
      parent: ctrl,
      curve: const Interval(0.70, 1.0, curve: Curves.easeOutCubic),
    );

    ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mor (full hero scene) welcomes the owner in; falls back to the static
    // greet frame if the illustration can't decode.
    final mark = BrandIllustration(
      RadhaAssets.morSceneSplash,
      size: widget.markSize * 1.6,
      semanticLabel: 'RADHA',
      fallback: MorCompanion(
        mood: MorMood.greet,
        size: widget.markSize * 1.35,
        animate: false,
      ),
    );
    final wordmark = _Wordmark();
    final underline = _ComplementUnderline(
      progress: widget.reduceMotion ? 1.0 : null,
    );

    if (widget.reduceMotion || _ctrl == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          mark,
          const SizedBox(height: RadhaSpacing.space24),
          wordmark,
          const SizedBox(height: RadhaSpacing.space12),
          underline,
        ],
      );
    }

    return AnimatedBuilder(
      animation: _ctrl!,
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: _markFade,
              child: ScaleTransition(scale: _markScale, child: mark),
            ),
            const SizedBox(height: RadhaSpacing.space24),
            FadeTransition(
              opacity: _wordFade,
              child: SlideTransition(position: _wordSlide, child: wordmark),
            ),
            const SizedBox(height: RadhaSpacing.space12),
            _ComplementUnderline(progress: _underline.value),
          ],
        );
      },
    );
  }
}

// _BrandMark removed — Mor (greet) is the splash hero now.

/// Brand wordmark — Plus Jakarta Sans 700 with tight editorial tracking.
class _Wordmark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.displaySmall;
    final fontSize = base?.fontSize ?? 36;
    return Semantics(
      label: 'RADHA',
      header: true,
      child: Text(
        'RADHA',
        textAlign: TextAlign.center,
        style: base?.copyWith(
          letterSpacing: 0.06 * fontSize,
          fontWeight: FontWeight.w800,
          color: RadhaColors.ink,
        ),
      ),
    );
  }
}

/// Short teal complement underline beneath the wordmark — orange's opposite,
/// used as a single restrained contrast cue. `progress` (0..1) wipes the
/// width in during the entrance; null resolves to fully drawn.
class _ComplementUnderline extends StatelessWidget {
  const _ComplementUnderline({required this.progress});

  final double? progress;

  @override
  Widget build(BuildContext context) {
    final p = (progress ?? 1.0).clamp(0.0, 1.0);
    return ExcludeSemantics(
      child: Container(
        width: 56 * p,
        height: 4,
        decoration: BoxDecoration(
          color: RadhaColors.complement,
          borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
        ),
      ),
    );
  }
}

/// Thin orange progress bar. Width-capped at 200 px so it never dominates the
/// wordmark on tablets. Indeterminate while the bootstrap is in flight;
/// settles to a full determinate bar once the controller resolves so the
/// visual "completes" before the redirect fires. Under reduce-motion the
/// indeterminate animation is replaced with a static partial bar.
class _ProgressStrip extends StatelessWidget {
  const _ProgressStrip({required this.isLoading, required this.reduceMotion});

  final bool isLoading;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final double? value = !isLoading
        ? 1.0
        : reduceMotion
        ? 0.35
        : null; // null → indeterminate sweep

    return Center(
      child: SizedBox(
        width: 200,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 3,
            valueColor: const AlwaysStoppedAnimation<Color>(
              RadhaColors.primary,
            ),
            backgroundColor: RadhaColors.primary.withValues(alpha: 0.16),
          ),
        ),
      ),
    );
  }
}

/// Discreet version label at the bottom — muted so it never competes with the
/// wordmark. Hidden until the bootstrap returns the version so we don't render
/// an empty placeholder line.
class _Footer extends StatelessWidget {
  const _Footer({required this.version});

  final String? version;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (version == null || version!.isEmpty) {
      return const SizedBox(height: 16);
    }
    return Text(
      'v$version',
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    );
  }
}

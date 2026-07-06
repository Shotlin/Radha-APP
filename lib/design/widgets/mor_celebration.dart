import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:radha_app/design/app_assets.dart';
import 'package:radha_app/design/tokens.dart';
import 'package:radha_app/design/widgets/brand_illustration.dart';
import 'package:radha_app/design/widgets/mor_companion.dart';
import 'package:radha_app/l10n/generated/app_localizations.dart';

/// A one-shot celebration beat: Mor in the `celebrate` pose with a burst of
/// marigold petals radiating outward, then a gentle settle.
///
/// This is the native-Flutter realisation of the "scan-success" / "win-beat"
/// moments described in the Character Bible §6/§8. Petals are drawn with a
/// lightweight [CustomPainter] particle system (Bible §7.1 sanctions particles
/// via a custom painter) rather than a Lottie dependency — so it is robust,
/// cheap (transform/opacity only), and degrades cleanly.
///
/// Reduced-motion: when `MediaQuery.disableAnimations` is true, the petals are
/// skipped entirely and a static [MorCompanion] celebrate frame is shown — no
/// state is ever conveyed by motion alone (the caller always pairs this with
/// text + an icon).
class MorCelebration extends StatefulWidget {
  const MorCelebration({
    super.key,
    this.size = 120,
    this.petalCount = 6,
    this.intensity = 1.0,
    this.onComplete,
  });

  /// Footprint of the Mor figure (petals burst within ~1.6× this box).
  final double size;

  /// Number of petals in the burst. Bible scan-success spec calls for ~6.
  final int petalCount;

  /// 0..1 — scales the burst radius and petal size for "small win" vs
  /// "big win-beat" reuse.
  final double intensity;

  /// Fired once the burst animation settles (not fired in reduced-motion).
  final VoidCallback? onComplete;

  @override
  State<MorCelebration> createState() => _MorCelebrationState();
}

class _MorCelebrationState extends State<MorCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    // Bible §7.4: scan-success ≈ 600 ms; win-beat ≈ 800 ms (motion.celebrate).
    duration: const Duration(milliseconds: 760),
  );

  late final List<_Petal> _petals;
  bool _reduceMotion = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    // Deterministic-ish but varied spread: petals fan out across the full
    // circle with small jitter so the burst feels organic, not mechanical.
    final rnd = math.Random(widget.petalCount * 31 + 7);
    _petals = List<_Petal>.generate(widget.petalCount, (i) {
      final base = (i / widget.petalCount) * 2 * math.pi;
      final jitter = (rnd.nextDouble() - 0.5) * 0.6;
      return _Petal(
        angle: base + jitter,
        distanceFactor: 0.78 + rnd.nextDouble() * 0.22,
        spin: (rnd.nextDouble() - 0.5) * 2.4,
        sizeFactor: 0.8 + rnd.nextDouble() * 0.4,
        marigold: i.isEven,
      );
    });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onComplete?.call();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (!_started && !_reduceMotion) {
      _started = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mor = BrandIllustration(
      RadhaAssets.morSceneWin,
      size: widget.size,
      semanticLabel: AppLocalizations.of(context).commonSuccess,
      // The breathing idle would fight the burst; the static frame is the
      // fallback if the win illustration can't decode.
      fallback: MorCompanion(
        mood: MorMood.celebrate,
        size: widget.size,
        animate: false,
      ),
    );

    if (_reduceMotion) {
      return mor;
    }

    final burstBox = widget.size * 1.6;
    return SizedBox(
      width: burstBox,
      height: burstBox,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(burstBox, burstBox),
                painter: _PetalBurstPainter(
                  progress: _controller.value,
                  petals: _petals,
                  intensity: widget.intensity,
                  marigold: RadhaColors.festiveMarigold,
                  turmeric: RadhaColors.festiveTurmeric,
                ),
              ),
              // A small pop-in on Mor himself: 0.92 → 1.0 with the burst.
              Transform.scale(
                scale:
                    0.92 +
                    0.08 *
                        Curves.easeOutBack.transform(
                          _controller.value.clamp(0.0, 1.0),
                        ),
                child: child,
              ),
            ],
          );
        },
        child: mor,
      ),
    );
  }
}

/// Immutable description of a single petal in the burst.
class _Petal {
  const _Petal({
    required this.angle,
    required this.distanceFactor,
    required this.spin,
    required this.sizeFactor,
    required this.marigold,
  });

  /// Radial direction of travel (radians).
  final double angle;

  /// 0..1 — how far along the max radius this petal travels.
  final double distanceFactor;

  /// Rotation applied over the burst (radians).
  final double spin;

  /// Relative petal size.
  final double sizeFactor;

  /// Alternate marigold / turmeric for a warm two-tone burst.
  final bool marigold;
}

class _PetalBurstPainter extends CustomPainter {
  _PetalBurstPainter({
    required this.progress,
    required this.petals,
    required this.intensity,
    required this.marigold,
    required this.turmeric,
  });

  final double progress;
  final List<_Petal> petals;
  final double intensity;
  final Color marigold;
  final Color turmeric;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final center = size.center(Offset.zero);
    final maxRadius = size.width * 0.42 * intensity;

    // Eased travel: fast out, then settle. Opacity fades in the last third.
    final travel = Curves.easeOutCubic.transform(progress);
    final fade = progress < 0.7 ? 1.0 : (1.0 - (progress - 0.7) / 0.3);

    for (final petal in petals) {
      final dist = maxRadius * petal.distanceFactor * travel;
      final dx = center.dx + math.cos(petal.angle) * dist;
      final dy = center.dy + math.sin(petal.angle) * dist;
      final petalLen = size.width * 0.06 * petal.sizeFactor * intensity;

      final paint = Paint()
        ..color = (petal.marigold ? marigold : turmeric).withValues(
          alpha: (0.9 * fade).clamp(0.0, 1.0),
        )
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(petal.angle + petal.spin * travel);

      // A simple teardrop/petal: two mirrored quadratics.
      final path = Path()
        ..moveTo(0, -petalLen)
        ..quadraticBezierTo(petalLen * 0.7, 0, 0, petalLen)
        ..quadraticBezierTo(-petalLen * 0.7, 0, 0, -petalLen)
        ..close();
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PetalBurstPainter old) =>
      old.progress != progress ||
      old.intensity != intensity ||
      old.petals != petals;
}

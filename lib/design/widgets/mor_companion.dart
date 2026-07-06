import 'package:flutter/material.dart';

import 'package:radha_app/design/app_assets.dart';

/// Mor — RADHA's companion mascot (CHARACTER_STORYTELLING_BIBLE.md).
///
/// Renders a static mood frame with a gentle, reduced-motion-aware "breathing"
/// idle so the character feels alive without any heavyweight animation
/// dependency. Decorative by default; pass [semanticLabel] only when the
/// character itself carries meaning the surrounding text doesn't.
///
/// Robustness: a missing/!corrupt asset degrades to an empty box (never a
/// red error widget) so a single bad PNG can never crash a screen.
class MorCompanion extends StatefulWidget {
  const MorCompanion({
    super.key,
    this.mood = MorMood.idle,
    this.size = 96,
    this.animate = true,
    this.semanticLabel,
  });

  final MorMood mood;
  final double size;
  final bool animate;
  final String? semanticLabel;

  @override
  State<MorCompanion> createState() => _MorCompanionState();
}

class _MorCompanionState extends State<MorCompanion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant MorCompanion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) _syncAnimation();
  }

  void _syncAnimation() {
    if (widget.animate && !_reduceMotion) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      RadhaAssets.morMoodFrame(widget.mood),
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      // Decode at ~3× the display size (crisp on retina) instead of the full
      // multi-MB source — keeps memory low and scrolling jank-free.
      cacheWidth: (widget.size * 3).round(),
      errorBuilder: (_, _, _) =>
          SizedBox(width: widget.size, height: widget.size),
    );

    final Widget body;
    if (!widget.animate || _reduceMotion) {
      body = image;
    } else {
      body = AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Gentle breathing: a small scale + vertical bob. Transform-only —
          // never animates layout, so it stays cheap and jank-free.
          final t = Curves.easeInOut.transform(_controller.value);
          return Transform.translate(
            offset: Offset(0, -2.0 * t),
            child: Transform.scale(scale: 1.0 + 0.035 * t, child: child),
          );
        },
        child: image,
      );
    }

    if (widget.semanticLabel != null) {
      return Semantics(label: widget.semanticLabel, image: true, child: body);
    }
    return ExcludeSemantics(child: body);
  }
}

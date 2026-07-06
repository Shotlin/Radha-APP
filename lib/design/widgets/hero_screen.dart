import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Frosted circular back button readable on any illustration background.
class HeroBackButton extends StatelessWidget {
  const HeroBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.22),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

/// White RADHA wordmark with shadow — readable over any illustration palette.
class HeroBrand extends StatelessWidget {
  const HeroBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'RADHA',
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        shadows: [Shadow(color: Colors.black38, blurRadius: 10)],
      ),
    );
  }
}

/// Sets the status bar to light (white) icons so they remain visible over
/// the dark/colourful illustration. Reverts automatically when the widget
/// leaves the tree — no manual reset needed.
class HeroStatusBar extends StatelessWidget {
  const HeroStatusBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: child,
    );
  }
}

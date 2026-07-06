import 'package:flutter/material.dart';

import '../tokens.dart';

/// Cinematic hero banner shown at the top of every major business screen.
///
/// Renders the corresponding `business/` hero webp behind a diagonal
/// dark gradient so overlaid text stays legible on any frame. A rounded
/// "lip" in the screen's own surface colour overlaps the bottom edge of the
/// photo, so the scrollable content that immediately follows (same surface
/// colour) reads as one continuous sheet rising over the image with a
/// curved, shadowed edge — rather than a hard cut between photo and list.
/// Keep the banner above the first scrollable child so it scrolls away
/// naturally when the user pulls down the list content.
class BizScreenHero extends StatelessWidget {
  const BizScreenHero({
    super.key,
    required this.assetPath,
    required this.headline,
    required this.subtitle,
    this.height = 240,
  });

  final String assetPath;
  final String headline;
  final String subtitle;
  final double height;

  static const double _lipHeight = 24;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            assetPath,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            cacheHeight: (height * 3).round(),
            errorBuilder: (_, _, _) => Container(
              color: RadhaColors.primaryTint.withValues(alpha: 0.3),
            ),
          ),
          // Bottom-left scrim: transparent top-right → dark bottom-left
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.68),
                ],
                stops: const [0.15, 1.0],
              ),
            ),
          ),
          Positioned(
            left: RadhaSpacing.space20,
            right: RadhaSpacing.space20,
            bottom: RadhaSpacing.space20 + _lipHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  headline,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          // Premium "sheet rising over the photo" lip — same colour as the
          // screen body, rounded top corners, shadow cast upward onto the
          // image. Purely decorative: the real content below starts flush.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _lipHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(RadhaRadii.radiusXl),
                  topRight: Radius.circular(RadhaRadii.radiusXl),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

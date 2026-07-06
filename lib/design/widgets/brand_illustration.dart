import 'package:flutter/material.dart';

/// A bundled brand illustration (Mor scenes, state art, onboarding…). Decodes
/// at ~3× the display height for crispness without holding the multi-hundred-px
/// source in memory, and degrades to [fallback] (or empty space) if the asset
/// is ever missing — never a broken-image glyph.
class BrandIllustration extends StatelessWidget {
  const BrandIllustration(
    this.asset, {
    super.key,
    this.size = 140,
    this.fallback,
    this.semanticLabel,
  });

  final String asset;
  final double size;
  final Widget? fallback;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      height: size,
      fit: BoxFit.contain,
      cacheHeight: (size * 3).round(),
      filterQuality: FilterQuality.medium,
      semanticLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) =>
          fallback ?? SizedBox(width: size, height: size),
    );
  }
}

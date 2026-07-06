import 'package:flutter/material.dart';

import '../tokens.dart';
import 'skeleton_loader.dart';

/// A bundled-asset image that is **safe by construction**: it can never throw a
/// red error widget, and it never pops in with a hard flash.
///
/// Three guarantees that map directly to RADHA's "production-feel" contract:
///  1. **Graceful failure** — a missing or corrupt asset degrades to a neutral
///     branded tile (optionally captioned with [label], e.g. a product name),
///     so one bad PNG can never break a screen. This is the same robustness
///     contract `MorCompanion` follows.
///  2. **Static-UI loading** — while the first frame decodes we paint a calm
///     skeleton, then cross-fade the real image in. The layout box is reserved
///     up front, so content "arrives into" a stable frame instead of shoving
///     the page around (no jank, no reflow).
///  3. **Cheap decode** — pass [cacheWidth]/[cacheHeight] to decode large
///     source art down to display size, keeping scroll buttery and memory low.
///
/// Sizing is the caller's job — wrap in a `SizedBox`/`AspectRatio`/tile so the
/// reserved box is known before the bytes land.
class BrandedImage extends StatelessWidget {
  const BrandedImage({
    super.key,
    required this.asset,
    this.fit = BoxFit.cover,
    this.cacheWidth,
    this.cacheHeight,
    this.label,
    this.fallbackIcon = Icons.image_outlined,
    this.semanticLabel,
  });

  final String asset;
  final BoxFit fit;

  /// Decode hints. Set at least one to the on-screen pixel size × devicePixelRatio
  /// for crisp output without decoding multi-MB sources at full resolution.
  final int? cacheWidth;
  final int? cacheHeight;

  /// Caption shown only on the *failure* placeholder — typically the product /
  /// item name, so a missing image still communicates what belongs there.
  final String? label;
  final IconData fallbackIcon;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      semanticLabel: semanticLabel,
      errorBuilder: (context, _, _) =>
          _Placeholder(label: label, icon: fallbackIcon),
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        final reduceMotion =
            MediaQuery.maybeOf(context)?.disableAnimations ?? false;
        if (reduceMotion) {
          return frame == null ? const _Placeholder(loading: true) : child;
        }
        return AnimatedSwitcher(
          duration: RadhaMotion.medium,
          switchInCurve: RadhaMotion.easeOut,
          child: frame == null
              ? const _Placeholder(key: ValueKey('ph'), loading: true)
              : KeyedSubtree(key: const ValueKey('img'), child: child),
        );
      },
    );
  }
}

/// Fills its parent. `loading == true` paints a shimmer; otherwise a calm
/// tinted tile with an icon and (optionally) the item name.
class _Placeholder extends StatelessWidget {
  const _Placeholder({
    super.key,
    this.label,
    this.icon = Icons.image_outlined,
    this.loading = false,
  });

  final String? label;
  final IconData icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SkeletonLoader(
        width: double.infinity,
        height: double.infinity,
        radius: 0,
      );
    }
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: theme.colorScheme.onSurfaceVariant),
            if (label != null && label!.isNotEmpty) ...[
              const SizedBox(height: RadhaSpacing.space4),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: RadhaSpacing.space8,
                ),
                child: Text(
                  label!,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

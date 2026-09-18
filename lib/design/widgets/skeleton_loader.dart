import 'package:flutter/material.dart';

import '../tokens.dart';

/// Shimmer placeholder. Width and height are configurable; radius defaults to
/// `radiusSm` so blocks feel consistent with the rest of the surface.
///
/// Implementation note: we use a manually animated gradient sweep instead of
/// pulling a third-party shimmer package. Keeps the dependency surface small
/// and lets us tune the timing to the brand motion contract.
class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({
    super.key,
    this.width,
    this.height = 16,
    this.radius = RadhaRadii.radiusSm,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double height;
  final double radius;
  final BoxShape shape;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.colorScheme.surfaceContainerHighest;
    final highlight = Color.alphaBlend(
      theme.colorScheme.onSurface.withValues(alpha: 0.04),
      base,
    );

    // Isolates this widget's own per-frame gradient repaint into its own
    // layer — without this, every SkeletonLoader on screen (dashboards show
    // several at once) forces its siblings to repaint on the same frame,
    // even when only the shimmer sweep itself actually changed.
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              shape: widget.shape,
              borderRadius: widget.shape == BoxShape.rectangle
                  ? BorderRadius.circular(widget.radius)
                  : null,
              gradient: LinearGradient(
                begin: Alignment(-1 + 2 * t, 0),
                end: Alignment(1 + 2 * t, 0),
                colors: [base, highlight, base],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          );
        },
      ),
    );
  }
}

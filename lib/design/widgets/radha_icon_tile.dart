import 'package:flutter/material.dart';

import '../tokens.dart';

/// The tinted, soft-shadowed icon chip used in front of every stat, action,
/// and breakdown row across the app (home KPIs, biz-screen stat rows, OHS
/// breakdown, audit tallies). Centralised so the same shadow/tint/radius
/// recipe never drifts between screens.
class RadhaIconTile extends StatelessWidget {
  const RadhaIconTile({
    super.key,
    required this.icon,
    required this.tint,
    this.size = 40,
    this.iconSize,
    this.shape = BoxShape.rectangle,
  });

  final IconData icon;
  final Color tint;
  final double size;
  final double? iconSize;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.14),
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(RadhaRadii.radiusMd)
            : null,
        boxShadow: RadhaShadows.tile(tint),
      ),
      child: Icon(icon, size: iconSize ?? size * 0.45, color: tint),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:radha_app/design/tokens.dart';

/// Health classification levels for a product.
enum HealthLevel { healthy, moderate, unhealthy }

/// A colored chip indicating a product's health classification.
///
/// Colors are desaturated per anti-slop rule (max saturation < 80%):
///   * healthy  → green (success token — functional "fresh/healthy" cue)
///   * moderate → amber (warning token)
///   * unhealthy → rose (danger token)
class HealthLabelChip extends StatelessWidget {
  const HealthLabelChip({super.key, required this.label, required this.level});

  final String label;
  final HealthLevel level;

  Color get _backgroundColor {
    // Backgrounds reuse the brand semantic tokens at 15% alpha so the chip
    // stays in the same restrained, single-accent discipline as the app.
    switch (level) {
      case HealthLevel.healthy:
        return RadhaColors.success.withValues(alpha: 0.15);
      case HealthLevel.moderate:
        return RadhaColors.warning.withValues(alpha: 0.15);
      case HealthLevel.unhealthy:
        return RadhaColors.danger.withValues(alpha: 0.15);
    }
  }

  Color get _foregroundColor {
    switch (level) {
      case HealthLevel.healthy:
        return RadhaColors.success;
      case HealthLevel.moderate:
        return RadhaColors.warning;
      case HealthLevel.unhealthy:
        return RadhaColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space12,
        vertical: RadhaSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _foregroundColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

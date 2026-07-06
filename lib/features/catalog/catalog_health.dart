import 'package:flutter/material.dart';

import 'package:radha_app/design/tokens.dart';

/// Shared health-rating visuals for the catalog (browse card pill + detail
/// gauge). All derive from the backend's real assessment — a 0..100
/// `healthScore` and/or an A..E `healthGrade`. When neither is present the
/// helpers return null/neutral so the UI shows an honest "not assessed" state
/// rather than a fabricated rating.

/// Normalise the backend rating to a 0..5 scale (the familiar consumer scale,
/// matching the discovery flow). Prefers the numeric score; falls back to the
/// letter grade; null when unrated.
double? healthOutOfFive({String? grade, num? score}) {
  if (score != null) return (score / 20).clamp(0, 5).toDouble();
  switch (grade?.toUpperCase()) {
    case 'A':
      return 4.6;
    case 'B':
      return 3.8;
    case 'C':
      return 2.8;
    case 'D':
      return 1.8;
    case 'E':
      return 0.8;
  }
  return null;
}

/// Traffic-light colour for a rating. Neutral grey when unrated.
Color healthColor({String? grade, num? score}) {
  final five = healthOutOfFive(grade: grade, score: score);
  if (five == null) return RadhaColors.inkMuted;
  if (five >= 3.5) return RadhaColors.success;
  if (five >= 2.0) return RadhaColors.warning;
  return RadhaColors.danger;
}

/// Short verdict word. Empty when unrated (callers show "Not rated").
String healthLabel({String? grade, num? score}) {
  final five = healthOutOfFive(grade: grade, score: score);
  if (five == null) return '';
  if (five >= 4.0) return 'Excellent';
  if (five >= 3.0) return 'Good';
  if (five >= 2.0) return 'Fair';
  if (five >= 1.0) return 'Poor';
  return 'Avoid';
}

/// The square veg/non-veg mark used across Indian retail (green = veg, red =
/// non-veg). Shared by the browse grid + product detail.
class VegDot extends StatelessWidget {
  const VegDot({super.key, required this.isVeg, this.size = 12});

  final bool isVeg;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? RadhaColors.success : RadhaColors.danger;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Container(
          width: size * 0.5,
          height: size * 0.5,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

/// Compact rating pill for browse cards — a coloured chip with the /5 number
/// (or the letter grade as a fallback). Renders nothing when unrated.
class HealthRatingPill extends StatelessWidget {
  const HealthRatingPill({super.key, this.grade, this.score});

  final String? grade;
  final num? score;

  @override
  Widget build(BuildContext context) {
    final five = healthOutOfFive(grade: grade, score: score);
    if (five == null) return const SizedBox.shrink();
    final color = healthColor(grade: grade, score: score);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 12, color: Colors.white),
          const SizedBox(width: 2),
          Text(
            five.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

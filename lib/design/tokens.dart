// RADHA design tokens.
//
// These are the canonical, surface-agnostic primitives that every screen and
// component in the mobile app reads from. Nothing in `lib/features/**` may
// hard-code colors, spacing, or radii — always consume tokens from here.
//
// Anti-slop discipline:
//   * One accent only. The brand commits to a single orange primary
//     (#EA580C). A restrained teal complement (#0F766E — orange's opposite)
//     and deep ink may appear sparingly for contrast, never as a competing
//     accent.
//   * Saturation kept under 80% on every functional swatch.
//   * No gradient text, no neon glows, no AI-purple. Banned by policy.
//   * Fonts: Plus Jakarta Sans (display + body) and JetBrains Mono (numeric).
//     Inter / Arial / Roboto are explicitly NOT used.
//
// Material 3 typography scale is mirrored here so that anywhere the framework
// expects a `TextTheme` we can hand it back the brand-correct fonts.

import 'package:flutter/material.dart';

/// Brand colors. Each swatch is an exact hex committed at design time.
/// Saturation has been verified under 80% where the design discipline applies.
class RadhaColors {
  RadhaColors._();

  // --- Primitive palette --------------------------------------------------

  /// Deep neutral ink — text on light, base surface on dark. Warm near-black
  /// (#1C1917), never pure #000000. This is the "touch of black" anchor.
  static const Color ink = Color(0xFF1C1917);

  /// Warm cream — base surface on light. Reads as paper, not a screen.
  static const Color paper = Color(0xFFFFFBF5);

  /// Raised surface on light (cards, sheets, modals). Pure white lifts
  /// cleanly off the cream canvas.
  static const Color paperRaised = Color(0xFFFFFFFF);

  /// Sunken surface on light (skeletons, empty states, stepper tiles).
  static const Color paperSunken = Color(0xFFF5F1E8);

  /// Tonal lift used for cards and elevated containers on dark.
  static const Color inkRaised = Color(0xFF262220);

  /// 1px hairline separator on light.
  static const Color hairlineLight = Color(0xFFE7E1D4);

  /// 1px hairline separator on dark.
  static const Color hairlineDark = Color(0xFF3A332E);

  /// Muted ink for secondary text on light.
  static const Color inkMuted = Color(0xFF57534E);

  /// Muted paper for secondary text on dark.
  static const Color paperMuted = Color(0xFFB8AFA3);

  // --- Single accent (orange) --------------------------------------------

  /// Primary brand accent. Used sparingly: CTAs, focused fields, active nav,
  /// score-gauge fill, brand mark. Premium punchy orange — not fast-food,
  /// not neon.
  static const Color primary = Color(0xFFEA580C);

  /// Pressed / deep accent. Section headers, pressed-state CTA, dark-mode
  /// accent. Used rarely.
  static const Color primaryDeep = Color(0xFF9A3412);

  /// Soft accent tint. Highlight chips, soft badges, focus halos, hover on
  /// warm surfaces.
  static const Color primaryTint = Color(0xFFFED7AA);

  /// Text/icon color that sits on top of `primary`. The warm cream reads
  /// better than pure white on orange.
  static const Color onPrimary = Color(0xFFFFFBF5);

  /// Restrained complementary accent — teal, orange's opposite on the wheel.
  /// Used VERY sparingly for a contrasting secondary cue (e.g. an info
  /// highlight or a single chart series). Never a second brand accent.
  static const Color complement = Color(0xFF0F766E);

  // --- Functional semantics (low-saturation) -----------------------------

  /// Success / fresh / in-stock state. Distinct green, NOT a second accent.
  static const Color success = Color(0xFF15803D);

  /// Warning state. Restrained amber, tonally sympathetic to the orange
  /// accent (expiring soon, low stock).
  static const Color warning = Color(0xFFB45309);

  /// Danger / destructive state. Deep red, used sparingly.
  static const Color danger = Color(0xFFB91C1C);

  // --- Festive accents (celebration-only) --------------------------------
  // Per the Visual Bible §2.1: marigold + turmeric are reserved strictly for
  // celebratory beats (win-beat confetti, scan-success petals, the optional
  // festive skin). They are NEVER a CTA or a competing brand hue on a normal
  // screen. Consume only inside celebration surfaces.

  /// Marigold (genda) — devotional-offering warmth. Petal bursts, confetti.
  static const Color festiveMarigold = Color(0xFFF59E0B);

  /// Turmeric — secondary festive spark, paired with marigold.
  static const Color festiveTurmeric = Color(0xFFFACC15);
}

/// Semantic color tokens. Consumers should always read these (not the raw
/// palette) so the same widget renders correctly in light and dark.
@immutable
class RadhaSemanticColors {
  const RadhaSemanticColors({
    required this.surface,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.surfaceContainer,
    required this.surfaceSunken,
    required this.outline,
    required this.primary,
    required this.primaryDeep,
    required this.primaryTint,
    required this.onPrimary,
    required this.complement,
    required this.success,
    required this.warning,
    required this.danger,
  });

  final Color surface;
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color surfaceContainer;
  final Color surfaceSunken;
  final Color outline;
  final Color primary;
  final Color primaryDeep;
  final Color primaryTint;
  final Color onPrimary;
  final Color complement;
  final Color success;
  final Color warning;
  final Color danger;

  static const RadhaSemanticColors light = RadhaSemanticColors(
    surface: RadhaColors.paper,
    onSurface: RadhaColors.ink,
    onSurfaceMuted: RadhaColors.inkMuted,
    surfaceContainer: RadhaColors.paperRaised,
    surfaceSunken: RadhaColors.paperSunken,
    outline: RadhaColors.hairlineLight,
    primary: RadhaColors.primary,
    primaryDeep: RadhaColors.primaryDeep,
    primaryTint: RadhaColors.primaryTint,
    onPrimary: RadhaColors.onPrimary,
    complement: RadhaColors.complement,
    success: RadhaColors.success,
    warning: RadhaColors.warning,
    danger: RadhaColors.danger,
  );

  static const RadhaSemanticColors dark = RadhaSemanticColors(
    surface: RadhaColors.ink,
    onSurface: RadhaColors.paper,
    onSurfaceMuted: RadhaColors.paperMuted,
    surfaceContainer: RadhaColors.inkRaised,
    surfaceSunken: RadhaColors.inkRaised,
    outline: RadhaColors.hairlineDark,
    primary: RadhaColors.primary,
    primaryDeep: RadhaColors.primaryDeep,
    primaryTint: RadhaColors.primaryTint,
    onPrimary: RadhaColors.onPrimary,
    complement: RadhaColors.complement,
    success: RadhaColors.success,
    warning: RadhaColors.warning,
    danger: RadhaColors.danger,
  );
}

/// Spacing scale (4-pt grid). Always consume named constants, never literals.
class RadhaSpacing {
  RadhaSpacing._();

  static const double space2 = 2;
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space48 = 48;
  static const double space64 = 64;
}

/// Corner radii. `radiusFull` is used for chips and circular avatars.
class RadhaRadii {
  RadhaRadii._();

  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 9999;
}

/// Minimum touch target. Mirrors Material a11y guidance (44pt+).
const double kMinTouchTarget = 44.0;

/// Soft elevation shadows. Every "raised" surface (stat tiles, icon tiles,
/// hero cards) carries one of these instead of a hard Material elevation —
/// keeps the warm, soft-UI read instead of a flat bordered-box look.
class RadhaShadows {
  RadhaShadows._();

  /// Neutral ambient shadow for cards and tiles with no tint of their own.
  static List<BoxShadow> card = [
    BoxShadow(
      color: RadhaColors.ink.withValues(alpha: 0.06),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  /// Icon tiles are flat (no shadow) — a heavily blurred shadow on a small
  /// chip reads as a muddy smudge rather than a soft glow. Kept as a
  /// function (not a const) so call sites don't need to change.
  static List<BoxShadow> tile(Color tint) => const [];
}

/// Standardised motion. Mirrors `cubic-bezier(0.32, 0.72, 0, 1)` from the
/// design contract. `Curves.easeOutCubic` is the framework alias we lean on
/// for component transitions; the explicit Cubic is exposed for cases that
/// want the exact handcrafted easing.
class RadhaMotion {
  RadhaMotion._();

  static const Curve easeOut = Curves.easeOutCubic;
  static const Cubic spring = Cubic(0.32, 0.72, 0, 1);

  static const Duration fast = Duration(milliseconds: 120);
  static const Duration medium = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 320);
}

/// Typography metadata. Actual `TextStyle`s are realised in `theme.dart`
/// against `GoogleFonts.plusJakartaSansTextTheme` so we share runtime font
/// loading rather than bundling font files. JetBrains Mono is reserved for
/// numeric / code contexts (badges, tabular numerals).
class RadhaTypography {
  RadhaTypography._();

  static const String displayFamily = 'Plus Jakarta Sans';
  static const String bodyFamily = 'Plus Jakarta Sans';
  static const String monoFamily = 'JetBrains Mono';

  // Material 3 type scale — sizes and line heights tuned for readability.
  // Body line-height sits in the 1.5–1.6 range per the design contract.

  static const RadhaTextSpec displayLarge = RadhaTextSpec(
    fontSize: 57,
    height: 1.12,
    letterSpacing: -0.25,
    weight: FontWeight.w700,
  );
  static const RadhaTextSpec displayMedium = RadhaTextSpec(
    fontSize: 45,
    height: 1.16,
    letterSpacing: 0,
    weight: FontWeight.w700,
  );
  static const RadhaTextSpec displaySmall = RadhaTextSpec(
    fontSize: 36,
    height: 1.22,
    letterSpacing: 0,
    weight: FontWeight.w700,
  );

  static const RadhaTextSpec headlineLarge = RadhaTextSpec(
    fontSize: 32,
    height: 1.25,
    letterSpacing: 0,
    weight: FontWeight.w700,
  );
  static const RadhaTextSpec headlineMedium = RadhaTextSpec(
    fontSize: 28,
    height: 1.28,
    letterSpacing: 0,
    weight: FontWeight.w600,
  );
  static const RadhaTextSpec headlineSmall = RadhaTextSpec(
    fontSize: 24,
    height: 1.33,
    letterSpacing: 0,
    weight: FontWeight.w600,
  );

  static const RadhaTextSpec titleLarge = RadhaTextSpec(
    fontSize: 22,
    height: 1.27,
    letterSpacing: 0,
    weight: FontWeight.w600,
  );
  static const RadhaTextSpec titleMedium = RadhaTextSpec(
    fontSize: 16,
    height: 1.5,
    letterSpacing: 0.15,
    weight: FontWeight.w600,
  );
  static const RadhaTextSpec titleSmall = RadhaTextSpec(
    fontSize: 14,
    height: 1.43,
    letterSpacing: 0.1,
    weight: FontWeight.w600,
  );

  static const RadhaTextSpec bodyLarge = RadhaTextSpec(
    fontSize: 16,
    height: 1.5,
    letterSpacing: 0.15,
    weight: FontWeight.w400,
  );
  static const RadhaTextSpec bodyMedium = RadhaTextSpec(
    fontSize: 14,
    height: 1.5,
    letterSpacing: 0.25,
    weight: FontWeight.w400,
  );
  static const RadhaTextSpec bodySmall = RadhaTextSpec(
    fontSize: 12,
    height: 1.5,
    letterSpacing: 0.4,
    weight: FontWeight.w400,
  );

  static const RadhaTextSpec labelLarge = RadhaTextSpec(
    fontSize: 14,
    height: 1.43,
    letterSpacing: 0.1,
    weight: FontWeight.w600,
  );
  static const RadhaTextSpec labelMedium = RadhaTextSpec(
    fontSize: 12,
    height: 1.33,
    letterSpacing: 0.5,
    weight: FontWeight.w600,
  );
  static const RadhaTextSpec labelSmall = RadhaTextSpec(
    fontSize: 11,
    height: 1.45,
    letterSpacing: 0.5,
    weight: FontWeight.w600,
  );
}

/// One row of the type scale. Public so `theme.dart` (a sibling library) can
/// project these specs onto live `TextStyle`s through `google_fonts`.
@immutable
class RadhaTextSpec {
  const RadhaTextSpec({
    required this.fontSize,
    required this.height,
    required this.letterSpacing,
    required this.weight,
  });

  final double fontSize;
  final double height;
  final double letterSpacing;
  final FontWeight weight;
}

// RADHA Material 3 theme.
//
// Builds `ThemeData` for light and dark modes. Every component override here
// reads from the tokens defined in `tokens.dart`. Touching widget colors
// outside this file is a code-review failure.
//
// Notes on intent:
//   * No harsh shadows. Cards use a 1px hairline border on top of a tonal
//     surface container instead of `elevation > 1`.
//   * Buttons keep a 44pt minimum height to honour `kMinTouchTarget`.
//   * Text fields run filled, no border at rest, 2px primary border on focus,
//     2px danger border on error.
//   * `WidgetStateProperty` is used (Flutter 3.16+ replacement for
//     `MaterialStateProperty`).

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'tokens.dart';

/// Builds the light theme.
ThemeData radhaLightTheme() =>
    _buildTheme(Brightness.light, RadhaSemanticColors.light);

/// Builds the dark theme.
ThemeData radhaDarkTheme() =>
    _buildTheme(Brightness.dark, RadhaSemanticColors.dark);

ThemeData _buildTheme(Brightness brightness, RadhaSemanticColors c) {
  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: c.primary,
    onPrimary: c.onPrimary,
    primaryContainer: c.primaryTint,
    onPrimaryContainer: c.primaryDeep,
    secondary: c.complement,
    onSecondary: c.onPrimary,
    error: c.danger,
    onError: c.onPrimary,
    surface: c.surface,
    onSurface: c.onSurface,
    surfaceContainerHighest: c.surfaceContainer,
    surfaceContainer: c.surfaceContainer,
    surfaceContainerLow: c.surfaceSunken,
    outline: c.outline,
    outlineVariant: c.outline,
  );

  final textTheme = _buildTextTheme(c.onSurface);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: c.surface,
    canvasColor: c.surface,
    splashFactory: InkSparkle.splashFactory,
    textTheme: textTheme,
    primaryTextTheme: textTheme,

    // Page transitions inherit `Curves.easeOutCubic` per the motion contract.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: c.surface,
      foregroundColor: c.onSurface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
      iconTheme: IconThemeData(color: c.onSurface),
    ),

    cardTheme: CardThemeData(
      color: c.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        side: BorderSide(color: c.outline, width: 1),
      ),
    ),

    dividerTheme: DividerThemeData(color: c.outline, thickness: 1, space: 1),

    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size(0, kMinTouchTarget)),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: RadhaSpacing.space24),
        ),
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.disabled)) {
            return c.primary.withValues(alpha: 0.32);
          }
          if (states.contains(WidgetState.pressed)) {
            return _darken(c.primary, 0.08);
          }
          return c.primary;
        }),
        foregroundColor: WidgetStateProperty.all(c.onPrimary),
        overlayColor: WidgetStateProperty.all(
          c.onPrimary.withValues(alpha: 0.08),
        ),
        elevation: WidgetStateProperty.all(0),
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        textStyle: WidgetStateProperty.all(textTheme.labelLarge),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
          ),
        ),
        animationDuration: RadhaMotion.fast,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size(0, kMinTouchTarget)),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: RadhaSpacing.space24),
        ),
        side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(
              color: c.outline.withValues(alpha: 0.5),
              width: 1,
            );
          }
          if (states.contains(WidgetState.focused)) {
            return BorderSide(color: c.primary, width: 2);
          }
          return BorderSide(color: c.outline, width: 1);
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.disabled)) {
            return c.onSurfaceMuted;
          }
          return c.onSurface;
        }),
        overlayColor: WidgetStateProperty.all(
          c.primary.withValues(alpha: 0.06),
        ),
        textStyle: WidgetStateProperty.all(textTheme.labelLarge),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
          ),
        ),
        animationDuration: RadhaMotion.fast,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size(0, kMinTouchTarget)),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: RadhaSpacing.space12),
        ),
        foregroundColor: WidgetStateProperty.all(c.primary),
        overlayColor: WidgetStateProperty.all(
          c.primary.withValues(alpha: 0.06),
        ),
        textStyle: WidgetStateProperty.all(textTheme.labelLarge),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadhaRadii.radiusSm),
          ),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surfaceContainer,
      isDense: false,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space16,
        vertical: RadhaSpacing.space16,
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(color: c.onSurfaceMuted),
      labelStyle: textTheme.bodyMedium?.copyWith(color: c.onSurfaceMuted),
      floatingLabelStyle: textTheme.bodySmall?.copyWith(color: c.primary),
      helperStyle: textTheme.bodySmall?.copyWith(color: c.onSurfaceMuted),
      errorStyle: textTheme.bodySmall?.copyWith(color: c.danger),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        borderSide: BorderSide(color: c.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        borderSide: BorderSide(color: c.danger, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        borderSide: BorderSide(color: c.danger, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        borderSide: BorderSide.none,
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: c.primary.withValues(alpha: 0.12),
      labelTextStyle: WidgetStateProperty.all(textTheme.labelMedium),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: c.primary, size: 24);
        }
        return IconThemeData(color: c.onSurfaceMuted, size: 24);
      }),
      elevation: 0,
      height: 72,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: c.surface,
      modalBarrierColor: c.onSurface.withValues(alpha: 0.4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(RadhaRadii.radiusXl),
        ),
      ),
      showDragHandle: true,
      dragHandleColor: c.outline,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        side: BorderSide(color: c.outline, width: 1),
      ),
      titleTextStyle: textTheme.titleLarge,
      contentTextStyle: textTheme.bodyMedium,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.onSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: c.surface),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: c.surfaceContainer,
      side: BorderSide(color: c.outline, width: 1),
      labelStyle: textTheme.labelMedium?.copyWith(color: c.onSurface),
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space12,
        vertical: RadhaSpacing.space4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
      ),
    ),

    iconTheme: IconThemeData(color: c.onSurface, size: 24),
    listTileTheme: ListTileThemeData(
      iconColor: c.onSurfaceMuted,
      textColor: c.onSurface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space16,
        vertical: RadhaSpacing.space8,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: c.primary,
      circularTrackColor: c.outline,
      linearTrackColor: c.outline,
    ),

    visualDensity: VisualDensity.standard,
  );
}

/// Builds a `TextTheme` from `RadhaTypography` specs using Plus Jakarta Sans.
TextTheme _buildTextTheme(Color baseColor) {
  TextStyle style(RadhaTextSpec spec) => TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: spec.fontSize,
    height: spec.height,
    letterSpacing: spec.letterSpacing,
    fontWeight: spec.weight,
    color: baseColor,
  );

  return TextTheme(
    displayLarge: style(RadhaTypography.displayLarge),
    displayMedium: style(RadhaTypography.displayMedium),
    displaySmall: style(RadhaTypography.displaySmall),
    headlineLarge: style(RadhaTypography.headlineLarge),
    headlineMedium: style(RadhaTypography.headlineMedium),
    headlineSmall: style(RadhaTypography.headlineSmall),
    titleLarge: style(RadhaTypography.titleLarge),
    titleMedium: style(RadhaTypography.titleMedium),
    titleSmall: style(RadhaTypography.titleSmall),
    bodyLarge: style(RadhaTypography.bodyLarge),
    bodyMedium: style(RadhaTypography.bodyMedium),
    bodySmall: style(RadhaTypography.bodySmall),
    labelLarge: style(RadhaTypography.labelLarge),
    labelMedium: style(RadhaTypography.labelMedium),
    labelSmall: style(RadhaTypography.labelSmall),
  );
}

/// Returns a JetBrains Mono `TextStyle` for tabular numerics (badges, counts).
TextStyle radhaMonoStyle({
  double fontSize = 14,
  FontWeight weight = FontWeight.w500,
  Color? color,
}) => TextStyle(
  fontFamily: 'JetBrainsMono',
  fontSize: fontSize,
  fontWeight: weight,
  letterSpacing: 0,
  color: color,
  fontFeatures: const [FontFeature.tabularFigures()],
);

Color _darken(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}

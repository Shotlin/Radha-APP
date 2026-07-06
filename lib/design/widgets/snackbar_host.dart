// Global snackbar host.
//
// Backed by a single `GlobalKey<ScaffoldMessengerState>` wired into
// `MaterialApp.router(scaffoldMessengerKey: ...)` from `main.dart`. With
// the key in place, any code path can fire a snackbar without needing a
// `BuildContext` — handy for async error reporting (`FlutterError.onError`,
// the sync notifier, etc.).
//
// Three visual variants — `success`, `info`, and `error` — encode their
// intent through color and icon. Layout matches the design contract:
//   * 12px corner radius (RadhaRadii.radiusMd),
//   * 16px horizontal padding (RadhaSpacing.space16),
//   * 600-weight label (Plus Jakarta Sans via the theme),
//   * floating behaviour, swipe-to-dismiss enabled,
//   * 3-second display duration,
//   * icon at start, label flexes, single-line ellipsis on overflow.

import 'package:flutter/material.dart';

import '../tokens.dart';

/// Global key used by `MaterialApp.router(scaffoldMessengerKey:)` so any
/// code path can show a snackbar without a `BuildContext`.
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>(debugLabel: 'rootScaffoldMessenger');

/// Visual flavour of a global snackbar.
enum _SnackbarVariant { success, info, error }

/// Static facade for showing globally-routed snackbars.
///
/// Usage:
///
///   SnackbarHost.success('Task created');
///   SnackbarHost.info('You\'re offline — work will sync later');
///   SnackbarHost.error('Could not save expiry, try again');
class SnackbarHost {
  SnackbarHost._();

  /// How long each variant remains on screen before auto-dismiss.
  static const Duration _displayDuration = Duration(seconds: 3);

  /// Show a green confirmation snackbar.
  static void success(String message) =>
      _show(message: message, variant: _SnackbarVariant.success);

  /// Show a neutral surface-tint snackbar for informational messages.
  static void info(String message) =>
      _show(message: message, variant: _SnackbarVariant.info);

  /// Show a rose-coloured destructive/failure snackbar.
  static void error(String message) =>
      _show(message: message, variant: _SnackbarVariant.error);

  static void _show({
    required String message,
    required _SnackbarVariant variant,
  }) {
    final messengerState = scaffoldMessengerKey.currentState;
    if (messengerState == null) {
      // No messenger mounted yet (e.g. snackbar fired before the first
      // frame, or in a test that didn't install the key). Drop silently —
      // failing here would surface an opaque error far from the call site.
      return;
    }
    messengerState
      ..clearSnackBars()
      ..showSnackBar(_buildSnackbar(message: message, variant: variant));
  }

  /// Visible for tests — builds the SnackBar widget for a given variant
  /// without actually pushing it through a ScaffoldMessenger.
  @visibleForTesting
  static SnackBar buildForTest({
    required String message,
    required SnackbarVariantTestHandle variant,
  }) {
    return _buildSnackbar(message: message, variant: variant._inner);
  }

  static SnackBar _buildSnackbar({
    required String message,
    required _SnackbarVariant variant,
  }) {
    final palette = _paletteFor(variant);

    return SnackBar(
      backgroundColor: palette.background,
      behavior: SnackBarBehavior.floating,
      duration: _displayDuration,
      dismissDirection: DismissDirection.horizontal,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space16,
        vertical: RadhaSpacing.space12,
      ),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(palette.icon, color: palette.foreground, size: 20),
          const SizedBox(width: RadhaSpacing.space12),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                color: palette.foreground,
                fontFamily: RadhaTypography.bodyFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.43,
                letterSpacing: 0.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  static _SnackbarPalette _paletteFor(_SnackbarVariant v) {
    switch (v) {
      case _SnackbarVariant.success:
        return const _SnackbarPalette(
          background: RadhaColors.success,
          foreground: RadhaColors.onPrimary,
          icon: Icons.check_circle_outline,
        );
      case _SnackbarVariant.info:
        return const _SnackbarPalette(
          background: RadhaColors.paperRaised,
          foreground: RadhaColors.ink,
          icon: Icons.info_outline,
        );
      case _SnackbarVariant.error:
        return const _SnackbarPalette(
          background: RadhaColors.danger,
          foreground: RadhaColors.onPrimary,
          icon: Icons.error_outline,
        );
    }
  }
}

@immutable
class _SnackbarPalette {
  const _SnackbarPalette({
    required this.background,
    required this.foreground,
    required this.icon,
  });
  final Color background;
  final Color foreground;
  final IconData icon;
}

/// Test-visible mirror of the private `_SnackbarVariant` enum so unit tests
/// can request a specific variant without us having to expose the enum
/// itself (which would invite production callers to start passing variant
/// arguments around — defeating the purpose of the three named methods).
class SnackbarVariantTestHandle {
  const SnackbarVariantTestHandle._(this._inner);
  final _SnackbarVariant _inner;

  static const SnackbarVariantTestHandle success = SnackbarVariantTestHandle._(
    _SnackbarVariant.success,
  );
  static const SnackbarVariantTestHandle info = SnackbarVariantTestHandle._(
    _SnackbarVariant.info,
  );
  static const SnackbarVariantTestHandle error = SnackbarVariantTestHandle._(
    _SnackbarVariant.error,
  );
}

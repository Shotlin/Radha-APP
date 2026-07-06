// Global error boundary.
//
// Wraps the entire app in `main()` so we can:
//
//   1. Replace Flutter's red-screen-of-death with a brand-correct fallback
//      via `ErrorWidget.builder`. Synchronous build-phase exceptions never
//      reach the user as a stack trace.
//   2. Capture asynchronous exceptions reported through `FlutterError.onError`
//      and `PlatformDispatcher.instance.onError`, surface a concise message
//      to the user via `SnackbarHost.error`, and forward to a future Sentry
//      hook. The hook is intentionally a no-op today — Task 20 only asks
//      for the wiring; the integration lands in a later observability task.
//
// The build-phase fallback intentionally does NOT use `runZonedGuarded` —
// Flutter 3.3+ recommends `PlatformDispatcher.instance.onError` for async
// errors instead, and `runZonedGuarded` interferes with the framework's
// own zone (BindingBase complains in debug). The two hooks above cover
// every uncaught path the framework actually surfaces.
//
// Visual:
//   * Soft surface background — no harsh red.
//   * `error_outline` glyph in the danger token.
//   * "Something went wrong" headline.
//   * Friendly subtitle that does not echo the framework error string
//     (PII / tokens occasionally end up in stack traces).
//   * Two CTAs: "Report" (primary, orange) and "Retry" (secondary).
//   * 44pt+ touch targets via the theme'd buttons.

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../tokens.dart';
import 'primary_button.dart';
import 'secondary_button.dart';
import 'snackbar_host.dart';

/// Pluggable hook for forwarding error reports. Defaults to a debug print;
/// the observability task can swap this out for a Sentry call.
typedef ErrorReporter =
    void Function(Object error, StackTrace? stackTrace, {String? hint});

/// Default reporter — debug-print only so the rest of the codebase compiles
/// without a Sentry dependency. Overridable via [ErrorBoundary.reporter].
void _defaultReporter(Object error, StackTrace? stackTrace, {String? hint}) {
  if (kDebugMode) {
    debugPrint('[ErrorBoundary] ${hint ?? "uncaught"}: $error');
  }
}

/// Returns true for errors that should be silently logged but NOT surfaced to
/// the user as a snackbar. These are background best-effort operations that
/// degrade gracefully without user action (e.g. optional font downloads).
bool _isSilentError(Object error) {
  final msg = error.toString();
  // google_fonts downloads fonts at runtime from fonts.gstatic.com. When the
  // device has no internet access the fetch fails and the package falls back to
  // the system font — the app continues working normally. There is nothing the
  // user can or should do about this.
  return msg.contains('Failed to load font') ||
      msg.contains('fonts.gstatic.com');
}

/// Wraps the app and installs the global error hooks.
///
/// Use exactly once at the root of `main()`:
///
/// ```dart
/// runApp(
///   ProviderScope(
///     child: ErrorBoundary(child: const RadhaApp()),
///   ),
/// );
/// ```
class ErrorBoundary extends StatefulWidget {
  const ErrorBoundary({
    required this.child,
    this.reporter = _defaultReporter,
    super.key,
  });

  /// The widget tree this boundary protects.
  final Widget child;

  /// Forwarder used when an async error is caught. Tests can override it
  /// to assert the error was observed without poking real Sentry plumbing.
  final ErrorReporter reporter;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  @override
  void initState() {
    super.initState();
    _installHooks();
  }

  void _installHooks() {
    // 1. Replace the framework's red-on-yellow `ErrorWidget` with a
    //    brand-correct fallback. This handles synchronous build-phase
    //    errors thrown from any descendant.
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // Forward to the reporter so it still lands in observability.
      widget.reporter(
        details.exception,
        details.stack,
        hint: 'build-phase error',
      );
      return _ErrorFallback(
        // We deliberately do NOT show `details.exception.toString()` to
        // the end user — error messages occasionally embed tokens / PII
        // and the screen is shipped to production builds.
        details: details,
      );
    };

    // 2. Forward async framework errors to our reporter and surface a
    //    short message via the global snackbar host.
    final defaultFlutterOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      widget.reporter(
        details.exception,
        details.stack,
        hint: 'FlutterError.onError',
      );
      if (!_isSilentError(details.exception)) {
        SnackbarHost.error('Something went wrong. Please try again.');
      }
      // Preserve the framework's own logging for debug-mode visibility.
      defaultFlutterOnError?.call(details);
    };

    // 3. Catch top-level uncaught errors that escape Flutter's zone. The
    //    handler returns `true` to mark them as handled.
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      widget.reporter(error, stack, hint: 'PlatformDispatcher.onError');
      if (!_isSilentError(error)) {
        SnackbarHost.error('Something went wrong. Please try again.');
      }
      return true;
    };
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Brand-correct fallback rendered when a descendant throws during build.
class _ErrorFallback extends StatelessWidget {
  const _ErrorFallback({required this.details});

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    // We can't rely on the inherited theme here — `ErrorWidget.builder`
    // can fire before the app's `MaterialApp` is mounted, or inside a
    // subtree that lost its `Material` ancestor. Wrap the fallback in a
    // self-contained `MaterialApp` so the theme'd buttons always render.
    final brightness = PlatformDispatcher.instance.platformBrightness;
    final palette = brightness == Brightness.dark
        ? RadhaSemanticColors.dark
        : RadhaSemanticColors.light;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: brightness,
        scaffoldBackgroundColor: palette.surface,
        colorScheme: ColorScheme(
          brightness: brightness,
          primary: palette.primary,
          onPrimary: palette.onPrimary,
          secondary: palette.primary,
          onSecondary: palette.onPrimary,
          error: palette.danger,
          onError: palette.onPrimary,
          surface: palette.surface,
          onSurface: palette.onSurface,
        ),
      ),
      home: Scaffold(
        backgroundColor: palette.surface,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Padding(
                padding: const EdgeInsets.all(RadhaSpacing.space24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline, size: 32, color: palette.danger),
                    const SizedBox(height: RadhaSpacing.space16),
                    Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontFamily: RadhaTypography.displayFamily,
                        fontSize: 24,
                        height: 1.33,
                        fontWeight: FontWeight.w600,
                        color: palette.onSurface,
                      ),
                    ),
                    const SizedBox(height: RadhaSpacing.space8),
                    Text(
                      'A part of the app crashed unexpectedly. '
                      'You can report this to our team or try again.',
                      style: TextStyle(
                        fontFamily: RadhaTypography.bodyFamily,
                        fontSize: 14,
                        height: 1.5,
                        color: palette.onSurfaceMuted,
                      ),
                    ),
                    const SizedBox(height: RadhaSpacing.space24),
                    PrimaryButton(
                      label: 'Report', // l10n-ignore: crash fallback must not depend on the l10n layer
                      icon: Icons.flag_outlined,
                      expand: true,
                      onPressed: () {
                        // The reporter has already received the details
                        // via `ErrorWidget.builder`. This CTA acknowledges
                        // the report so the user knows something happened.
                        SnackbarHost.success(
                          'Thanks — our team has been notified.',
                        );
                      },
                    ),
                    const SizedBox(height: RadhaSpacing.space12),
                    SecondaryButton(
                      label: 'Retry', // l10n-ignore: crash fallback must not depend on the l10n layer
                      icon: Icons.refresh,
                      expand: true,
                      onPressed: () {
                        // Retrying a build-phase error in place is not
                        // reliable from inside the failed subtree — the
                        // safest UX is to ask the user to navigate away
                        // and back. We surface that hint via snackbar.
                        SnackbarHost.info(
                          'Tap Home or restart the app to try again.',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

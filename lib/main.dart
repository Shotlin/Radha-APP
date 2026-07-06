import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/auth/session_resume_guard.dart';
import 'core/auth/session_storage.dart';
import 'core/i18n/locale_controller.dart';
import 'core/network/token_provider.dart';
import 'core/router/app_router.dart';
import 'design/theme.dart';
import 'design/widgets/error_boundary.dart';
import 'design/widgets/snackbar_host.dart';
import 'features/settings/settings_preferences.dart';
import 'features/splash/bootstrap_controller.dart';
import 'features/sync/conflict_banner.dart';
import 'l10n/generated/app_localizations.dart';

void main() {
  // `ErrorBoundary` installs `ErrorWidget.builder`, `FlutterError.onError`,
  // and `PlatformDispatcher.instance.onError` from its `initState`. Mounting
  // it as the topmost widget guarantees those hooks are in place before any
  // descendant has a chance to throw.
  runApp(
    ProviderScope(
      overrides: [
        // Wire secure-storage-backed [TokenStore] into the networking layer.
        // Task 2 declared `tokenStoreProvider` as an `UnimplementedError`
        // placeholder; without this override the first request would crash.
        tokenStoreProvider.overrideWith(
          (ref) => ref.watch(sessionStorageTokenStoreProvider),
        ),
      ],
      child: const ErrorBoundary(child: RadhaApp()),
    ),
  );
}

/// Application root. Builds a `MaterialApp.router` that delegates routing to
/// the `appRouterProvider` defined in `core/router/app_router.dart`.
class RadhaApp extends ConsumerWidget {
  const RadhaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watching the bootstrap controller here kicks off cold-start work
    // (package_info, device_id, session hydration, optional /auth/me) on
    // first build. We intentionally ignore its `AsyncValue` — the splash
    // screen renders the loading visual and the router's `refreshListenable`
    // handles the navigation hand-off when auth + onboarding settle.
    ref.watch(bootstrapControllerProvider);

    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeControllerProvider);
    final textScale = ref.watch(textScaleProvider);

    return MaterialApp.router(
      title: 'RADHA',
      debugShowCheckedModeBanner: false,
      // Bind the global ScaffoldMessenger so `SnackbarHost.success/info/error`
      // can surface messages from anywhere — including async error handlers
      // installed by `ErrorBoundary` that have no `BuildContext`.
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: radhaLightTheme(),
      darkTheme: radhaDarkTheme(),
      themeMode: ThemeMode.light, // dark mode disabled; themeMode provider kept for future re-enable
      locale: locale,
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      // Builder injects the user's text-scale preference into MediaQuery so
      // every Text widget reflects the choice without per-screen plumbing.
      // Wraps the conflict banner overlay so sync conflicts surface above
      // the bottom-nav shell (FE-34).
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(textScale.scale),
          ),
          child: SessionResumeGuard(
            child: ConflictBannerOverlay(child: child ?? const SizedBox.shrink()),
          ),
        );
      },
    );
  }
}

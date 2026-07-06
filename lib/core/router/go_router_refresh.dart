import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bridges Riverpod providers to GoRouter's `refreshListenable` API.
///
/// Subscribes to one or more providers and calls [notifyListeners] whenever
/// any of them change, so the router re-evaluates its `redirect` callback.
///
/// Usage:
/// ```dart
/// final refresh = GoRouterRefreshNotifier(ref, [
///   authControllerProvider,
///   onboardingFlagControllerProvider,
/// ]);
/// GoRouter(refreshListenable: refresh, ...);
/// ```
class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(
    Ref ref,
    List<ProviderListenable<Object?>> listenables,
  ) {
    for (final listenable in listenables) {
      ref.listen<Object?>(listenable, (_, _) => notifyListeners());
    }
  }
}

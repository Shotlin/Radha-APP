import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session_storage.dart';

/// Tiny state machine over the `onboarding_complete` flag in secure storage.
/// Exposed as an `AsyncNotifier<bool>` so the router can wait on the initial
/// read (returns `false` until secure storage answers, then settles into the
/// real value).
class OnboardingFlagController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final storage = ref.read(sessionStorageProvider);
    return storage.readOnboardingComplete();
  }

  /// Marks the user as having seen onboarding. The router will stop pushing
  /// `/onboarding` after this resolves.
  Future<void> markComplete() async {
    final storage = ref.read(sessionStorageProvider);
    await storage.setOnboardingComplete(true);
    state = const AsyncData<bool>(true);
  }

  /// Test hook + "reset onboarding" debug action. Production UI never calls
  /// this.
  Future<void> reset() async {
    final storage = ref.read(sessionStorageProvider);
    await storage.setOnboardingComplete(false);
    state = const AsyncData<bool>(false);
  }
}

/// Global handle for the onboarding flag. The router reads this before every
/// redirect decision.
final onboardingFlagControllerProvider =
    AsyncNotifierProvider<OnboardingFlagController, bool>(
      OnboardingFlagController.new,
    );

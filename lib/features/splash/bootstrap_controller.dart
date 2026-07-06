// App bootstrap controller.
//
// Owns the work that runs once at cold start, before the first user-facing
// route is permitted to render. Specifically:
//
//   1. Load `package_info_plus` for version / build metadata.
//   2. Mint or read the persisted `device_id` from secure storage.
//   3. Hydrate the [AuthController] from secure storage and force the
//      [OnboardingFlagController] to build so the router's
//      `refreshListenable` sees both controllers settle in lock-step.
//   4. If a session was recovered, optimistically call `/auth/me` to refresh
//      roles + storeAccess. Best-effort — any [ApiException] is swallowed
//      and the persisted session is kept untouched.
//   5. Race the bootstrap work against a 600 ms floor so the splash is
//      perceptible without ever feeling laggy.
//
// The controller never navigates. It exists to drive a single
// `AsyncValue<BootstrapResult>` that the splash widget watches; the router's
// global `redirect` callback is what actually moves the user off `/splash`
// once auth + onboarding state has settled.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/auth/auth_repository.dart';
import '../../core/auth/auth_session.dart';
import '../../core/auth/session_storage.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/offline/sync_service.dart';
import '../../core/onboarding/onboarding_flag_controller.dart';

/// Minimum splash dwell time. Below this the splash flickers and feels like
/// a glitch; above ~800 ms it starts to feel laggy. 600 ms is the spec value.
const Duration _kSplashFloor = Duration(milliseconds: 600);

/// Result surfaced to the splash widget once bootstrap completes. Keeps the
/// payload small — anything routing-related is read from the auth /
/// onboarding controllers directly.
class BootstrapResult {
  const BootstrapResult({
    required this.packageInfo,
    required this.deviceId,
    required this.hasSession,
  });

  final PackageInfo packageInfo;
  final String deviceId;
  final bool hasSession;
}

/// Riverpod controller that runs the bootstrap sequence once and caches the
/// result. Consumers (the splash screen, `RadhaApp.build`) `watch` this
/// provider; subsequent rebuilds reuse the cached `AsyncData` rather than
/// re-running the work.
class BootstrapController extends AsyncNotifier<BootstrapResult> {
  @override
  Future<BootstrapResult> build() async {
    // Enforce a perceptible-but-not-laggy splash floor by measuring how long
    // the real work took and only sleeping for the *remaining* time. We
    // deliberately avoid the old `Future.wait([work, Future.delayed(floor)])`
    // pattern: if the work finished (or threw) before the floor elapsed, that
    // standalone delayed future left an orphaned pending Timer, which trips
    // `flutter_test`'s pending-timer guard and is a real teardown leak. By
    // awaiting the remainder inline, the timer is always part of this future
    // chain and can never outlive the bootstrap.
    final stopwatch = Stopwatch()..start();
    final result = await _runBootstrap();
    final remaining = _kSplashFloor - stopwatch.elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
    return result;
  }

  Future<BootstrapResult> _runBootstrap() async {
    final storage = ref.read(sessionStorageProvider);
    final repo = ref.read(authRepositoryProvider);

    // Independent reads in parallel — none depend on each other.
    final packageInfoFuture = PackageInfo.fromPlatform();
    final deviceIdFuture = storage.getOrCreateDeviceId();
    final sessionFuture = repo.currentSession();

    // Force the auth + onboarding controllers to build so the router's
    // `refreshListenable` observes them transition out of `AsyncLoading` in
    // lockstep with the splash dwell. We `await` after the optimistic
    // `/auth/me` step so we don't race the state mutation below.
    final onboardingFuture = ref.read(onboardingFlagControllerProvider.future);
    final authControllerFuture = ref.read(authControllerProvider.future);

    final session = await sessionFuture;

    // Optimistic refresh: only fire `/auth/me` when we already have a token
    // in secure storage. Failure is non-fatal — the persisted session is
    // perfectly usable for the next API call (the auth interceptor will
    // rotate on 401 if needed).
    if (session != null) {
      try {
        final api = ref.read(apiClientProvider);
        final me = await api.me();
        final refreshed = session.copyWith(
          userId: me.user.id,
          tenantId: me.user.tenantId,
          roles: me.roles,
          stores: me.storeAccess
              .map(_storeAccessFromDto)
              .toList(growable: false),
          // Carry forward any stored selection; auto-select when there is
          // exactly one store and none was previously chosen. This is the
          // cold-start fix for business users whose session was written
          // before the auto-select logic existed.
          selectedStoreId: session.selectedStoreId ??
              (me.storeAccess.length == 1
                  ? me.storeAccess.first.storeId
                  : null),
        );
        await storage.writeSession(refreshed);

        // Make sure the auth controller has finished its first build before
        // we overwrite its state, otherwise the build() may resolve after
        // and clobber our update.
        await authControllerFuture;
        ref.read(authControllerProvider.notifier).state =
            AsyncData<AuthSession?>(refreshed);
      } on ApiException {
        // Best-effort — keep the persisted session. The router will still
        // route the user normally; if the token is genuinely revoked the
        // auth interceptor will surface that on the next protected call.
        await authControllerFuture;
      }
    } else {
      // No session: still wait for the controllers to settle so the router
      // can decide between /onboarding and /auth/otp.
      await authControllerFuture;
    }

    await onboardingFuture;

    // Kick the offline-first sync bootstrap. Reading the provider triggers
    // its constructor side-effect, which runs an initial `processQueue()`
    // and subscribes to `connectivity_plus` for offline → online events.
    // Failures inside the service surface via the registered notifier, so
    // we don't need to await anything here.
    ref.read(syncBootstrapProvider);

    final pkg = await packageInfoFuture;
    final deviceId = await deviceIdFuture;
    return BootstrapResult(
      packageInfo: pkg,
      deviceId: deviceId,
      hasSession: session != null,
    );
  }

  static StoreAccess _storeAccessFromDto(StoreAccessDto dto) => StoreAccess(
    storeId: dto.storeId,
    storeName: dto.storeName,
    role: dto.role,
  );
}

/// Global handle for the bootstrap controller. `RadhaApp` watches this so the
/// bootstrap kicks off on first build; the splash screen also watches it so
/// the same `AsyncValue` drives both wiring and UI.
final bootstrapControllerProvider =
    AsyncNotifierProvider<BootstrapController, BootstrapResult>(
      BootstrapController.new,
    );

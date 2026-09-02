import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import 'auth_repository.dart';
import 'auth_session.dart';
import 'session_storage.dart';

/// Single source of truth for the user's authentication state. Reads the
/// session from secure storage on first build, then mutates it through the
/// repository as the user logs in / out / switches stores. Widgets watching
/// `authControllerProvider` re-render through the standard
/// `AsyncValue<T>` machinery (data / loading / error).
class AuthController extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() async {
    final repo = ref.read(authRepositoryProvider);
    final session = await repo.currentSession();
    if (session == null) return null;
    // Auto-select the only store when the session has no selection — handles
    // old sessions that were written before this logic existed.
    if (session.selectedStoreId == null && session.stores.length == 1) {
      final updated = session.copyWith(
        selectedStoreId: session.stores.first.storeId,
      );
      await ref.read(sessionStorageProvider).writeSession(updated);
      return updated;
    }
    return session;
  }

  /// Issues an OTP. Doesn't change session state — only on `verifyOtp` does
  /// the user become authenticated.
  Future<OtpRequestResult> requestOtp(String mobile) {
    final repo = ref.read(authRepositoryProvider);
    return repo.requestOtp(mobile);
  }

  /// Completes the OTP flow and lifts the controller into a signed-in state.
  ///
  /// NOTE: intentionally does NOT set AsyncLoading first. Setting loading would
  /// trigger the GoRouter redirect (auth.isLoading → /splash), which unmounts
  /// the OTP verify screen before it can post the pending onboarding segment.
  /// The verify screen owns its own loading UI via local setState.
  ///
  /// IMPORTANT: rethrows on failure (e.g. wrong OTP). `AsyncValue.guard`
  /// captures the exception into `state` either way (so the router's
  /// `auth.valueOrNull` reflects the real signed-out state on failure),
  /// but a bare `await controller.verifyOtp(...)` at the call site must
  /// also see the failure — otherwise the caller has no way to tell "wrong
  /// OTP" apart from "signed in successfully" and ends up running its
  /// success path (checkmark animation, navigation) unconditionally. That
  /// was a real bug: the OTP verify screen showed a green checkmark and
  /// tried to navigate to /home even when the OTP was rejected, because it
  /// had no signal that anything went wrong.
  Future<void> verifyOtp({
    required String mobile,
    required String otp,
    required String requestId,
  }) async {
    state = await AsyncValue.guard<AuthSession?>(() async {
      final repo = ref.read(authRepositoryProvider);
      return repo.verifyOtp(mobile: mobile, otp: otp, requestId: requestId);
    });
    final error = state.error;
    if (error != null) {
      final stack = state.stackTrace ?? StackTrace.current;
      Error.throwWithStackTrace(error, stack);
    }
  }

  /// Admin email + password login. Same state transitions as [verifyOtp].
  Future<void> adminLogin({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading<AuthSession?>();
    state = await AsyncValue.guard<AuthSession?>(() async {
      final repo = ref.read(authRepositoryProvider);
      return repo.adminLogin(email: email, password: password);
    });
  }

  /// Phase 13 — primary login. Same NOT-setting-loading-first rationale as
  /// [verifyOtp] doesn't apply here (there's no pending-onboarding-segment
  /// post step riding on this screen), so this one sets loading normally.
  /// Rethrows on failure, same contract as [verifyOtp].
  Future<void> signInWithFirebase({
    required String idToken,
    String? deviceId,
  }) async {
    state = const AsyncLoading<AuthSession?>();
    state = await AsyncValue.guard<AuthSession?>(() async {
      final repo = ref.read(authRepositoryProvider);
      return repo.exchangeFirebaseToken(idToken: idToken, deviceId: deviceId);
    });
    final error = state.error;
    if (error != null) {
      final stack = state.stackTrace ?? StackTrace.current;
      Error.throwWithStackTrace(error, stack);
    }
  }

  /// Phase 13 legacy-link recovery, step 1. Doesn't change session state.
  Future<OtpRequestResult> requestLegacyLink(String mobile) {
    final repo = ref.read(authRepositoryProvider);
    return repo.requestLegacyLink(mobile);
  }

  /// Phase 13 legacy-link recovery, step 2. Same state-transition contract
  /// as [verifyOtp] — rethrows on failure so the screen can distinguish
  /// "wrong OTP" from "linked successfully".
  Future<void> linkLegacyAccount({
    required String mobile,
    required String otp,
    required String requestId,
    required String idToken,
    String? deviceId,
  }) async {
    state = await AsyncValue.guard<AuthSession?>(() async {
      final repo = ref.read(authRepositoryProvider);
      return repo.linkLegacyAccount(
        mobile: mobile,
        otp: otp,
        requestId: requestId,
        idToken: idToken,
        deviceId: deviceId,
      );
    });
    final error = state.error;
    if (error != null) {
      final stack = state.stackTrace ?? StackTrace.current;
      Error.throwWithStackTrace(error, stack);
    }
  }

  /// Wipes the session locally and (best-effort) on the server. The new state
  /// is `AsyncData(null)` regardless of network outcome — see
  /// [AuthRepository.logout]. The `finally` is load-bearing: the router's
  /// redirect guard treats `auth.isLoading` as "stay on /splash", so if
  /// `repo.logout()` throws anything `AuthRepository` itself didn't already
  /// swallow (e.g. a concurrent in-flight request racing the token clear and
  /// surfacing its own 401), the state must still leave `AsyncLoading` or the
  /// app hangs on the splash screen forever.
  ///
  /// Intentionally does NOT reset the onboarding flag — the segment choice
  /// (Personal / Business) persists so the user lands on /auth/otp on next
  /// open rather than being sent back through onboarding.
  Future<void> logout() async {
    state = const AsyncLoading<AuthSession?>();
    final repo = ref.read(authRepositoryProvider);
    try {
      await repo.logout();
    } finally {
      state = const AsyncData<AuthSession?>(null);
    }
  }

  /// Calls `/auth/me` and refreshes the in-memory + stored session.
  /// Used after business activation when the tenant + stores change.
  Future<void> refreshSession() async {
    final currentSession = state.valueOrNull;
    if (currentSession == null) return;
    try {
      final api = ref.read(apiClientProvider);
      final me = await api.me();
      final storage = ref.read(sessionStorageProvider);
      final freshStores = me.storeAccess
          .map((dto) => StoreAccess(
                storeId: dto.storeId,
                storeName: dto.storeName,
                role: dto.role,
              ))
          .toList(growable: false);
      final refreshed = currentSession.copyWith(
        userId: me.user.id,
        tenantId: me.user.tenantId,
        roles: me.roles,
        stores: freshStores,
        // Preserve any prior selection; auto-select if exactly one store and
        // nothing was chosen yet.
        selectedStoreId: currentSession.selectedStoreId ??
            (freshStores.length == 1 ? freshStores.first.storeId : null),
        mobile: me.user.mobile ?? currentSession.mobile,
        name: me.user.name ?? currentSession.name,
        email: me.user.email ?? currentSession.email,
      );
      await storage.writeSession(refreshed);
      state = AsyncData<AuthSession?>(refreshed);
    } catch (_) {
      // Best-effort; existing session remains valid.
    }
  }

  /// Persists the user's chosen store and updates the in-memory session.
  /// Throws if the user isn't signed in — the UI guards prevent that.
  Future<void> selectStore(String storeId) async {
    state = const AsyncLoading<AuthSession?>();
    state = await AsyncValue.guard<AuthSession?>(() async {
      final repo = ref.read(authRepositoryProvider);
      return repo.selectStore(storeId);
    });
  }
}

/// Global handle for the auth state machine.
final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSession?>(AuthController.new);

/// Slim view of the current user that screens consume. Resolves to `null`
/// while the controller is loading, errored, or signed out — callers should
/// fall back to a guard / redirect rather than rendering on `null`.
class CurrentUser {
  const CurrentUser({
    required this.userId,
    this.tenantId,
    required this.roles,
    this.selectedStoreId,
    this.selectedStoreName,
    this.mobile,
    this.name,
    this.email,
  });

  final String userId;
  final String? tenantId;
  final List<String> roles;
  final String? selectedStoreId;
  final String? selectedStoreName;

  /// E.164-ish raw mobile number from `/auth/me`. Screens should mask it
  /// (e.g. `+91 •••••1 2345`) before display — this carries the
  /// unmasked value so each call site can apply its own masking format
  /// consistently with how it renders elsewhere.
  final String? mobile;

  /// Display name from `/auth/me`, when the account has one set. Most
  /// accounts today don't (OTP-only signup never collects a name), so
  /// callers should fall back to a masked [mobile] or a generic label —
  /// never to [userId], which is an internal UUID with no display value.
  final String? name;

  /// Google account email (Phase 13 Google Sign-In), null for legacy
  /// phone-only OTP accounts. Every account created via the primary
  /// Google Sign-In path has this set — prefer it over [mobile] for
  /// identity display since it reads as a real "you're signed in as"
  /// value rather than a masked digit string.
  final String? email;
}

/// Derived view of the auth state that ignores loading + error states. Use
/// this when a screen wants the "current user" without owning the
/// `AsyncValue` boilerplate; combine with auth/role guards for redirects.
final currentUserProvider = Provider<CurrentUser?>((ref) {
  final session = ref.watch(authControllerProvider).valueOrNull;
  if (session == null) return null;
  final selected = session.selectedStoreId == null
      ? null
      : session.stores.where((s) => s.storeId == session.selectedStoreId);
  final selectedStore = (selected == null || selected.isEmpty)
      ? null
      : selected.first;
  return CurrentUser(
    userId: session.userId,
    tenantId: session.tenantId,
    roles: session.roles,
    selectedStoreId: session.selectedStoreId,
    selectedStoreName: selectedStore?.storeName,
    mobile: session.mobile,
    name: session.name,
    email: session.email,
  );
});

// Proactive session refresh on app resume.
//
// The access token is short-lived (30 min in production). Without this,
// the token only ever gets refreshed reactively — the *first* protected API
// call made after resuming from the background 401s, the `AuthInterceptor`
// refreshes+retries it, and every other call the resumed screen fires
// concurrently joins that same single-flight refresh (see
// `auth_interceptor.dart`). That's already safe, but it means the user's
// first screen after resuming always eats one guaranteed round-trip of
// latency for the 401+refresh+retry dance.
//
// This widget shaves that off: on `AppLifecycleState.resumed`, it fires a
// single best-effort `/auth/me` call. If the access token has expired while
// backgrounded, that call 401s and drives the *same* interceptor refresh
// path — but it does so immediately on resume, before the screen's own
// data calls fire, so by the time Home/Tasks/etc. make their requests the
// token is already fresh and none of them need to 401 at all.
//
// Deliberately does NOT call `AuthRepository.refresh()` directly — that
// would be a second, independent code path rotating the refresh token
// outside the interceptor's single-flight lock, which is exactly the race
// that caused the token-theft false-positive this file exists to avoid.
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import 'auth_controller.dart';

class SessionResumeGuard extends ConsumerStatefulWidget {
  const SessionResumeGuard({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SessionResumeGuard> createState() => _SessionResumeGuardState();
}

class _SessionResumeGuardState extends ConsumerState<SessionResumeGuard>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final isSignedIn = ref.read(authControllerProvider).valueOrNull != null;
    if (!isSignedIn) return;
    // Fire-and-forget: any failure just means the next real API call falls
    // back to the interceptor's own reactive refresh, exactly as before.
    unawaited(ref.read(apiClientProvider).me());
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// App-mode resolver.
//
// Derives whether the current user is in consumer mode (personal food-health)
// or business mode (retail-ops command center) from the existing auth session.
// This is a pure computation — no new network calls. The router and home screen
// read this provider to decide which content set to render.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';

/// The two operating modes of the RADHA shell.
///
/// Same login, same 5-tab navigation. Mode decides which content a tab
/// renders and which Hero missions rotate in the Story Banner.
enum AppMode { consumer, business, auditor }

/// Roles that indicate the user has a business (tenant) identity.
///
/// A user holding any of these roles AND having a selected store is resolved
/// into business mode. Everything else is consumer mode.
///
/// Mirrors the backend's `UserRole` union exactly (`shared-types.ts`:
/// `'owner' | 'manager' | 'staff' | 'auditor' | 'consumer' | 'admin'`), minus
/// `consumer`. `tenant_admin`/`admin_lite` were previously listed here but
/// don't exist in the backend union — dead weight, never matched a real
/// session. `owner` was missing — every demo/seed business account is
/// provisioned with that role, so omitting it silently fell back the
/// entire Home/Tasks/Expiry business UI to consumer mode for every owner
/// login.
const kBusinessRoles = {'owner', 'manager', 'staff', 'auditor', 'admin'};

/// Pure function — same inputs always return the same output.
///
/// [user] comes from `currentUserProvider` (GET /auth/me). A null user
/// (loading, signed-out) defaults to consumer so no screen is blank.
AppMode resolveMode(CurrentUser? user) {
  if (user == null) return AppMode.consumer;
  // Auditor role takes precedence — restricted 3-tab shell, no business secrets.
  if (user.roles.contains('auditor') && user.selectedStoreId != null) {
    return AppMode.auditor;
  }
  final hasBizRole = user.roles.any(kBusinessRoles.contains);
  return (hasBizRole && user.selectedStoreId != null)
      ? AppMode.business
      : AppMode.consumer;
}

/// Debug-only manual override (set from the Profile screen's preview
/// toggle). Lets QA flip between the two surfaces without juggling phone
/// numbers — a phone number that's already business-activated has no way
/// to "go back" to consumer through real account data, since the backend
/// stores one permanent role per user. `null` means no override: defer to
/// [resolveMode]. Never read in release builds — see [appModeProvider].
final modeOverrideProvider = StateProvider<AppMode?>((ref) => null);

/// Derived provider — no I/O, re-evaluates whenever auth session changes.
///
/// Reads from `currentUserProvider` (which itself watches
/// `authControllerProvider`), so mode flips automatically when a consumer
/// completes business-activation and the entitlement refresh updates the
/// session. In debug builds, [modeOverrideProvider] can short-circuit this
/// for local preview/QA.
final appModeProvider = Provider<AppMode>((ref) {
  if (kDebugMode) {
    final override = ref.watch(modeOverrideProvider);
    if (override != null) return override;
  }
  return resolveMode(ref.watch(currentUserProvider));
});

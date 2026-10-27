// App-mode resolver.
//
// RADHA has a single product surface: the business module. Every signed-in
// user — free or paid — sees it; what a plan unlocks is decided by
// `entitlementProvider`, not by a separate "personal" mode. The only variant
// is the restricted auditor shell for invited auditors.
//
// This is a pure computation — no new network calls.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';

/// Operating modes of the RADHA shell. (The former `consumer` mode was merged
/// into `business`; free vs paid is an entitlement concern.)
enum AppMode { business, auditor }

/// Pure function — same inputs always return the same output.
///
/// [user] comes from `currentUserProvider` (GET /auth/me). Auditors with a
/// selected store get the restricted 3-tab shell; everyone else (including a
/// null/loading user) gets the business shell.
AppMode resolveMode(CurrentUser? user) {
  if (user != null &&
      user.roles.contains('auditor') &&
      user.selectedStoreId != null) {
    return AppMode.auditor;
  }
  return AppMode.business;
}

/// Derived provider — no I/O, re-evaluates whenever the auth session changes.
final appModeProvider = Provider<AppMode>((ref) {
  return resolveMode(ref.watch(currentUserProvider));
});

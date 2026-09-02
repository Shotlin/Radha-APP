import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';

/// Store details (name, short code, address, GSTIN, business hours) for a
/// given store id. Shared by the Profile screen, the business-mode Home
/// greeting, and the Store Details edit screen so they don't each run
/// their own independent `GET /stores/{id}` fetch.
///
/// Display-only callers (Profile header, Home greeting) should read
/// `.valueOrNull` and just omit their bit of UI while it's null (loading
/// or failed) rather than rendering an error state for a non-critical
/// detail. The Store Details edit screen, where a failed fetch matters,
/// should use `.when(...)` on the full `AsyncValue` to show a real
/// loading/error/retry state.
final storeDetailsProvider =
    FutureProvider.family<StoreResponse, String>((ref, storeId) {
  return ref.read(apiClientProvider).getStore(storeId);
});

/// A store's current team (`GET /stores/{id}/access`). Owner/manager/admin
/// only (per `StoresController.listStaff`'s doc comment). Shared by the
/// Create Task assignee picker and (via `staff_management_screen.dart`'s
/// own copy, kept private there since it doesn't need cross-feature
/// sharing) the Staff & roles team list.
final storeStaffProvider =
    FutureProvider.family<List<StaffMemberResponse>, String>((ref, storeId) {
  return ref.read(apiClientProvider).getStoreStaff(storeId);
});

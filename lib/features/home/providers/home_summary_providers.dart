import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:radha_app/core/auth/auth_controller.dart';
import 'package:radha_app/core/network/api_client.dart';
import 'package:radha_app/core/network/dto/reports_dto.dart';
import 'package:radha_app/core/network/dto/task_dto.dart';

/// Cache a *successful* result for the lifetime of the app session.
///
/// Why: the home summary tiles must feel "already there" on every return to
/// the Home tab — no skeleton flash on re-entry. Calling [KeepAliveLink] only
/// after a value resolves means errors are **not** cached, so a transient
/// backend/network failure is retried on the next read (graceful self-heal),
/// while good data sticks until an explicit pull-to-refresh invalidates it.
void _cacheOnSuccess(Ref ref) => ref.keepAlive();

/// Count of expiry records in warning/danger states for the selected store.
/// Returns 0 immediately when no store is selected (consumer accounts).
final nearExpiryCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final storeId = ref.watch(currentUserProvider)?.selectedStoreId;
  if (storeId == null) return 0;
  final client = ref.watch(apiClientProvider);
  final response = await client.getExpiries(
    status: 'yellow,red',
    storeId: storeId,
    limit: 200,
  );
  _cacheOnSuccess(ref);
  return response.total;
});

/// Count of tasks with status "open".
///
/// `GET /tasks` has no server-side total count (it's a flat, `limit`-capped
/// list, not a paginated envelope) — same approximation pattern as
/// [lowStockCountProvider]: fetch a generously-bounded page and count it.
final openTasksCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.getTasks(status: 'open', limit: 200);
  _cacheOnSuccess(ref);
  return response.length;
});

/// Count of low-stock inventory items for the selected store.
/// Uses the server-side `/inventory/summary` roll-up (tenant-scoped) which
/// returns `lowStockCount` directly — one cheap call, no on-device filtering.
final lowStockCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final storeId = ref.watch(currentUserProvider)?.selectedStoreId;
  if (storeId == null) return 0;
  final client = ref.watch(apiClientProvider);
  final summary = await client.getInventorySummary(storeId);
  _cacheOnSuccess(ref);
  return summary.lowStockCount;
});

// ─── Consumer-mode providers ─────────────────────────────────────────────────

/// Count of the signed-in user's saved products (consumer mode KPI).
///
/// Fetches up to 20 items and reports `.length`. The API uses cursor
/// pagination without a total count, so this is a best-effort display number
/// for the home KPI tile — exact counts live on the saved-products screen.
final savedProductsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.getSavedProducts(limit: 20);
  _cacheOnSuccess(ref);
  return response.items.length;
});

/// Count of active system-wide recall alerts (consumer mode KPI).
///
/// Recalls are a free safety hook — always visible regardless of plan. The
/// endpoint returns the full list; `.length` is used as the badge value.
final recallAlertsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final client = ref.watch(apiClientProvider);
  final recalls = await client.getRecalls();
  _cacheOnSuccess(ref);
  return recalls.length;
});

/// OHS snapshot for the business home mini-card (business mode only).
/// Fetches 14 days of dashboard data so we have enough for week-over-week delta.
final homeOhsProvider = FutureProvider.autoDispose<OhsSnapshot?>((ref) async {
  final storeId = ref.watch(currentUserProvider)?.selectedStoreId;
  if (storeId == null) return null;
  final client = ref.watch(apiClientProvider);
  final response = await client.getDashboardSummary(storeId, daysAhead: 14);
  _cacheOnSuccess(ref);
  return OhsSnapshot.fromDashboard(response);
});

/// Top-3 most recent open tasks (business mode — replaces hardcoded list).
///
/// Scoped to open status so the home preview always shows actionable items.
/// The full task list lives on the Tasks tab.
final recentTasksProvider =
    FutureProvider.autoDispose<List<TaskResponse>>((ref) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.getTasks(status: 'open', limit: 3);
  _cacheOnSuccess(ref);
  return response;
});

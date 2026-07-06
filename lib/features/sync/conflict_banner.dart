// Conflict banner overlay (FE-34).
//
// Surfaces unresolved sync conflicts that the offline queue couldn't
// reconcile. Wraps the routed app body in `main.dart`'s `MaterialApp.builder`
// so the banner stays anchored above any route — the bottom-nav shell
// included.
//
// Backing data:
//   The Drift schema (`lib/core/offline/db.dart`) has no dedicated
//   `conflicts` column or table today. As a deliberate stop-gap we treat
//   any pending write whose `retryCount` has reached or exceeded
//   `kSyncMaxRetries - 1` (i.e. the row is one attempt away from being
//   dropped by the queue runner) as a conflict candidate. The shape of
//   `syncConflictsProvider` is forward-compatible with a future `conflicts`
//   table — when it lands, the only change needed is to swap the query in
//   `_loadConflicts` to read from that table.
//
//   TODO (FE-34 follow-up): add an explicit `conflicts` table in
//   `apps/mobile/lib/core/offline/db.dart` with columns
//   `(id, write_id, server_revision, client_revision, resource_type,
//    resource_id, summary, detected_at)` and bump `schemaVersion` to 2.
//
// Visual rules:
//   * Calm rose/amber tint — not alarming. The brand accent never appears
//     on a conflict surface (reserved for success).
//   * Banner is dismissible for one hour via a session-scoped controller
//     (resets on app restart; never permanently muted).
//   * Sticky on top of every screen, animates in/out via opacity + slide.
//   * 44pt+ touch targets on the "Resolve" CTA and dismiss icon.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/offline/db.dart';
import '../../core/offline/sync_service.dart';
import '../../design/tokens.dart';
import '../../l10n/generated/app_localizations.dart';
import 'conflict_resolution_sheet.dart';

// ─── Conflict types ───────────────────────────────────────────────────────

/// The kinds of resources we can render in the resolution sheet. Mapped
/// from the endpoint path so the UI can render a friendly label without
/// the user having to read URLs.
enum ConflictResourceKind {
  task,
  expiry,
  scan,
  inventory,
  grn,
  shoppingList,
  generic,
}

/// One unresolved sync conflict surfaced to the UI.
@immutable
class SyncConflict {
  const SyncConflict({
    required this.queueRowId,
    required this.endpoint,
    required this.method,
    required this.kind,
    required this.retryCount,
    required this.localChange,
    required this.lastError,
  });

  /// Primary key in `pending_writes`. Used by the resolution sheet to
  /// either re-enqueue or drop the row.
  final int queueRowId;

  /// Original endpoint path, e.g. `/api/v1/tasks`.
  final String endpoint;

  /// HTTP method (`POST` / `PATCH` / etc).
  final String method;

  /// High-level resource kind, derived from the endpoint.
  final ConflictResourceKind kind;

  /// Number of times the queue runner has attempted this row.
  final int retryCount;

  /// Decoded JSON body the user submitted locally. Used to render the
  /// "your change" summary in the resolution card.
  final Map<String, Object?> localChange;

  /// Last error message recorded against this row, if any.
  final String? lastError;

  /// Resolves the kind from a path-only endpoint string.
  static ConflictResourceKind kindFromEndpoint(String endpoint) {
    if (endpoint.contains('/tasks')) return ConflictResourceKind.task;
    if (endpoint.contains('/expiry')) return ConflictResourceKind.expiry;
    if (endpoint.contains('/scans')) return ConflictResourceKind.scan;
    if (endpoint.contains('/inventory')) return ConflictResourceKind.inventory;
    if (endpoint.contains('/grn')) return ConflictResourceKind.grn;
    if (endpoint.contains('/shopping-list')) {
      return ConflictResourceKind.shoppingList;
    }
    return ConflictResourceKind.generic;
  }

  /// Localised label for [kind].
  static String labelFor(AppLocalizations l10n, ConflictResourceKind kind) {
    switch (kind) {
      case ConflictResourceKind.task:
        return l10n.conflictResourceTask;
      case ConflictResourceKind.expiry:
        return l10n.conflictResourceExpiry;
      case ConflictResourceKind.scan:
        return l10n.conflictResourceScan;
      case ConflictResourceKind.inventory:
        return l10n.conflictResourceInventory;
      case ConflictResourceKind.grn:
        return l10n.conflictResourceGrn;
      case ConflictResourceKind.shoppingList:
        return l10n.conflictResourceShoppingList;
      case ConflictResourceKind.generic:
        return l10n.conflictResourceGeneric;
    }
  }
}

/// Conflict threshold. Rows whose `retryCount` is at-or-beyond this value
/// are surfaced as conflicts. We pick `kSyncMaxRetries - 1` so the user
/// sees the conflict before the queue runner drops the row.
const int _kConflictRetryThreshold = kSyncMaxRetries - 1;

/// Reads pending writes from Drift and projects only the ones that look
/// like conflicts. See file-level note on the conflict-detection heuristic.
final syncConflictsProvider = FutureProvider<List<SyncConflict>>((ref) async {
  final db = ref.watch(radhaDatabaseProvider);
  // Re-fetch whenever the queue depth changes so the banner stays current.
  ref.watch(pendingWriteCountStreamProvider);
  final rows = await db.getAllPendingWrites();
  final conflicts = <SyncConflict>[];
  for (final row in rows) {
    if (row.retryCount < _kConflictRetryThreshold) continue;
    Map<String, Object?> body = const <String, Object?>{};
    if (row.bodyJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(row.bodyJson);
        if (decoded is Map<String, Object?>) body = decoded;
      } catch (_) {
        body = const <String, Object?>{};
      }
    }
    conflicts.add(
      SyncConflict(
        queueRowId: row.id,
        endpoint: row.endpoint,
        method: row.method,
        kind: SyncConflict.kindFromEndpoint(row.endpoint),
        retryCount: row.retryCount,
        localChange: body,
        lastError: row.lastError,
      ),
    );
  }
  return conflicts;
});

// ─── Dismissal controller (session-scoped) ───────────────────────────────

/// Holds the wall-clock until-time the banner is muted. Resets on cold
/// start (provider lifecycle is the app lifecycle).
class ConflictBannerDismissal extends StateNotifier<DateTime?> {
  ConflictBannerDismissal() : super(null);

  /// Mutes the banner for [duration]. Default is 1 hour per spec.
  void dismissFor(Duration duration) {
    state = DateTime.now().add(duration);
  }

  /// True if the banner should currently be hidden.
  bool isMuted() {
    final until = state;
    if (until == null) return false;
    return DateTime.now().isBefore(until);
  }
}

final conflictBannerDismissalProvider =
    StateNotifierProvider<ConflictBannerDismissal, DateTime?>((ref) {
      return ConflictBannerDismissal();
    });

// ─── Overlay widget ──────────────────────────────────────────────────────

/// Wraps [child] with a sticky banner on top. The banner appears only when
/// [syncConflictsProvider] returns at least one row and the dismissal
/// controller hasn't muted it.
class ConflictBannerOverlay extends ConsumerWidget {
  const ConflictBannerOverlay({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncConflicts = ref.watch(syncConflictsProvider);
    final mutedUntil = ref.watch(conflictBannerDismissalProvider);
    final conflicts = asyncConflicts.valueOrNull ?? const <SyncConflict>[];
    final muted =
        mutedUntil != null && DateTime.now().isBefore(mutedUntil);
    final showBanner = conflicts.isNotEmpty && !muted;

    return Stack(
      children: [
        // Reserve the banner height when it's shown so the page content
        // doesn't slide underneath.
        Padding(
          padding: EdgeInsets.only(top: showBanner ? _ConflictBanner.height : 0),
          child: child,
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedSwitcher(
            duration: RadhaMotion.medium,
            switchInCurve: RadhaMotion.easeOut,
            switchOutCurve: RadhaMotion.easeOut,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: showBanner
                ? _ConflictBanner(
                    key: const ValueKey('conflict-banner'),
                    count: conflicts.length,
                    conflicts: conflicts,
                  )
                : const SizedBox.shrink(key: ValueKey('conflict-banner-empty')),
          ),
        ),
      ],
    );
  }
}

// ─── Banner ───────────────────────────────────────────────────────────────

class _ConflictBanner extends ConsumerWidget {
  const _ConflictBanner({required this.count, required this.conflicts, super.key});

  static const double height = 56.0;
  static const Duration _dismissalDuration = Duration(hours: 1);

  final int count;
  final List<SyncConflict> conflicts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    // Calm rose/amber background — never the brand accent (which is reserved
    // for success states).
    final background = RadhaColors.warning.withValues(alpha: 0.12);
    final foreground = RadhaColors.warning;

    return Material(
      color: background,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(
            horizontal: RadhaSpacing.space16,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: scheme.outline.withValues(alpha: 0.5)),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.sync_problem_rounded,
                color: foreground,
                size: 20,
              ),
              const SizedBox(width: RadhaSpacing.space12),
              Expanded(
                child: Text(
                  l10n.conflictBannerCount(count),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: RadhaSpacing.space8),
              SizedBox(
                height: kMinTouchTarget,
                child: TextButton(
                  onPressed: () => _openSheet(context, ref),
                  style: TextButton.styleFrom(
                    foregroundColor: foreground,
                    padding: const EdgeInsets.symmetric(
                      horizontal: RadhaSpacing.space12,
                    ),
                  ),
                  child: Text(l10n.conflictBannerCta),
                ),
              ),
              IconButton(
                tooltip: l10n.conflictBannerDismiss,
                icon: Icon(Icons.close_rounded, color: scheme.onSurface),
                onPressed: () {
                  ref
                      .read(conflictBannerDismissalProvider.notifier)
                      .dismissFor(_dismissalDuration);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (sheetContext) => ConflictResolutionSheet(initial: conflicts),
    );
  }
}

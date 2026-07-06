// Conflict resolution sheet (FE-34).
//
// Modal bottom sheet rendered when the user taps "Resolve" on the
// `ConflictBanner`. Each conflict is shown as a card with two choices:
//
//   * Use my version  — re-enqueue the local write with a fresh
//     `next_retry_at = null` and `retry_count = 0` so the queue runner
//     picks it up again next sweep. The future ideal is to attach a new
//     idempotency key; today the retrofit client builds the body from
//     `body_json` verbatim so resetting retry state achieves the same
//     practical outcome.
//   * Use server version — drop the pending write entirely so the
//     client falls back to the server's row on next sync pull.
//
// The sheet refuses dismissal until every conflict has a resolution
// (either applied immediately or skipped for "later"). The user may also
// tap the banner's close icon to mute it for an hour — that path is
// handled by `conflict_banner.dart`, not this widget.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/offline/db.dart';
import '../../design/tokens.dart';
import '../../l10n/generated/app_localizations.dart';
import 'conflict_banner.dart';

/// Choice the user made on a conflict card.
enum ConflictChoice { useMine, useServer }

/// Modal bottom sheet that walks the user through every conflict.
class ConflictResolutionSheet extends ConsumerStatefulWidget {
  const ConflictResolutionSheet({required this.initial, super.key});

  /// Snapshot of the conflicts at the moment the sheet was opened. The
  /// sheet keeps a local mutable copy so edits to the underlying queue
  /// don't reorder the cards under the user's finger.
  final List<SyncConflict> initial;

  @override
  ConsumerState<ConflictResolutionSheet> createState() =>
      _ConflictResolutionSheetState();
}

class _ConflictResolutionSheetState
    extends ConsumerState<ConflictResolutionSheet> {
  /// Per-conflict choice. Keys are the queue row id.
  final Map<int, ConflictChoice> _choices = {};

  /// Conflicts the user has actively resolved (server or local choice
  /// applied). Removed from the visible list once committed.
  final Set<int> _committed = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final remaining = widget.initial
        .where((c) => !_committed.contains(c.queueRowId))
        .toList();

    return PopScope(
      // Prevent dismissal while at least one conflict is unresolved. The
      // user can still mute via the banner's close icon (one-hour snooze).
      canPop: remaining.isEmpty,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            RadhaSpacing.space16,
            RadhaSpacing.space8,
            RadhaSpacing.space16,
            RadhaSpacing.space24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: RadhaSpacing.space8,
                    vertical: RadhaSpacing.space8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.conflictResolveTitle,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: RadhaSpacing.space4),
                      Text(
                        l10n.conflictResolveSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space8),
                if (remaining.isEmpty)
                  _AllResolvedTile(label: l10n.conflictResolvedAll)
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: remaining.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: RadhaSpacing.space12),
                      itemBuilder: (context, index) {
                        final conflict = remaining[index];
                        return _ConflictCard(
                          conflict: conflict,
                          choice: _choices[conflict.queueRowId],
                          onChoose: (choice) =>
                              _handleChoice(conflict, choice),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: RadhaSpacing.space16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: kMinTouchTarget,
                      child: TextButton(
                        onPressed: remaining.isEmpty
                            ? () => Navigator.of(context).maybePop()
                            : null,
                        child: Text(l10n.done),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Applies the user's choice for one conflict. Mutates the Drift queue
  /// (via `RadhaDatabase`) and commits the row to `_committed` so it
  /// disappears from the sheet on the next rebuild.
  Future<void> _handleChoice(
    SyncConflict conflict,
    ConflictChoice choice,
  ) async {
    setState(() {
      _choices[conflict.queueRowId] = choice;
    });

    final db = ref.read(radhaDatabaseProvider);
    final l10n = AppLocalizations.of(context);

    try {
      switch (choice) {
        case ConflictChoice.useMine:
          // Reset the retry state so the queue runner re-attempts the
          // local write on the next sweep. We can't easily attach a new
          // idempotency key with the current queue schema; resetting the
          // retry counter approximates the contract until the schema
          // grows an `idempotency_key` column (TODO above).
          await db.bumpRetry(
            id: conflict.queueRowId,
            newRetryCount: 0,
            // `bumpRetry` writes a non-null `next_retry_at`; pass a past
            // timestamp so the row is eligible immediately.
            nextRetryAt: DateTime.fromMillisecondsSinceEpoch(0),
            error: null,
          );
        case ConflictChoice.useServer:
          await db.deletePendingWrite(conflict.queueRowId);
      }

      if (!mounted) return;
      setState(() {
        _committed.add(conflict.queueRowId);
      });
      // Refresh the live conflicts provider so the banner count drops.
      ref.invalidate(syncConflictsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.conflictResolved)),
        );
      }
    } catch (_) {
      // The failure surface is intentionally subtle — the user can retry
      // from the same sheet.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorGeneric)),
      );
    }
  }
}

// ─── Card ────────────────────────────────────────────────────────────────

class _ConflictCard extends StatelessWidget {
  const _ConflictCard({
    required this.conflict,
    required this.choice,
    required this.onChoose,
  });

  final SyncConflict conflict;
  final ConflictChoice? choice;
  final ValueChanged<ConflictChoice> onChoose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final kindLabel = SyncConflict.labelFor(l10n, conflict.kind);

    return Material(
      color: scheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        side: BorderSide(color: scheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(RadhaSpacing.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.compare_arrows_rounded,
                  size: 20,
                  color: RadhaColors.warning,
                ),
                const SizedBox(width: RadhaSpacing.space8),
                Expanded(
                  child: Text(
                    kindLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  l10n.conflictAttempts(conflict.retryCount),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: RadhaSpacing.space8),
            Text(
              _summariseLocalChange(conflict.localChange),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (conflict.lastError != null &&
                conflict.lastError!.isNotEmpty) ...[
              const SizedBox(height: RadhaSpacing.space4),
              Text(
                conflict.lastError!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: RadhaSpacing.space12),
            Row(
              children: [
                Expanded(
                  child: _ChoiceButton(
                    label: l10n.conflictUseMine,
                    selected: choice == ConflictChoice.useMine,
                    onPressed: () => onChoose(ConflictChoice.useMine),
                  ),
                ),
                const SizedBox(width: RadhaSpacing.space8),
                Expanded(
                  child: _ChoiceButton(
                    label: l10n.conflictUseServer,
                    selected: choice == ConflictChoice.useServer,
                    onPressed: () => onChoose(ConflictChoice.useServer),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a short, single-line summary from a JSON body. Picks the most
  /// likely user-meaningful field from a known shortlist (title, name,
  /// note, productId, ean) and falls back to the raw map for diagnostic
  /// transparency.
  static String _summariseLocalChange(Map<String, Object?> body) {
    if (body.isEmpty) return '—';
    const candidates = <String>[
      'title',
      'name',
      'note',
      'productId',
      'ean',
      'description',
    ];
    for (final key in candidates) {
      final value = body[key];
      if (value is String && value.isNotEmpty) return value;
    }
    final firstNonEmpty = body.entries.firstWhere(
      (e) {
        final v = e.value;
        return v != null && v.toString().isNotEmpty;
      },
      orElse: () => const MapEntry<String, Object?>('', null),
    );
    if (firstNonEmpty.key.isEmpty) return '—';
    return '${firstNonEmpty.key}: ${firstNonEmpty.value}';
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SizedBox(
      height: kMinTouchTarget,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: selected
              ? scheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outline,
            width: selected ? 2 : 1,
          ),
          foregroundColor: selected ? scheme.primary : scheme.onSurface,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium?.copyWith(
            color: selected ? scheme.primary : scheme.onSurface,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _AllResolvedTile extends StatelessWidget {
  const _AllResolvedTile({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(RadhaSpacing.space24),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 24,
            color: scheme.primary,
          ),
          const SizedBox(width: RadhaSpacing.space12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

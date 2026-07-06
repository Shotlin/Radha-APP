import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/network/api_client.dart';
import '../../core/network/dto/scan_dto.dart';
import '../../design/app_assets.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/widgets/biz_screen_hero.dart';
import '../../design/widgets/empty_state.dart';
import '../../design/widgets/mor_companion.dart';
import '../../design/widgets/radha_icon_tile.dart';
import '../../l10n/generated/app_localizations.dart';
import 'utils/ean_validator.dart';

/// Bulk EAN audit screen (Part C2).
///
/// Opens (or reuses) an `audit` scan session for the operator's selected
/// store, then lets them scan/enter EANs one at a time. Each entry is posted
/// to `POST /scan-sessions/:id/items`; the result drives a running
/// matched/not-matched tally and a newest-first results feed. Ending the
/// audit closes the session server-side and pops back with a summary snackbar.
class EanAuditScreen extends ConsumerStatefulWidget {
  const EanAuditScreen({super.key});

  @override
  ConsumerState<EanAuditScreen> createState() => _EanAuditScreenState();
}

class _EanAuditScreenState extends ConsumerState<EanAuditScreen> {
  static const _uuid = Uuid();

  final TextEditingController _eanController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  /// Results newest-first. Index 0 maps to the top of the [AnimatedList].
  final List<ScanItemResultResponse> _results = <ScanItemResultResponse>[];

  String? _sessionId;
  bool _ensuringSession = false;
  bool _submitting = false;
  bool _ending = false;
  String? _inputError;

  int _matched = 0;
  int _notMatched = 0;

  @override
  void dispose() {
    _eanController.dispose();
    super.dispose();
  }

  /// Lazily resolves a session id: reuse the store's active session if one
  /// exists, otherwise open a fresh `audit` session. Returns null on failure.
  Future<String?> _ensureSession(String storeId) async {
    if (_sessionId != null) return _sessionId;
    if (_ensuringSession) return null;
    _ensuringSession = true;
    try {
      final client = ref.read(apiClientProvider);
      String? id;
      try {
        final active = await client.getActiveScanSession(storeId);
        if (active.id.isNotEmpty) id = active.id;
      } catch (_) {
        // No active session (or endpoint returned null) — fall through to
        // creating a new one below.
      }
      id ??= (await client.createScanSession(
        CreateScanSessionDto(storeId: storeId, type: 'audit'),
      )).id;
      _sessionId = id;
      return id;
    } finally {
      _ensuringSession = false;
    }
  }

  Future<void> _addEan(String storeId) async {
    final ean = _eanController.text.trim();
    if (!isValidEan(ean)) {
      setState(
        () => _inputError = AppLocalizations.of(context).auditEanInvalid,
      );
      return;
    }
    if (_submitting) return;

    HapticFeedback.lightImpact();
    setState(() {
      _inputError = null;
      _submitting = true;
    });

    try {
      final sessionId = await _ensureSession(storeId);
      if (sessionId == null) {
        throw StateError('Could not start an audit session');
      }
      final client = ref.read(apiClientProvider);
      final result = await client.recordScanItem(
        sessionId,
        RecordScanItemDto(
          ean: ean,
          scannedAt: DateTime.now().toUtc().toIso8601String(),
          quantity: 1,
          clientId: _uuid.v4(),
        ),
      );
      if (!mounted) return;
      _insertResult(result);
      _eanController.clear();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).auditRecordError),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _insertResult(ScanItemResultResponse result) {
    setState(() {
      _results.insert(0, result);
      if (result.matched) {
        _matched++;
      } else if (result.eanMatchStatus == 'unmatched') {
        _notMatched++;
      }
    });
    _listKey.currentState?.insertItem(0, duration: RadhaMotion.medium);
  }

  Future<void> _endAudit() async {
    final sessionId = _sessionId;
    if (sessionId == null) {
      // Nothing was scanned — just leave.
      context.pop();
      return;
    }
    if (_ending) return;
    setState(() => _ending = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.endScanSession(sessionId, const EndScanSessionDto());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)
                .auditEndedSummary(_matched, _notMatched),
          ),
        ),
      );
      context.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _ending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).auditEndError),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final storeId = ref.watch(currentUserProvider)?.selectedStoreId;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          AppLocalizations.of(context).auditTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (storeId != null)
            TextButton(
              onPressed: _ending ? null : _endAudit,
              child: Text(
                _ending
                    ? AppLocalizations.of(context).auditEndingAction
                    : AppLocalizations.of(context).auditEndAction,
              ),
            ),
        ],
      ),
      body: storeId == null
          ? Center(
              child: EmptyState(
                illustration: MorCompanion(
                  mood: MorMood.guard,
                  size: 104,
                  semanticLabel: AppLocalizations.of(context).auditNoStore,
                ),
                title: AppLocalizations.of(context).auditNoStore,
                body: AppLocalizations.of(context).auditNoStoreBody,
              ),
            )
          : _buildAudit(context, storeId),
    );
  }

  Widget _buildAudit(BuildContext context, String storeId) {
    final total = _matched + _notMatched;
    return Column(
      children: [
        BizScreenHero(
          assetPath: RadhaAssets.heroStoreAudit,
          headline: 'Store audit',
          subtitle: 'Verify every shelf with confidence',
        ),
        _TallyHeader(matched: _matched, notMatched: _notMatched, total: total),
        _EntryBar(
          controller: _eanController,
          errorText: _inputError,
          submitting: _submitting,
          onSubmit: () => _addEan(storeId),
          onChanged: () {
            if (_inputError != null) setState(() => _inputError = null);
          },
        ),
        Expanded(
          child: _results.isEmpty
              ? const _AuditEmpty()
              : AnimatedList(
                  key: _listKey,
                  padding: const EdgeInsets.fromLTRB(
                    RadhaSpacing.space20,
                    RadhaSpacing.space8,
                    RadhaSpacing.space20,
                    RadhaSpacing.space24,
                  ),
                  initialItemCount: _results.length,
                  itemBuilder: (context, index, animation) {
                    return _AnimatedRow(
                      animation: animation,
                      child: _ResultRow(result: _results[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ─── Running tally header ────────────────────────────────────────────────────

class _TallyHeader extends StatelessWidget {
  const _TallyHeader({
    required this.matched,
    required this.notMatched,
    required this.total,
  });

  final int matched;
  final int notMatched;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        RadhaSpacing.space20,
        RadhaSpacing.space16,
        RadhaSpacing.space20,
        RadhaSpacing.space8,
      ),
      child: Row(
        children: [
          Expanded(
            child: _TallyTile(
              label: AppLocalizations.of(context).auditMatched,
              value: matched,
              color: RadhaColors.success,
              icon: Icons.check_circle_rounded,
            ),
          ),
          const SizedBox(width: RadhaSpacing.space12),
          Expanded(
            child: _TallyTile(
              label: AppLocalizations.of(context).auditNotInList,
              value: notMatched,
              color: RadhaColors.danger,
              icon: Icons.cancel_rounded,
            ),
          ),
          const SizedBox(width: RadhaSpacing.space12),
          Expanded(
            child: _TallyTile(
              label: AppLocalizations.of(context).commonTotal,
              value: total,
              color: RadhaColors.primary,
              icon: Icons.fact_check_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _TallyTile extends StatelessWidget {
  const _TallyTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final int value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(RadhaSpacing.space12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        boxShadow: RadhaShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RadhaIconTile(icon: icon, tint: color, size: 32),
          const SizedBox(height: RadhaSpacing.space8),
          Text(
            '$value',
            style: radhaMonoStyle(
              fontSize: 24,
              weight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: RadhaSpacing.space2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Manual entry bar ────────────────────────────────────────────────────────

class _EntryBar extends StatelessWidget {
  const _EntryBar({
    required this.controller,
    required this.errorText,
    required this.submitting,
    required this.onSubmit,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String? errorText;
  final bool submitting;
  final VoidCallback onSubmit;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        RadhaSpacing.space20,
        RadhaSpacing.space8,
        RadhaSpacing.space20,
        RadhaSpacing.space8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              enabled: !submitting,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).auditEnterScanEan,
                prefixIcon: const Icon(Icons.qr_code_2_rounded),
                errorText: errorText,
              ),
              onChanged: (_) => onChanged(),
              onSubmitted: (_) => onSubmit(),
            ),
          ),
          const SizedBox(width: RadhaSpacing.space12),
          SizedBox(
            height: kMinTouchTarget + 4,
            child: FilledButton(
              onPressed: submitting ? null : onSubmit,
              child: submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(AppLocalizations.of(context).add),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Result row + status chip ────────────────────────────────────────────────

/// Subtle fade + slide for newly-inserted rows. Honors reduce-motion by
/// skipping the slide when animations are disabled.
class _AnimatedRow extends StatelessWidget {
  const _AnimatedRow({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final curved = CurvedAnimation(parent: animation, curve: RadhaMotion.easeOut);
    if (reduceMotion) {
      return FadeTransition(opacity: curved, child: child);
    }
    return FadeTransition(
      opacity: curved,
      child: SizeTransition(
        sizeFactor: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.1),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.result});

  final ScanItemResultResponse result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: RadhaSpacing.space8),
      padding: const EdgeInsets.all(RadhaSpacing.space12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.ean,
                  style: radhaMonoStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (result.productName != null &&
                    result.productName!.isNotEmpty) ...[
                  const SizedBox(height: RadhaSpacing.space4),
                  Text(
                    result.productName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: RadhaSpacing.space12),
          _StatusChip(result: result),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.result});

  final ScanItemResultResponse result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    late final Color color;
    late final IconData icon;
    late final String label;

    if (result.matched) {
      color = RadhaColors.success;
      icon = Icons.check_circle_rounded;
      label = l10n.auditMatched;
    } else {
      switch (result.eanMatchStatus) {
        case 'unmatched':
          color = RadhaColors.danger;
          icon = Icons.cancel_rounded;
          label = l10n.auditNotInList;
          break;
        case 'no_list':
          color = RadhaColors.warning;
          icon = Icons.info_outline_rounded;
          label = l10n.auditNoList;
          break;
        case 'invalid':
          color = theme.colorScheme.onSurfaceVariant;
          icon = Icons.help_outline_rounded;
          label = l10n.auditInvalid;
          break;
        default:
          color = theme.colorScheme.onSurfaceVariant;
          icon = Icons.remove_circle_outline_rounded;
          label = l10n.auditUnchecked;
      }
    }

    return Semantics(
      label: l10n.auditStatus(label),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: RadhaSpacing.space12,
          vertical: RadhaSpacing.space8,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: RadhaSpacing.space4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────────────────────

class _AuditEmpty extends StatelessWidget {
  const _AuditEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: EmptyState(
        illustration: MorCompanion(
          mood: MorMood.guard,
          size: 104,
          semanticLabel: AppLocalizations.of(context).auditStartAuditing,
        ),
        title: AppLocalizations.of(context).auditStartAuditing,
        body: AppLocalizations.of(context).auditStartBody,
      ),
    );
  }
}

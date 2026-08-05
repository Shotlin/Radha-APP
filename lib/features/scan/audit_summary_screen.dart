// Quick Audit session summary — lands here when the user taps "Finish"
// on the Quick Audit camera screen. Lists every product scanned/saved
// during that session with the same red/expired · yellow/near · green/
// safe traffic-light convention the Expiry tracker and calendar already
// use, and offers a top-of-screen Excel download of the whole session.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dto/reports_dto.dart';
import '../../design/tokens.dart';
import '../../l10n/generated/app_localizations.dart';
import 'audit_session.dart';

String _fmtDate(String? iso) {
  if (iso == null) return '—';
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  const m = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day.toString().padLeft(2, '0')} ${m[d.month - 1]} ${d.year}';
}

/// Shown after a Quick Audit camera session ends. Takes the finished
/// session's entries as `extra` (a `List<AuditSessionEntry>`) rather than
/// re-deriving them from the server, so the summary always matches
/// exactly what the user just did, in the order they did it.
class AuditSummaryScreen extends ConsumerStatefulWidget {
  const AuditSummaryScreen({super.key, required this.entries});

  final List<AuditSessionEntry> entries;

  @override
  ConsumerState<AuditSummaryScreen> createState() =>
      _AuditSummaryScreenState();
}

class _AuditSummaryScreenState extends ConsumerState<AuditSummaryScreen> {
  bool _downloading = false;

  int get _expiredCount =>
      widget.entries.where((e) => e.status == 'expired').length;
  int get _nearCount =>
      widget.entries.where((e) => e.status == 'yellow' || e.status == 'red').length;
  int get _safeCount =>
      widget.entries.where((e) => e.status == 'green').length;

  Future<void> _download() async {
    if (_downloading) return;
    setState(() => _downloading = true);
    final l10n = AppLocalizations.of(context);
    final user = ref.read(currentUserProvider);
    try {
      final api = ref.read(apiClientProvider);
      final now = DateTime.now();
      final rows = widget.entries
          .map(
            (e) => <String, dynamic>{
              'productName': e.productName,
              'ean': e.ean ?? '',
              'batchNumber': e.batchNumber ?? '',
              'category': e.category ?? '',
              'quantity': e.quantity,
              'previousQuantity': e.previousQuantity,
              'expiryDate': e.expiryDate ?? '',
              'daysLeft': e.daysLeft ?? '',
              'status': e.status ?? 'unknown',
              'scannedAt': e.scannedAt.toIso8601String(),
            },
          )
          .toList();

      final response = await api.exportAdHoc(
        AdHocExportRequestDto(
          title: 'Quick Audit — ${_fmtDate(now.toIso8601String())}',
          subtitle: '${widget.entries.length} products scanned',
          formats: const ['xlsx'],
          rows: rows,
          summary: <String, dynamic>{
            'totalScanned': widget.entries.length,
            'expired': _expiredCount,
            'nearExpiry': _nearCount,
            'safe': _safeCount,
          },
          tenantName: user?.selectedStoreName ?? 'RADHA',
          storeName: user?.selectedStoreName,
        ),
      );

      final file = response.files.isEmpty ? null : response.files.first;
      if (file == null) {
        throw const ApiException(
          statusCode: 500,
          code: 'NO_FILE',
          message: 'Export produced no file',
        );
      }
      final download = await api.getReportDownloadUrl(
        response.reportId,
        file.format,
      );
      await launchUrl(
        Uri.parse(download.url),
        mode: LaunchMode.externalApplication,
      );
    } on ApiException catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.quickAuditDownloadFailed)),
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    // Mirrors the server's `@Roles('owner', 'manager', 'admin')` guard on
    // `POST /reports/export` exactly — `auditor` has the `reports:export`
    // *permission* but is not one of the roles allowed on this specific
    // ad-hoc-export route, so it's deliberately excluded here too rather
    // than showing a button that would 403.
    final canExport = user?.roles.contains('owner') == true ||
        user?.roles.contains('manager') == true ||
        user?.roles.contains('admin') == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quickAuditSummaryTitle),
        actions: [
          if (canExport)
            IconButton(
              tooltip: l10n.quickAuditDownload,
              onPressed: _downloading ? null : _download,
              icon: _downloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_outlined),
            ),
        ],
      ),
      body: widget.entries.isEmpty
          ? Center(
              child: Text(
                l10n.quickAuditSummaryEmpty,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(RadhaSpacing.space16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryTile(
                          color: RadhaColors.danger,
                          label: l10n.expired,
                          count: _expiredCount,
                        ),
                      ),
                      const SizedBox(width: RadhaSpacing.space8),
                      Expanded(
                        child: _SummaryTile(
                          color: RadhaColors.warning,
                          label: l10n.expiryTabNear,
                          count: _nearCount,
                        ),
                      ),
                      const SizedBox(width: RadhaSpacing.space8),
                      Expanded(
                        child: _SummaryTile(
                          color: RadhaColors.success,
                          label: l10n.expiryTabSafe,
                          count: _safeCount,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      RadhaSpacing.space16,
                      0,
                      RadhaSpacing.space16,
                      RadhaSpacing.space24,
                    ),
                    itemCount: widget.entries.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: RadhaSpacing.space8),
                    itemBuilder: (context, i) =>
                        _AuditEntryRow(entry: widget.entries[i]),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.color,
    required this.label,
    required this.count,
  });

  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: RadhaSpacing.space12,
        horizontal: RadhaSpacing.space8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: RadhaSpacing.space4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditEntryRow extends StatelessWidget {
  const _AuditEntryRow({required this.entry});

  final AuditSessionEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final days = entry.daysLeft;

    final (chipColor, chipLabel) = switch (entry.status) {
      'expired' => (RadhaColors.danger, l10n.expired),
      'red' || 'yellow' => (
          RadhaColors.warning,
          days != null ? l10n.expiryCalendarDaysLeft(days) : l10n.expiryTabNear,
        ),
      'green' => (
          RadhaColors.success,
          days != null ? l10n.expiryCalendarDaysLeft(days) : l10n.expiryTabSafe,
        ),
      _ => (scheme.onSurfaceVariant, '—'),
    };

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        border: Border.all(color: scheme.outline),
      ),
      padding: const EdgeInsets.all(RadhaSpacing.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space2),
                Text(
                  [
                    if (entry.ean != null && entry.ean!.isNotEmpty)
                      l10n.expiryCalendarEanLabel(entry.ean!),
                    entry.quantityChanged
                        ? '${entry.previousQuantity} → ${entry.quantity}'
                        : l10n.expiryCalendarQtyLabel('${entry.quantity}'),
                    l10n.expiryExp(entry.expiryDate ?? '—'),
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: RadhaSpacing.space8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: RadhaSpacing.space12,
              vertical: RadhaSpacing.space4,
            ),
            decoration: BoxDecoration(
              color: chipColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
            ),
            child: Text(
              chipLabel,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: chipColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

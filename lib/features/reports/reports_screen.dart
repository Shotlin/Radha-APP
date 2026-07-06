// Reports / Exports screen (FE-30).
//
// Mounted at `/reports` and gated by `Feature.advancedReports` via
// the `LockedFeature` wrapper applied at the route layer. The screen
// is owners-and-managers territory — staff don't see the route on
// the home shell at all.
//
// Backend wiring
// ──────────────
//   * `GET    /api/v1/reports`               — recent runs (history tab).
//   * `POST   /api/v1/reports/generate`      — kick off ad-hoc exports.
//   * `POST   /api/v1/reports/:id/export`    — re-export an existing job.
//   * `GET    /api/v1/reports/:id/download/:format` — presigned URL.
//   * `GET    /api/v1/reports/scheduled`     — scheduled reports.
//   * `POST   /api/v1/reports/schedule`      — create a recurring schedule.
//   * `POST   /api/v1/reports/scheduled/:id/{pause|resume}` — toggle.
//   * `DELETE /api/v1/reports/scheduled/:id` — cancel a schedule.
//
// Visual contract (anti-slop)
// ──────────────────────────
//   * Single orange accent (#EA580C) — rose only for danger affordances
//     (delete schedule), amber only for paused schedules.
//   * Plus Jakarta Sans body / display, JetBrains Mono numerics.
//   * Quick-export tiles in a 2x2 grid (3-equal grids are banned).
//   * No 3-card row, no centred hero, no purple/blue gradients.
//   * 44pt+ touch targets on every action.
//   * Animations on transform/opacity only.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:radha_app/core/network/api_client.dart';
import 'package:radha_app/core/network/api_exception.dart';
import 'package:radha_app/core/network/dto/reports_dto.dart';
import 'package:radha_app/core/network/error_codes.dart';
import 'package:radha_app/design/theme.dart';
import 'package:radha_app/design/app_assets.dart';
import 'package:radha_app/design/tokens.dart';
import 'package:radha_app/design/widgets/biz_screen_hero.dart';
import 'package:radha_app/design/widgets/mor_companion.dart';
import 'package:radha_app/design/widgets/primary_button.dart';
import 'package:radha_app/design/widgets/radha_icon_tile.dart';
import 'package:radha_app/design/widgets/secondary_button.dart';
import 'package:radha_app/design/widgets/skeleton_loader.dart';
import 'package:radha_app/l10n/generated/app_localizations.dart';

/// Catalog of "quick" report types surfaced on the Available tab.
///
/// Every quick export maps to a server-side report `type` plus a default
/// `format`. The server-side enum lives in `report.types.ts`; we keep the
/// strings inline so the screen doesn't have to import from a generated
/// types module.
class QuickReportSpec {
  const QuickReportSpec({
    required this.id,
    required this.type,
    required this.defaultFormat,
    required this.icon,
  });

  /// Stable identifier so tests can target a tile without translating
  /// the localized title.
  final String id;
  final String type;
  final String defaultFormat;
  final IconData icon;
}

const List<QuickReportSpec> _quickExports = <QuickReportSpec>[
  QuickReportSpec(
    id: 'inventory-snapshot',
    type: 'inventory-summary',
    defaultFormat: 'pdf',
    icon: Icons.inventory_2_outlined,
  ),
  QuickReportSpec(
    id: 'expiring-items',
    type: 'expiry-summary',
    defaultFormat: 'xlsx',
    icon: Icons.event_busy_outlined,
  ),
  QuickReportSpec(
    id: 'sales-summary',
    type: 'scan-history',
    defaultFormat: 'xlsx',
    icon: Icons.bar_chart_outlined,
  ),
  QuickReportSpec(
    id: 'audit-log',
    type: 'audit-trail',
    defaultFormat: 'csv',
    icon: Icons.fact_check_outlined,
  ),
];

// ─── Providers ─────────────────────────────────────────────────────────

/// Recent reports, freshest first — drives the History tab.
final reportsListProvider = FutureProvider.autoDispose<List<ReportSummary>>((
  ref,
) async {
  final api = ref.watch(apiClientProvider);
  final reports = await api.getReports(limit: 50);
  // The server already orders by createdAt desc, but tolerate a noisy
  // backend by re-sorting client-side.
  final sorted = [...reports]
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return sorted;
});

/// Scheduled (recurring) reports — drives the Scheduled tab. Cancelled
/// schedules are filtered out so the list reflects what's actually
/// active or paused. The server keeps cancelled rows for audit.
final scheduledReportsProvider =
    FutureProvider.autoDispose<List<ScheduledReport>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final schedules = await api.getScheduledReports();
  return schedules.where((s) => !s.cancelled).toList(growable: false);
});

// ─── Screen ────────────────────────────────────────────────────────────

/// Reports & Exports surface mounted at `/reports`.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.reportsTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: false,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withValues(
            alpha: 0.7,
          ),
          indicatorColor: theme.colorScheme.primary,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: <Widget>[
            Tab(text: l10n.reportsTabAvailable),
            Tab(text: l10n.reportsTabScheduled),
            Tab(text: l10n.reportsTabHistory),
          ],
        ),
      ),
      body: Column(
        children: [
          BizScreenHero(
            assetPath: RadhaAssets.heroReportsExports,
            headline: 'Reports & exports',
            subtitle: 'See where operations improved',
          ),
          Expanded(
            child: SafeArea(
              child: TabBarView(
                controller: _tabs,
                children: const <Widget>[
                  _AvailableTab(),
                  _ScheduledTab(),
                  _HistoryTab(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Available tab ─────────────────────────────────────────────────────

class _AvailableTab extends ConsumerWidget {
  const _AvailableTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(RadhaSpacing.space24),
      children: [
        Text(
          l10n.reportsQuickExportsHeader,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: RadhaSpacing.space16),
        const _QuickExportGrid(),
      ],
    );
  }
}

class _QuickExportGrid extends ConsumerWidget {
  const _QuickExportGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: RadhaSpacing.space12,
      crossAxisSpacing: RadhaSpacing.space12,
      childAspectRatio: 1.05,
      children: _quickExports
          .map(
            (q) => _QuickExportTile(
              spec: q,
              title: _quickExportTitle(q.id, l10n),
              format: q.defaultFormat.toUpperCase(),
              onTap: () => _openGenerateSheet(context, ref, q),
            ),
          )
          .toList(growable: false),
    );
  }
}

String _quickExportTitle(String id, AppLocalizations l10n) {
  switch (id) {
    case 'inventory-snapshot':
      return l10n.reportsInventorySnapshot;
    case 'expiring-items':
      return l10n.reportsExpiringItems;
    case 'sales-summary':
      return l10n.reportsSalesSummary;
    case 'audit-log':
      return l10n.reportsAuditLog;
  }
  return id;
}

class _QuickExportTile extends StatelessWidget {
  const _QuickExportTile({
    required this.spec,
    required this.title,
    required this.format,
    required this.onTap,
  });

  final QuickReportSpec spec;
  final String title;
  final String format;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        boxShadow: RadhaShadows.card,
      ),
      child: Material(
        color: scheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(RadhaSpacing.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RadhaIconTile(icon: spec.icon, tint: scheme.primary, size: 36),
                const Spacer(),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: RadhaSpacing.space4),
                Text(
                  format,
                  style: radhaMonoStyle(
                    fontSize: 11,
                    weight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Generate config bottom sheet ──────────────────────────────────────

void _openGenerateSheet(
  BuildContext context,
  WidgetRef ref,
  QuickReportSpec spec,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => _GenerateSheet(spec: spec),
  );
}

class _GenerateSheet extends ConsumerStatefulWidget {
  const _GenerateSheet({required this.spec});

  final QuickReportSpec spec;

  @override
  ConsumerState<_GenerateSheet> createState() => _GenerateSheetState();
}

class _GenerateSheetState extends ConsumerState<_GenerateSheet> {
  late String _format = widget.spec.defaultFormat;
  late DateTimeRange _range = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  bool _submitting = false;

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _range,
    );
    if (picked != null && mounted) {
      setState(() => _range = picked);
    }
  }

  Future<void> _generate() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _submitting = true);
    try {
      final api = ref.read(apiClientProvider);
      final response = await api.generateReport(
        GenerateReportRequestDto(
          type: widget.spec.type,
          formats: <String>[_format],
          dateRange: DateRangeDto(from: _range.start, to: _range.end),
          title: _quickExportTitle(widget.spec.id, l10n),
        ),
      );
      if (!mounted) return;

      // Refresh the history list so the new run appears at the top.
      ref.invalidate(reportsListProvider);

      // Try to surface a downloadable file. The job runs async server-side
      // so the URL may not be ready immediately — when the format isn't
      // available yet we still confirm the request was accepted.
      Object? launchError;
      try {
        final download = await api.getReportDownloadUrl(
          response.reportId,
          _format,
        );
        await launchUrl(
          Uri.parse(download.url),
          mode: LaunchMode.externalApplication,
        );
      } catch (err) {
        launchError = err;
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            launchError == null
                ? l10n.reportsGenerateSuccess
                : l10n.reportsGenerateQueued,
          ),
        ),
      );
    } on ApiException catch (err) {
      _showErrorSnack(
        context,
        userMessageForCode(err.code, l10n: l10n, fallback: err.message),
      );
    } catch (err) {
      _showErrorSnack(context, l10n.reportsGenerateFailed);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showErrorSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        RadhaSpacing.space24,
        RadhaSpacing.space8,
        RadhaSpacing.space24,
        RadhaSpacing.space24 + viewInsets,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _quickExportTitle(widget.spec.id, l10n),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: RadhaSpacing.space16),
          _DateRangeRow(range: _range, onTap: _pickRange),
          const SizedBox(height: RadhaSpacing.space16),
          _FormatSelector(
            value: _format,
            onChanged: (value) => setState(() => _format = value),
          ),
          const SizedBox(height: RadhaSpacing.space24),
          SizedBox(
            height: kMinTouchTarget,
            child: PrimaryButton(
              label: l10n.reportsGenerate,
              icon: Icons.download_outlined,
              expand: true,
              loading: _submitting,
              onPressed: _submitting ? null : _generate,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateRangeRow extends StatelessWidget {
  const _DateRangeRow({required this.range, required this.onTap});

  final DateTimeRange range;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fmt = DateFormat('d MMM yyyy');

    return Material(
      color: scheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        side: BorderSide(color: scheme.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: RadhaSpacing.space16,
            vertical: RadhaSpacing.space12,
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: RadhaSpacing.space12),
              Expanded(
                child: Text(
                  '${fmt.format(range.start)} – ${fmt.format(range.end)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormatSelector extends StatelessWidget {
  const _FormatSelector({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  static const List<String> _formats = <String>['pdf', 'xlsx', 'csv'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Wrap(
      spacing: RadhaSpacing.space8,
      runSpacing: RadhaSpacing.space8,
      children: _formats.map((f) {
        final selected = value == f;
        return ChoiceChip(
          selected: selected,
          showCheckmark: false,
          label: Text(f.toUpperCase()),
          labelStyle: radhaMonoStyle(
            fontSize: 12,
            weight: FontWeight.w600,
            color: selected ? scheme.primary : scheme.onSurface,
          ),
          backgroundColor: scheme.surfaceContainer,
          selectedColor: scheme.primary.withValues(alpha: 0.12),
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outline,
            width: selected ? 1.5 : 1,
          ),
          onSelected: (_) => onChanged(f),
        );
      }).toList(growable: false),
    );
  }
}

// ─── Scheduled tab ─────────────────────────────────────────────────────

class _ScheduledTab extends ConsumerWidget {
  const _ScheduledTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncSchedules = ref.watch(scheduledReportsProvider);

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(scheduledReportsProvider);
            await ref.read(scheduledReportsProvider.future);
          },
          child: asyncSchedules.when(
            loading: () => const _ListSkeleton(),
            error: (err, _) => _ErrorView(
              title: l10n.reportsErrorTitle,
              message: _errorMessage(err, l10n),
              onRetry: () => ref.invalidate(scheduledReportsProvider),
            ),
            data: (items) {
              if (items.isEmpty) {
                return _EmptyView(
                  title: l10n.reportsScheduledEmptyTitle,
                  body: l10n.reportsScheduledEmptyBody,
                  icon: Icons.schedule_outlined,
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  RadhaSpacing.space24,
                  RadhaSpacing.space24,
                  RadhaSpacing.space24,
                  // Leave room for the FAB so the last row isn't clipped.
                  RadhaSpacing.space64 + RadhaSpacing.space24,
                ),
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: RadhaSpacing.space12),
                itemBuilder: (context, i) => _ScheduledRow(schedule: items[i]),
              );
            },
          ),
        ),
        Positioned(
          right: RadhaSpacing.space24,
          bottom: RadhaSpacing.space24,
          child: FloatingActionButton.extended(
            heroTag: 'reportsScheduleFab',
            onPressed: () => _openScheduleSheet(context, ref),
            icon: const Icon(Icons.add),
            label: Text(l10n.reportsScheduleNew),
          ),
        ),
      ],
    );
  }
}

class _ScheduledRow extends ConsumerWidget {
  const _ScheduledRow({required this.schedule});

  final ScheduledReport schedule;

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final api = ref.read(apiClientProvider);
      if (schedule.paused) {
        await api.resumeScheduledReport(schedule.id);
      } else {
        await api.pauseScheduledReport(schedule.id);
      }
      ref.invalidate(scheduledReportsProvider);
    } on ApiException catch (err) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userMessageForCode(err.code, l10n: l10n, fallback: err.message),
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorGeneric)),
      );
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.reportsDeleteScheduleTitle),
        content: Text(l10n.reportsDeleteScheduleBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: RadhaColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(l10n.reportsDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final api = ref.read(apiClientProvider);
      await api.deleteScheduledReport(schedule.id);
      ref.invalidate(scheduledReportsProvider);
    } on ApiException catch (err) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userMessageForCode(err.code, l10n: l10n, fallback: err.message),
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorGeneric)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fmt = DateFormat('d MMM yyyy, h:mm a');

    final frequency = _frequencyLabel(schedule.frequency, l10n);
    final paused = schedule.paused;
    final lastRunLabel = schedule.lastRunAt == null
        ? l10n.reportsLastRunNever
        : l10n.reportsLastRun(fmt.format(schedule.lastRunAt!.toLocal()));
    final nextRunLabel = schedule.nextRunAt == null
        ? null
        : l10n.reportsNextRun(fmt.format(schedule.nextRunAt!.toLocal()));

    return Container(
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        boxShadow: RadhaShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        schedule.title.isEmpty ? schedule.type : schedule.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: scheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (paused) ...[
                      const SizedBox(width: RadhaSpacing.space8),
                      const _PausedBadge(),
                    ],
                  ],
                ),
                const SizedBox(height: RadhaSpacing.space4),
                Text(
                  frequency,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space8),
                Text(
                  lastRunLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                if (nextRunLabel != null) ...[
                  const SizedBox(height: RadhaSpacing.space2),
                  Text(
                    nextRunLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<_ScheduleAction>(
            tooltip: l10n.reportsScheduleActionsTooltip,
            onSelected: (action) {
              switch (action) {
                case _ScheduleAction.toggle:
                  _toggle(context, ref);
                  break;
                case _ScheduleAction.delete:
                  _delete(context, ref);
                  break;
              }
            },
            itemBuilder: (popupCtx) => <PopupMenuEntry<_ScheduleAction>>[
              PopupMenuItem(
                value: _ScheduleAction.toggle,
                child: Text(
                  paused ? l10n.reportsResume : l10n.reportsPause,
                ),
              ),
              PopupMenuItem(
                value: _ScheduleAction.delete,
                child: Text(
                  l10n.reportsDelete,
                  style: TextStyle(color: RadhaColors.danger),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _ScheduleAction { toggle, delete }

class _PausedBadge extends StatelessWidget {
  const _PausedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space8,
        vertical: RadhaSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: RadhaColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
      ),
      child: Text(
        'PAUSED',
        style: radhaMonoStyle(
          fontSize: 10,
          weight: FontWeight.w700,
          color: RadhaColors.warning,
        ),
      ),
    );
  }
}

String _frequencyLabel(String frequency, AppLocalizations l10n) {
  switch (frequency) {
    case 'daily':
      return l10n.reportsFrequencyDaily;
    case 'weekly':
      return l10n.reportsFrequencyWeekly;
    case 'monthly':
      return l10n.reportsFrequencyMonthly;
  }
  return frequency;
}

// ─── Scheduler bottom sheet ────────────────────────────────────────────

void _openScheduleSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => const _ScheduleSheet(),
  );
}

class _ScheduleSheet extends ConsumerStatefulWidget {
  const _ScheduleSheet();

  @override
  ConsumerState<_ScheduleSheet> createState() => _ScheduleSheetState();
}

class _ScheduleSheetState extends ConsumerState<_ScheduleSheet> {
  QuickReportSpec _spec = _quickExports.first;
  String _frequency = 'weekly';
  String _format = 'pdf';
  int _hourOfDay = 9;
  int _dayOfWeek = 1;
  int _dayOfMonth = 1;
  bool _submitting = false;

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hourOfDay, minute: 0),
    );
    if (picked != null && mounted) {
      setState(() => _hourOfDay = picked.hour);
    }
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _submitting = true);
    try {
      final api = ref.read(apiClientProvider);
      final today = DateTime.now();
      final body = CreateScheduleRequestDto(
        title: _quickExportTitle(_spec.id, l10n),
        type: _spec.type,
        frequency: _frequency,
        dayOfWeek: _frequency == 'weekly' ? _dayOfWeek : null,
        dayOfMonth: _frequency == 'monthly' ? _dayOfMonth : null,
        hourOfDay: _hourOfDay,
        parameters: GenerateReportRequestDto(
          type: _spec.type,
          formats: <String>[_format],
          dateRange: DateRangeDto(
            from: DateTime(today.year, today.month, today.day)
                .subtract(const Duration(days: 30)),
            to: today,
          ),
          title: _quickExportTitle(_spec.id, l10n),
        ),
      );
      await api.createScheduledReport(body);
      if (!mounted) return;
      ref.invalidate(scheduledReportsProvider);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.reportsScheduleSuccess)),
      );
    } on ApiException catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userMessageForCode(err.code, l10n: l10n, fallback: err.message),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorGeneric)),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    final timeLabel = TimeOfDay(
      hour: _hourOfDay,
      minute: 0,
    ).format(context);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          RadhaSpacing.space24,
          RadhaSpacing.space8,
          RadhaSpacing.space24,
          RadhaSpacing.space24 + viewInsets,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.reportsScheduleNew,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: RadhaSpacing.space16),
            _SheetLabel(label: l10n.reportsScheduleReportLabel),
            const SizedBox(height: RadhaSpacing.space8),
            _ReportPickerRow(
              spec: _spec,
              onChanged: (spec) => setState(() {
                _spec = spec;
                _format = spec.defaultFormat;
              }),
            ),
            const SizedBox(height: RadhaSpacing.space16),
            _SheetLabel(label: l10n.reportsFrequency),
            const SizedBox(height: RadhaSpacing.space8),
            _FrequencySelector(
              value: _frequency,
              onChanged: (value) => setState(() => _frequency = value),
            ),
            if (_frequency == 'weekly') ...[
              const SizedBox(height: RadhaSpacing.space16),
              _SheetLabel(label: l10n.reportsScheduleDayOfWeek),
              const SizedBox(height: RadhaSpacing.space8),
              _WeekdaySelector(
                value: _dayOfWeek,
                onChanged: (value) => setState(() => _dayOfWeek = value),
              ),
            ],
            if (_frequency == 'monthly') ...[
              const SizedBox(height: RadhaSpacing.space16),
              _SheetLabel(label: l10n.reportsScheduleDayOfMonth),
              const SizedBox(height: RadhaSpacing.space8),
              _DayOfMonthSelector(
                value: _dayOfMonth,
                onChanged: (value) => setState(() => _dayOfMonth = value),
              ),
            ],
            const SizedBox(height: RadhaSpacing.space16),
            _SheetLabel(label: l10n.reportsScheduleTime),
            const SizedBox(height: RadhaSpacing.space8),
            SecondaryButton(
              label: timeLabel,
              icon: Icons.schedule_outlined,
              onPressed: _pickTime,
            ),
            const SizedBox(height: RadhaSpacing.space16),
            _SheetLabel(label: l10n.reportsScheduleFormat),
            const SizedBox(height: RadhaSpacing.space8),
            _FormatSelector(
              value: _format,
              onChanged: (value) => setState(() => _format = value),
            ),
            const SizedBox(height: RadhaSpacing.space24),
            SizedBox(
              height: kMinTouchTarget,
              child: PrimaryButton(
                label: l10n.reportsScheduleCreate,
                icon: Icons.check_outlined,
                expand: true,
                loading: _submitting,
                onPressed: _submitting ? null : _create,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  const _SheetLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _ReportPickerRow extends StatelessWidget {
  const _ReportPickerRow({required this.spec, required this.onChanged});

  final QuickReportSpec spec;
  final ValueChanged<QuickReportSpec> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: RadhaSpacing.space8,
      runSpacing: RadhaSpacing.space8,
      children: _quickExports.map((q) {
        final selected = q.id == spec.id;
        return ChoiceChip(
          selected: selected,
          showCheckmark: false,
          label: Text(_quickExportTitle(q.id, l10n)),
          onSelected: (_) => onChanged(q),
        );
      }).toList(growable: false),
    );
  }
}

class _FrequencySelector extends StatelessWidget {
  const _FrequencySelector({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = <(String, String)>[
      ('daily', l10n.reportsFrequencyDaily),
      ('weekly', l10n.reportsFrequencyWeekly),
      ('monthly', l10n.reportsFrequencyMonthly),
    ];
    return Wrap(
      spacing: RadhaSpacing.space8,
      runSpacing: RadhaSpacing.space8,
      children: options.map((opt) {
        final selected = opt.$1 == value;
        return ChoiceChip(
          selected: selected,
          showCheckmark: false,
          label: Text(opt.$2),
          onSelected: (_) => onChanged(opt.$1),
        );
      }).toList(growable: false),
    );
  }
}

class _WeekdaySelector extends StatelessWidget {
  const _WeekdaySelector({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    // Sun..Sat — server enum is 0..6.
    const labels = <String>['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Wrap(
      spacing: RadhaSpacing.space8,
      runSpacing: RadhaSpacing.space8,
      children: List<Widget>.generate(7, (i) {
        return ChoiceChip(
          selected: i == value,
          showCheckmark: false,
          label: Text(labels[i]),
          onSelected: (_) => onChanged(i),
        );
      }),
    );
  }
}

class _DayOfMonthSelector extends StatelessWidget {
  const _DayOfMonthSelector({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    // Server caps day-of-month at 28 to avoid month-end edge cases.
    return Wrap(
      spacing: RadhaSpacing.space4,
      runSpacing: RadhaSpacing.space4,
      children: List<Widget>.generate(28, (idx) {
        final day = idx + 1;
        return ChoiceChip(
          selected: day == value,
          showCheckmark: false,
          label: Text('$day'),
          onSelected: (_) => onChanged(day),
        );
      }),
    );
  }
}

// ─── History tab ───────────────────────────────────────────────────────

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncReports = ref.watch(reportsListProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(reportsListProvider);
        await ref.read(reportsListProvider.future);
      },
      child: asyncReports.when(
        loading: () => const _ListSkeleton(),
        error: (err, _) => _ErrorView(
          title: l10n.reportsErrorTitle,
          message: _errorMessage(err, l10n),
          onRetry: () => ref.invalidate(reportsListProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return _EmptyView(
              title: l10n.reportsEmptyTitle,
              body: l10n.reportsEmptyBody,
              icon: Icons.description_outlined,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(RadhaSpacing.space24),
            itemCount: items.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: RadhaSpacing.space12),
            itemBuilder: (context, i) => _HistoryRow(report: items[i]),
          );
        },
      ),
    );
  }
}

class _HistoryRow extends ConsumerWidget {
  const _HistoryRow({required this.report});

  final ReportSummary report;

  Future<void> _download(
    BuildContext context,
    WidgetRef ref,
    String format,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final api = ref.read(apiClientProvider);
      final dl = await api.getReportDownloadUrl(report.reportId, format);
      await launchUrl(
        Uri.parse(dl.url),
        mode: LaunchMode.externalApplication,
      );
    } on ApiException catch (err) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userMessageForCode(err.code, l10n: l10n, fallback: err.message),
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.reportsDownloadFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fmt = DateFormat('d MMM yyyy, h:mm a');

    final completed = report.status == 'completed';
    final failed = report.status == 'failed';
    final canDownload = completed;

    return Container(
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        boxShadow: RadhaShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title.isEmpty ? report.type : report.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: RadhaSpacing.space4),
                Text(
                  fmt.format(report.createdAt.toLocal()),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space8),
                _StatusChip(
                  status: report.status,
                  label: _statusLabel(report.status, l10n),
                ),
                if (failed && report.errorMessage != null) ...[
                  const SizedBox(height: RadhaSpacing.space8),
                  Text(
                    report.errorMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: RadhaColors.danger,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (canDownload)
            IconButton(
              tooltip: l10n.reportsDownload,
              onPressed: () => _download(context, ref, 'pdf'),
              icon: const Icon(Icons.download_outlined),
            ),
        ],
      ),
    );
  }

  String _statusLabel(String status, AppLocalizations l10n) {
    switch (status) {
      case 'completed':
        return l10n.reportsStatusCompleted;
      case 'pending':
      case 'generating':
        return l10n.reportsStatusGenerating;
      case 'failed':
        return l10n.reportsStatusFailed;
      case 'cancelled':
        return l10n.reportsStatusCancelled;
      case 'expired':
        return l10n.reportsStatusExpired;
    }
    return status;
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.label});

  final String status;
  final String label;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'completed':
        color = RadhaColors.primary;
        break;
      case 'failed':
      case 'expired':
        color = RadhaColors.danger;
        break;
      case 'cancelled':
        color = RadhaColors.warning;
        break;
      default:
        color = RadhaColors.warning;
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space8,
        vertical: RadhaSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
      ),
      child: Text(
        label.toUpperCase(),
        style: radhaMonoStyle(
          fontSize: 10,
          weight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ─── Shared loading / empty / error views ─────────────────────────────

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(RadhaSpacing.space24),
      children: const [
        SkeletonLoader(height: 88, radius: RadhaRadii.radiusLg),
        SizedBox(height: RadhaSpacing.space12),
        SkeletonLoader(height: 88, radius: RadhaRadii.radiusLg),
        SizedBox(height: RadhaSpacing.space12),
        SkeletonLoader(height: 88, radius: RadhaRadii.radiusLg),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListView(
      // Stay scrollable so RefreshIndicator can attach.
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.6,
          child: Padding(
            padding: const EdgeInsets.all(RadhaSpacing.space24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RadhaIconTile(
                  icon: icon,
                  tint: scheme.primary,
                  size: 56,
                  iconSize: 28,
                  shape: BoxShape.circle,
                ),
                const SizedBox(height: RadhaSpacing.space24),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space8),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(RadhaSpacing.space24),
      children: [
        MorCompanion(
          mood: MorMood.concern,
          size: 96,
          semanticLabel: l10n.commonCouldNotLoad,
        ),
        const SizedBox(height: RadhaSpacing.space16),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: RadhaSpacing.space8),
        Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: RadhaSpacing.space24),
        SizedBox(
          height: kMinTouchTarget,
          child: SecondaryButton(
            label: l10n.tryAgain,
            icon: Icons.refresh,
            onPressed: onRetry,
          ),
        ),
      ],
    );
  }
}

String _errorMessage(Object error, AppLocalizations l10n) {
  if (error is ApiException) {
    return userMessageForCode(
      error.code,
      l10n: l10n,
      retryAfterSeconds: error is RateLimitException ? error.retryAfter : null,
      fallback: error.message,
    );
  }
  return l10n.errorGeneric;
}

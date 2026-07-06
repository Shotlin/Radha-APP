import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:radha_app/core/auth/auth_controller.dart';
import 'package:radha_app/core/network/api_client.dart';
import 'package:radha_app/core/network/dto/inventory_dto.dart';
import 'package:radha_app/core/network/dto/reports_dto.dart';
import 'package:radha_app/core/network/dto/task_dto.dart';
import 'package:radha_app/core/router/app_router.dart';
import 'package:radha_app/design/app_assets.dart';
import 'package:radha_app/design/tokens.dart';
import 'package:radha_app/design/widgets/biz_screen_hero.dart';
import 'package:radha_app/design/widgets/error_state.dart';
import 'package:radha_app/design/widgets/skeleton_loader.dart';
import 'package:radha_app/l10n/generated/app_localizations.dart';

// ─── Data class ──────────────────────────────────────────────────────────────

class _BizDashData {
  const _BizDashData({
    required this.dashboard,
    required this.recentTasks,
    required this.lowStockCount,
    required this.nearExpiryCount,
  });
  final DashboardSummaryResponse dashboard;
  final List<TaskResponse> recentTasks;
  final int lowStockCount;
  final int nearExpiryCount;
}

// ─── Provider ────────────────────────────────────────────────────────────────

/// Runs [call], returning [fallback] if it throws. Used so a single flaky
/// sub-request can't blank the entire command center — only the core
/// dashboard summary is allowed to surface an error state.
Future<T> _soft<T>(Future<T> Function() call, T fallback) async {
  try {
    return await call();
  } catch (_) {
    return fallback;
  }
}

final _bizDashProvider = FutureProvider.autoDispose<_BizDashData>((ref) async {
  final user = ref.watch(currentUserProvider);
  final client = ref.watch(apiClientProvider);
  final storeId = user?.selectedStoreId ?? '';

  // The dashboard summary is the heart of the screen (OHS + activity charts).
  // If it fails the screen legitimately shows an error + retry. The KPI
  // sub-calls each degrade to a sane default so one flaky endpoint never
  // takes the whole dashboard down with it.
  final results = await Future.wait<Object?>([
    client.getDashboardSummary(storeId, daysAhead: 14),
    _soft(() => client.getTasks(status: 'open', limit: 3), <TaskResponse>[]),
    _soft<InventorySummaryResponse?>(
      () => client.getInventorySummary(storeId),
      null,
    ),
    _soft<int>(
      () async => (await client.getExpiries(
        status: 'yellow,red',
        storeId: storeId,
        limit: 200,
      ))
          .total,
      0,
    ),
  ]);

  final dashboard = results[0] as DashboardSummaryResponse;
  final tasks = results[1] as List<TaskResponse>;
  final inventory = results[2] as InventorySummaryResponse?;
  final nearExpiry = results[3] as int;

  return _BizDashData(
    dashboard: dashboard,
    recentTasks: tasks,
    lowStockCount: inventory?.lowStockCount ?? 0,
    nearExpiryCount: nearExpiry,
  );
});

// ─── Screen ──────────────────────────────────────────────────────────────────

class BusinessDashboardScreen extends ConsumerWidget {
  /// When [standalone] is true the widget wraps itself in a Scaffold with an
  /// AppBar — used when navigated to directly via the `/business-dashboard`
  /// route. When false (default) it returns its body content directly so it
  /// can be embedded inside the home tab's existing Scaffold shell.
  const BusinessDashboardScreen({super.key, this.standalone = false});

  final bool standalone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_bizDashProvider);

    final body = async.when(
      loading: () => const _DashboardSkeleton(),
      error: (_, _) => Center(
        child: ErrorState(
          title: 'Could not load dashboard',
          body: 'Check your connection and try again.',
          onRetry: () => ref.invalidate(_bizDashProvider),
        ),
      ),
      data: (data) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(_bizDashProvider),
        child: ListView(
          padding: const EdgeInsets.all(RadhaSpacing.space16),
          children: [
            _HomeHeroBand(
              nearExpiry: data.nearExpiryCount,
              lowStock: data.lowStockCount,
              openTasks: data.recentTasks.length,
            ),
            const SizedBox(height: RadhaSpacing.space16),
            _OhsHeroCard(dashboard: data.dashboard),
            const SizedBox(height: RadhaSpacing.space16),
            _ActivityChartsRow(dashboard: data.dashboard),
            const SizedBox(height: RadhaSpacing.space16),
            _KpiGrid(
              nearExpiry: data.nearExpiryCount,
              lowStock: data.lowStockCount,
              openTasks: data.recentTasks.length,
              weekTasksDone: data.dashboard.totals.tasksCompleted,
            ),
            const SizedBox(height: RadhaSpacing.space16),
            const _QuickActionsGrid(),
            const SizedBox(height: RadhaSpacing.space16),
            _RecentTasksSection(tasks: data.recentTasks),
            const SizedBox(height: RadhaSpacing.space32),
          ],
        ),
      ),
    );

    if (standalone) {
      return Scaffold(
        appBar: AppBar(title: const Text('Store Dashboard')),
        body: body,
      );
    }
    return body;
  }
}

// ─── Home hero band ──────────────────────────────────────────────────────────

/// Photo greeting band shown above the score card — gives Home the same
/// photo+scrim cold-open every other business screen already has via
/// [BizScreenHero]. Deliberately greeting-only: the stat row, alert banner
/// and quick actions from the original art direction already exist below
/// (the KPI grid and quick-actions grid), so repeating them here would just
/// show the same numbers twice on one screen.
class _HomeHeroBand extends ConsumerWidget {
  const _HomeHeroBand({
    required this.nearExpiry,
    required this.lowStock,
    required this.openTasks,
  });

  final int nearExpiry;
  final int lowStock;
  final int openTasks;

  String _timeGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.homeGreetingMorning;
    if (hour < 17) return l10n.homeGreetingAfternoon;
    return l10n.homeGreetingEvening;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final fallback = l10n.homeGreetingFallbackName;
    final rawName = user?.userId.split('-').first ?? fallback;
    final name = rawName.isEmpty ? fallback : rawName;
    final needsAttention = nearExpiry + lowStock + openTasks > 0;

    return BizScreenHero(
      assetPath: RadhaAssets.heroBusinessHome,
      headline: '${_timeGreeting(l10n)}, $name',
      subtitle: needsAttention
          ? 'Your store needs attention today'
          : "You're all caught up today",
    );
  }
}

// ─── OHS hero card ───────────────────────────────────────────────────────────

class _OhsHeroCard extends StatelessWidget {
  const _OhsHeroCard({required this.dashboard});
  final DashboardSummaryResponse dashboard;

  static String _categoryLabel(String category) {
    switch (category) {
      case 'compliance':
        return 'Scan Compliance';
      case 'inventoryHygiene':
        return 'Inventory Hygiene';
      case 'auditCompletion':
        return 'Audit Pass';
      default:
        return category;
    }
  }

  Color _ohsColor(int score) {
    if (score >= 75) return RadhaColors.success;
    if (score >= 50) return RadhaColors.warning;
    return RadhaColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final snapshot = OhsSnapshot.fromDashboard(dashboard);
    final score = snapshot.ohsScore;
    final color = _ohsColor(score);

    return _PressableCard(
      onTap: () => context.push(AppRoute.ohsDashboard),
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OPERATIONAL HEALTH',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: RadhaColors.primary,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: RadhaSpacing.space4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$score',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: RadhaSpacing.space8),
                        Text(
                          '/ 100',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (snapshot.weekOverWeekDelta != null && snapshot.weekOverWeekDelta != 0) ...[
                          const SizedBox(width: RadhaSpacing.space8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (snapshot.weekOverWeekDelta! >= 0
                                      ? RadhaColors.success
                                      : RadhaColors.primary)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
                            ),
                            child: Text(
                              '${snapshot.weekOverWeekDelta! >= 0 ? '+' : ''}${snapshot.weekOverWeekDelta}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: snapshot.weekOverWeekDelta! >= 0
                                    ? RadhaColors.success
                                    : RadhaColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (snapshot.trend.isNotEmpty) ...[
                      const SizedBox(height: RadhaSpacing.space8),
                      _OhsSparkLine(trend: snapshot.trend, color: color),
                    ],
                  ],
                ),
              ),
              if (score >= 75)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(Icons.verified_outlined, color: RadhaColors.success, size: 28),
                    const SizedBox(height: RadhaSpacing.space4),
                    Text(
                      'RADHA Verified',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: RadhaColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    color: color,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    strokeWidth: 4,
                  ),
                ),
            ],
          ),
          const SizedBox(height: RadhaSpacing.space16),
          ...snapshot.breakdown.take(3).map(
                (b) => Padding(
                  padding: const EdgeInsets.only(bottom: RadhaSpacing.space8),
                  child: _OhsBarRow(label: _categoryLabel(b.category), score: b.score),
                ),
              ),
        ],
      ),
    );
  }
}

class _OhsSparkLine extends StatelessWidget {
  const _OhsSparkLine({required this.trend, required this.color});
  final List<OhsTrendBar> trend;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final spots = trend.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.score.toDouble());
    }).toList();

    return SizedBox(
      height: 36,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineTouchData: LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.4,
              color: color,
              barWidth: 2,
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, barData) => spot.x == (trend.length - 1).toDouble(),
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                  radius: 3,
                  color: color,
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.25),
                    color.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      ),
    );
  }
}

class _OhsBarRow extends StatelessWidget {
  const _OhsBarRow({required this.label, required this.score});
  final String label;
  final int score;

  Color _barColor(int s) {
    if (s >= 75) return RadhaColors.success;
    if (s >= 50) return RadhaColors.warning;
    return RadhaColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: RadhaSpacing.space8),
        Expanded(
          flex: 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: _barColor(score),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: RadhaSpacing.space8),
        SizedBox(
          width: 32,
          child: Text(
            '$score',
            textAlign: TextAlign.end,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── 7-day activity charts ────────────────────────────────────────────────────

class _ActivityChartsRow extends StatelessWidget {
  const _ActivityChartsRow({required this.dashboard});
  final DashboardSummaryResponse dashboard;

  static const _dayAbbrs = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  List<String> _dayLabels() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return _dayAbbrs[d.weekday % 7];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trends = dashboard.trends.length >= 7
        ? dashboard.trends.sublist(dashboard.trends.length - 7)
        : dashboard.trends;
    final labels = _dayLabels();
    final scanData = trends.map((t) => t.scans).toList();
    final taskData = trends.map((t) => t.tasksCompleted).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '7-Day Activity',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: RadhaSpacing.space12),
        Row(
          children: [
            Expanded(
              child: _PressableCard(
                onTap: () {},
                padding: const EdgeInsets.all(RadhaSpacing.space12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SCANS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: RadhaColors.primary,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${scanData.isEmpty ? 0 : scanData.reduce((a, b) => a + b)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: RadhaSpacing.space8),
                    _MiniBarChart(data: scanData, labels: labels, barColor: RadhaColors.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(width: RadhaSpacing.space12),
            Expanded(
              child: _PressableCard(
                onTap: () {},
                padding: const EdgeInsets.all(RadhaSpacing.space12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TASKS DONE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: RadhaColors.complement,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${taskData.isEmpty ? 0 : taskData.reduce((a, b) => a + b)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: RadhaSpacing.space8),
                    _MiniBarChart(data: taskData, labels: labels, barColor: RadhaColors.complement),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniBarChart extends StatelessWidget {
  const _MiniBarChart({required this.data, required this.labels, required this.barColor});
  final List<int> data;
  final List<String> labels;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayData = data.isEmpty ? List.filled(7, 0) : data;
    final displayLabels = labels.isEmpty ? List.filled(displayData.length, '') : labels;
    final maxVal = displayData.reduce(max);
    final safeMax = maxVal == 0 ? 1.0 : maxVal.toDouble();

    final barGroups = displayData.asMap().entries.map((e) {
      final isToday = e.key == displayData.length - 1;
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value.toDouble(),
            width: 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            gradient: LinearGradient(
              colors: [
                barColor.withValues(alpha: isToday ? 1.0 : 0.65),
                barColor.withValues(alpha: isToday ? 0.75 : 0.35),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ],
      );
    }).toList();

    return SizedBox(
      height: 88,
      child: BarChart(
        BarChartData(
          maxY: safeMax * 1.25,
          minY: 0,
          barGroups: barGroups,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: safeMax / 2,
            getDrawingHorizontalLine: (v) => FlLine(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= displayLabels.length) return const SizedBox.shrink();
                  final isToday = i == displayLabels.length - 1;
                  return Text(
                    displayLabels[i],
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 9,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                      color: isToday
                          ? barColor
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => theme.colorScheme.inverseSurface,
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              tooltipRoundedRadius: 6,
              getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                rod.toY.toInt().toString(),
                TextStyle(
                  color: theme.colorScheme.onInverseSurface,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      ),
    );
  }
}

// ─── KPI 2×2 grid ────────────────────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({
    required this.nearExpiry,
    required this.lowStock,
    required this.openTasks,
    required this.weekTasksDone,
  });

  final int nearExpiry;
  final int lowStock;
  final int openTasks;
  final int weekTasksDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _KpiTile(
                value: nearExpiry,
                label: 'Near Expiry',
                icon: Icons.schedule_outlined,
                color: RadhaColors.warning,
                onTap: () => context.push(AppRoute.expiry),
              ),
            ),
            const SizedBox(width: RadhaSpacing.space12),
            Expanded(
              child: _KpiTile(
                value: lowStock,
                label: 'Low Stock',
                icon: Icons.inventory_2_outlined,
                color: RadhaColors.complement,
                onTap: () => context.push(AppRoute.inventory),
              ),
            ),
          ],
        ),
        const SizedBox(height: RadhaSpacing.space12),
        Row(
          children: [
            Expanded(
              child: _KpiTile(
                value: openTasks,
                label: 'Open Tasks',
                icon: Icons.checklist_outlined,
                color: RadhaColors.primary,
                onTap: () => context.push(AppRoute.tasks),
              ),
            ),
            const SizedBox(width: RadhaSpacing.space12),
            Expanded(
              child: _KpiTile(
                value: weekTasksDone,
                label: 'Done This Week',
                icon: Icons.check_circle_outline,
                color: RadhaColors.success,
                onTap: () => context.push(AppRoute.tasks),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final int value;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PressableCard(
      onTap: onTap,
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: RadhaSpacing.space8),
          Text(
            '$value',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick actions grid ───────────────────────────────────────────────────────

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actions = [
      _QAData(icon: Icons.qr_code_scanner_rounded, label: 'Scan', accent: true,
          onTap: () { HapticFeedback.lightImpact(); context.go(AppRoute.scan); }),
      _QAData(icon: Icons.event_available_outlined, label: 'Add Expiry',
          onTap: () => context.push(AppRoute.expiryNew)),
      _QAData(icon: Icons.add_task_outlined, label: 'New Task',
          onTap: () => context.push(AppRoute.taskCreate)),
      _QAData(icon: Icons.local_shipping_outlined, label: 'GRN',
          onTap: () => context.push(AppRoute.grnCreate)),
      _QAData(icon: Icons.inventory_2_outlined, label: 'Inventory',
          onTap: () => context.push(AppRoute.inventory)),
      _QAData(icon: Icons.bar_chart_outlined, label: 'Reports',
          onTap: () => context.push(AppRoute.reports)),
      _QAData(icon: Icons.group_outlined, label: 'Staff & Team',
          onTap: () => context.push(AppRoute.staff)),
      _QAData(icon: Icons.verified_outlined, label: 'Store Health',
          onTap: () => context.push(AppRoute.ohsDashboard)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: RadhaSpacing.space12),
        for (var row = 0; row < 2; row++) ...[
          Row(
            children: [
              for (var col = 0; col < 4; col++) ...[
                Expanded(
                  child: _QuickActionTile(data: actions[row * 4 + col]),
                ),
                if (col < 3) const SizedBox(width: RadhaSpacing.space8),
              ],
            ],
          ),
          if (row == 0) const SizedBox(height: RadhaSpacing.space8),
        ],
      ],
    );
  }
}

class _QAData {
  const _QAData({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool accent;
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.data});
  final _QAData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = data.accent
        ? RadhaColors.primaryTint.withValues(alpha: 0.9)
        : RadhaColors.primaryTint.withValues(alpha: 0.45);
    return _PressableCard(
      onTap: () {
        HapticFeedback.selectionClick();
        data.onTap();
      },
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space8,
        vertical: RadhaSpacing.space12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(data.icon, size: 18, color: RadhaColors.primaryDeep),
          ),
          const SizedBox(height: RadhaSpacing.space4),
          Text(
            data.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recent tasks section ─────────────────────────────────────────────────────

class _RecentTasksSection extends StatelessWidget {
  const _RecentTasksSection({required this.tasks});
  final List<TaskResponse> tasks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Tasks',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () => context.push(AppRoute.tasks),
              child: const Text('See all →'),
            ),
          ],
        ),
        const SizedBox(height: RadhaSpacing.space8),
        if (tasks.isEmpty)
          _PressableCard(
            onTap: () => context.push(AppRoute.taskCreate),
            padding: const EdgeInsets.all(RadhaSpacing.space16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: RadhaColors.primaryTint.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(RadhaRadii.radiusSm),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.add_task_outlined, size: 18, color: RadhaColors.primaryDeep),
                ),
                const SizedBox(width: RadhaSpacing.space12),
                Expanded(
                  child: Text(
                    'No open tasks — create one to get started',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
          )
        else
          Column(
            children: [
              for (var i = 0; i < tasks.length; i++) ...[
                _TaskRow(task: tasks[i]),
                if (i != tasks.length - 1) const SizedBox(height: RadhaSpacing.space8),
              ],
            ],
          ),
      ],
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task});
  final TaskResponse task;

  Color _dotColor() {
    final s = task.status ?? '';
    if (s == 'done' || s == 'completed') return RadhaColors.success;
    if (task.dueDate != null) {
      final due = DateTime.tryParse(task.dueDate!);
      if (due != null && due.isBefore(DateTime.now())) return RadhaColors.warning;
    }
    return RadhaColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = task.status == 'done' || task.status == 'completed';
    return _PressableCard(
      onTap: () {
        HapticFeedback.selectionClick();
        context.push(AppRoute.tasks);
      },
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: _dotColor(), shape: BoxShape.circle),
          ),
          const SizedBox(width: RadhaSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    decorationColor: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (task.assigneeName != null) ...[
                  const SizedBox(height: RadhaSpacing.space2),
                  Text(
                    task.assigneeName!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

// ─── Loading skeleton ─────────────────────────────────────────────────────────

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      children: [
        const SkeletonLoader(height: 140),
        const SizedBox(height: RadhaSpacing.space16),
        const SkeletonLoader(height: 120),
        const SizedBox(height: RadhaSpacing.space16),
        Row(children: const [
          Expanded(child: SkeletonLoader(height: 88)),
          SizedBox(width: RadhaSpacing.space12),
          Expanded(child: SkeletonLoader(height: 88)),
        ]),
        const SizedBox(height: RadhaSpacing.space12),
        Row(children: const [
          Expanded(child: SkeletonLoader(height: 88)),
          SizedBox(width: RadhaSpacing.space12),
          Expanded(child: SkeletonLoader(height: 88)),
        ]),
        const SizedBox(height: RadhaSpacing.space16),
        const SkeletonLoader(height: 140),
      ],
    );
  }
}

// ─── Pressable card ───────────────────────────────────────────────────────────

class _PressableCard extends StatefulWidget {
  const _PressableCard({
    required this.child,
    required this.onTap,
    required this.padding,
  });

  final Widget child;
  final VoidCallback onTap;
  final EdgeInsets padding;

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard> {
  bool _pressed = false;

  void _set(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: const Cubic(0.32, 0.72, 0, 1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

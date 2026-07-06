import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/mode/app_mode_provider.dart';
import '../../core/network/api_client.dart';
import '../../core/network/dto/task_dto.dart';
import '../../core/router/app_router.dart';
import '../../design/app_assets.dart';
import '../../design/tokens.dart';
import '../../design/widgets/biz_metric_row.dart';
import '../../design/widgets/biz_screen_hero.dart';
import '../../design/widgets/empty_state.dart';
import '../../design/widgets/mor_companion.dart';
import '../../l10n/generated/app_localizations.dart';

/// Paginated tasks state — loaded items + page cursor, per status filter.
class _TasksListState {
  const _TasksListState({
    required this.items,
    required this.cursor,
    required this.hasMore,
    required this.loadingMore,
  });

  final List<TaskResponse> items;
  final String? cursor;
  final bool hasMore;
  final bool loadingMore;

  _TasksListState copyWith({
    List<TaskResponse>? items,
    Object? cursor = _sentinel,
    bool? hasMore,
    bool? loadingMore,
  }) {
    return _TasksListState(
      items: items ?? this.items,
      cursor: identical(cursor, _sentinel) ? this.cursor : cursor as String?,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }

  static const _sentinel = Object();
}

/// Cursor-paginated tasks controller, keyed by status filter (one per tab).
/// Mirrors the inventory list pattern so behaviour stays consistent.
class _TasksListController
    extends AutoDisposeFamilyAsyncNotifier<_TasksListState, String?> {
  static const _pageSize = 30;

  // The server has no cursor pagination for this endpoint (just a `limit`
  // cap), so every fetch is the complete result set — `cursor` stays `null`
  // and `hasMore` stays `false`, which makes `loadMore()` below a no-op.
  Future<_TasksListState> _fetch(String? status) async {
    final client = ref.read(apiClientProvider);
    final items = await client.getTasks(status: status, limit: _pageSize);
    return _TasksListState(
      items: items,
      cursor: null,
      hasMore: false,
      loadingMore: false,
    );
  }

  @override
  Future<_TasksListState> build(String? status) async {
    ref.watch(apiClientProvider);
    return _fetch(status);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(arg));
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null) return;
    if (!current.hasMore || current.loadingMore) return;

    state = AsyncValue.data(current.copyWith(loadingMore: true));
    try {
      final next = await _fetch(arg);
      state = AsyncValue.data(
        _TasksListState(
          items: [...current.items, ...next.items],
          cursor: next.cursor,
          hasMore: next.hasMore,
          loadingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncValue.data(current.copyWith(loadingMore: false));
    }
  }
}

final _tasksListControllerProvider = AsyncNotifierProvider.autoDispose
    .family<_TasksListController, _TasksListState, String?>(
      _TasksListController.new,
    );

final _taskStatsProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final client = ref.read(apiClientProvider);
  final tasks = await client.getTasks(limit: 200);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  int open = 0, dueToday = 0, overdue = 0;
  for (final t in tasks) {
    if (t.status == 'completed' || t.status == 'cancelled') continue;
    open++;
    if (t.dueDate != null) {
      try {
        final due = DateTime.parse(t.dueDate!);
        final dueDay = DateTime(due.year, due.month, due.day);
        if (dueDay.isAtSameMomentAs(today)) {
          dueToday++;
        } else if (dueDay.isBefore(today)) {
          overdue++;
        }
      } catch (_) {}
    }
  }
  return {'open': open, 'dueToday': dueToday, 'overdue': overdue};
});

final _staffTasksProvider = FutureProvider.autoDispose<List<TaskResponse>>((ref) async {
  final client = ref.read(apiClientProvider);
  return client.getTasks(limit: 200);
});

/// Tasks list — filter tabs (My Tasks / All / Completed), a priority chip row,
/// polished task cards (priority chip, status dot, assignee + due meta), and a
/// manager-only FAB. Underline tabs + orange accent match the mockup.
class TasksListScreen extends ConsumerStatefulWidget {
  const TasksListScreen({super.key});

  @override
  ConsumerState<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends ConsumerState<TasksListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _index = 0;
  String? _priorityFilter;

  static const _tabCount = 3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && _tabController.index != _index) {
        setState(() => _index = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final currentUser = ref.watch(currentUserProvider);
    // 'owner' is the highest-authority business role (every demo/seed
    // business account is provisioned as owner) — it must be able to do
    // everything a manager can, including creating tasks.
    final isManager =
        currentUser?.roles.contains('owner') == true ||
        currentUser?.roles.contains('manager') == true ||
        currentUser?.roles.contains('admin') == true;
    final isConsumerMode =
        !(currentUser?.roles.any(kBusinessRoles.contains) ?? false);
    // 'Staff' (the middle tab) renders a per-staff workload breakdown, not a
    // flat "all tasks" list, so the l10n `tasksTabAll` label no longer fits.
    const tabs = ['Board', 'Staff', 'Completed'];

    // Tasks is a retail-store feature (assignment, priority, completion by
    // staff). A personal/consumer account has no store and no tasks to load —
    // show the same honest gate as Expiry instead of a doomed API call that
    // would otherwise surface as a confusing "Failed to load tasks" error.
    final body = isConsumerMode
        ? Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(RadhaSpacing.space16),
              child: EmptyState(
                illustration: const MorCompanion(mood: MorMood.guard, size: 104),
                title: l10n.tasksConsumerTitle,
                body: l10n.tasksConsumerBody,
              ),
            ),
          )
        : Column(
            children: [
              BizScreenHero(
                assetPath: RadhaAssets.heroTeamTasks,
                headline: 'Keep every shift on track',
                subtitle: 'Assign, manage and complete tasks',
              ),
              const _TaskStatsRow(),
              const _TaskDateChip(),
              _UnderlineTabs(
                labels: tabs,
                index: _index,
                onChanged: (i) {
                  HapticFeedback.selectionClick();
                  _tabController.animateTo(i);
                },
              ),
              if (_index != 1)
                _PriorityChips(
                  selected: _priorityFilter,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    setState(() => _priorityFilter = value);
                  },
                ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _TaskList(
                      status: 'pending',
                      priorityFilter: _priorityFilter,
                      userId: currentUser?.userId,
                    ),
                    const _StaffWorkloadView(),
                    _TaskList(
                      status: 'completed',
                      priorityFilter: _priorityFilter,
                    ),
                  ],
                ),
              ),
            ],
          );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          l10n.tasksTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: body,
      floatingActionButton: (isManager && !isConsumerMode)
          ? FloatingActionButton.extended(
              heroTag: 'tasks_fab',
              backgroundColor: RadhaColors.primary,
              foregroundColor: RadhaColors.onPrimary,
              onPressed: () {
                HapticFeedback.lightImpact();
                context.push(AppRoute.taskCreate);
              },
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.tasksNewTask),
            )
          : null,
    );
  }
}

// ─── Stats row ───────────────────────────────────────────────────────────────

class _TaskStatsRow extends ConsumerWidget {
  const _TaskStatsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(_taskStatsProvider);
    return statsAsync.when(
      loading: () => BizMetricRow(metrics: const [
        BizMetric(value: '—', label: 'Open', icon: Icons.task_outlined, color: RadhaColors.primary),
        BizMetric(value: '—', label: 'Due today', icon: Icons.today_outlined, color: RadhaColors.warning),
        BizMetric(value: '—', label: 'Overdue', icon: Icons.schedule_outlined, color: RadhaColors.danger),
      ]),
      error: (_, __) => BizMetricRow(metrics: const [
        BizMetric(value: '—', label: 'Open', icon: Icons.task_outlined, color: RadhaColors.primary),
        BizMetric(value: '—', label: 'Due today', icon: Icons.today_outlined, color: RadhaColors.warning),
        BizMetric(value: '—', label: 'Overdue', icon: Icons.schedule_outlined, color: RadhaColors.danger),
      ]),
      data: (stats) => BizMetricRow(metrics: [
        BizMetric(value: '${stats['open'] ?? 0}', label: 'Open', icon: Icons.task_outlined, color: RadhaColors.primary),
        BizMetric(value: '${stats['dueToday'] ?? 0}', label: 'Due today', icon: Icons.today_outlined, color: RadhaColors.warning),
        BizMetric(value: '${stats['overdue'] ?? 0}', label: 'Overdue', icon: Icons.schedule_outlined, color: RadhaColors.danger),
      ]),
    );
  }
}

class _TaskDateChip extends StatelessWidget {
  const _TaskDateChip();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final label = 'Today, ${DateFormat('d MMM').format(now)}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        RadhaSpacing.space16,
        RadhaSpacing.space4,
        RadhaSpacing.space16,
        RadhaSpacing.space4,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: RadhaSpacing.space12,
              vertical: RadhaSpacing.space4,
            ),
            decoration: BoxDecoration(
              color: RadhaColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
              border: Border.all(color: RadhaColors.primary.withValues(alpha: 0.30)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: RadhaColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: RadhaSpacing.space4),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: RadhaColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Staff workload view (Tab 2) ─────────────────────────────────────────────

class _StaffWorkloadView extends ConsumerWidget {
  const _StaffWorkloadView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tasksAsync = ref.watch(_staffTasksProvider);

    return tasksAsync.when(
      loading: () => const _TaskListSkeleton(),
      error: (_, __) => _TaskError(onRetry: () => ref.invalidate(_staffTasksProvider)),
      data: (tasks) {
        final staffMap = <String, _StaffStats>{};
        for (final t in tasks) {
          if (t.assigneeId == null || t.assigneeName == null) continue;
          final entry = staffMap.putIfAbsent(
            t.assigneeId!,
            () => _StaffStats(name: t.assigneeName!),
          );
          entry.total++;
          if (t.status == 'completed') entry.completed++;
        }

        if (staffMap.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(RadhaSpacing.space24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MorCompanion(mood: MorMood.greet, size: 96),
                  const SizedBox(height: RadhaSpacing.space16),
                  Text('No staff assigned yet', style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          );
        }

        final staffList = staffMap.values.toList()
          ..sort((a, b) => b.total.compareTo(a.total));

        return RefreshIndicator(
          color: RadhaColors.primary,
          onRefresh: () async => ref.invalidate(_staffTasksProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              RadhaSpacing.space16,
              RadhaSpacing.space16,
              RadhaSpacing.space16,
              RadhaSpacing.space32 + 72,
            ),
            children: [
              _ShiftCompletionBanner(tasks: tasks),
              const SizedBox(height: RadhaSpacing.space16),
              Text(
                'Staff Workload',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: RadhaSpacing.space12),
              ...staffList.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: RadhaSpacing.space12),
                child: _StaffWorkloadRow(stats: s),
              )),
            ],
          ),
        );
      },
    );
  }
}

class _StaffStats {
  _StaffStats({required this.name});
  final String name;
  int total = 0;
  int completed = 0;
  double get ratio => total == 0 ? 0 : completed / total;
}

class _ShiftCompletionBanner extends StatelessWidget {
  const _ShiftCompletionBanner({required this.tasks});
  final List<TaskResponse> tasks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = tasks.length;
    final done = tasks.where((t) => t.status == 'completed').length;
    final pct = total == 0 ? 0 : (done * 100 ~/ total);
    final color = pct >= 70 ? RadhaColors.success : RadhaColors.primary;

    return Container(
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Shift completion',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '$pct%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: RadhaSpacing.space8),
          ClipRRect(
            borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              minHeight: 8,
              backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.20),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: RadhaSpacing.space4),
          Text(
            '$done of $total tasks complete',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffWorkloadRow extends StatelessWidget {
  const _StaffWorkloadRow({required this.stats});
  final _StaffStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = stats.ratio >= 0.7
        ? RadhaColors.success
        : stats.ratio >= 0.4
            ? RadhaColors.warning
            : RadhaColors.primary;
    final initials = stats.name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Container(
      padding: const EdgeInsets.all(RadhaSpacing.space12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: RadhaColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: RadhaColors.primary,
              ),
            ),
          ),
          const SizedBox(width: RadhaSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        stats.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${stats.completed}/${stats.total}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
                  child: LinearProgressIndicator(
                    value: stats.ratio,
                    minHeight: 6,
                    backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.20),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Underline-style filter tabs with an animated indicator.
class _UnderlineTabs extends StatelessWidget {
  const _UnderlineTabs({
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            GestureDetector(
              onTap: () => onChanged(i),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: RadhaSpacing.space16,
                  vertical: RadhaSpacing.space12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      labels[i],
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: i == index
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: i == index
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: RadhaSpacing.space8),
                    AnimatedContainer(
                      duration: RadhaMotion.fast,
                      curve: RadhaMotion.easeOut,
                      height: 2.5,
                      width: i == index ? 24 : 0,
                      decoration: BoxDecoration(
                        color: RadhaColors.primary,
                        borderRadius: BorderRadius.circular(
                          RadhaRadii.radiusFull,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Horizontal priority filter chips.
class _PriorityChips extends StatelessWidget {
  const _PriorityChips({required this.selected, required this.onChanged});

  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    const priorities = ['high', 'medium', 'low'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        RadhaSpacing.space16,
        RadhaSpacing.space12,
        RadhaSpacing.space16,
        RadhaSpacing.space4,
      ),
      child: Row(
        children: priorities.map((p) {
          final isSelected = selected == p;
          final color = _priorityColor(p);
          return Padding(
            padding: const EdgeInsets.only(right: RadhaSpacing.space8),
            child: GestureDetector(
              onTap: () => onChanged(isSelected ? null : p),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: RadhaMotion.fast,
                padding: const EdgeInsets.symmetric(
                  horizontal: RadhaSpacing.space12,
                  vertical: RadhaSpacing.space8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.12)
                      : theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
                  border: Border.all(
                    color: isSelected ? color : theme.colorScheme.outline,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: RadhaSpacing.space8),
                    Text(
                      _priorityLabel(l10n, p),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Task list that consumes the paginated tasks controller and filters locally
/// by priority and optionally by assigned user. Infinite-scrolls across cursor
/// pages so a busy store's full task list is reachable, not just page one.
class _TaskList extends ConsumerStatefulWidget {
  const _TaskList({required this.status, this.priorityFilter, this.userId});

  final String? status;
  final String? priorityFilter;
  final String? userId;

  @override
  ConsumerState<_TaskList> createState() => _TaskListState();
}

class _TaskListState extends ConsumerState<_TaskList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(_tasksListControllerProvider(widget.status).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(_tasksListControllerProvider(widget.status));

    return tasksAsync.when(
      loading: () => const _TaskListSkeleton(),
      error: (err, _) => _TaskError(
        onRetry: () => ref
            .read(_tasksListControllerProvider(widget.status).notifier)
            .refresh(),
      ),
      data: (state) {
        var items = state.items;
        if (widget.priorityFilter != null) {
          items =
              items.where((t) => t.priority == widget.priorityFilter).toList();
        }
        if (widget.userId != null) {
          items = items.where((t) => t.assigneeId == widget.userId).toList();
        }

        if (items.isEmpty) {
          return RefreshIndicator(
            color: RadhaColors.primary,
            onRefresh: () async => ref
                .read(_tasksListControllerProvider(widget.status).notifier)
                .refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.14),
                Center(
                  child: EmptyState(
                    illustration: const MorCompanion(
                      mood: MorMood.greet,
                      size: 104,
                    ),
                    title: AppLocalizations.of(context).tasksEmptyTitle,
                    body: AppLocalizations.of(context).tasksEmptyBody,
                  ),
                ),
              ],
            ),
          );
        }

        // Only show the load-more footer when the full (unfiltered) list has
        // more pages — a local priority/assignee filter shouldn't imply more.
        final showFooter = state.loadingMore &&
            widget.priorityFilter == null &&
            widget.userId == null;

        return RefreshIndicator(
          color: RadhaColors.primary,
          onRefresh: () async => ref
              .read(_tasksListControllerProvider(widget.status).notifier)
              .refresh(),
          child: ListView.separated(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(
              RadhaSpacing.space20,
              RadhaSpacing.space12,
              RadhaSpacing.space20,
              RadhaSpacing.space32 + 72,
            ),
            itemCount: items.length + (showFooter ? 1 : 0),
            separatorBuilder: (_, _) =>
                const SizedBox(height: RadhaSpacing.space12),
            itemBuilder: (context, index) {
              if (index >= items.length) {
                return const Padding(
                  padding: EdgeInsets.all(RadhaSpacing.space16),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: RadhaColors.primary,
                    ),
                  ),
                );
              }
              return _TaskTile(task: items[index]);
            },
          ),
        );
      },
    );
  }
}

/// Single task card — title + priority chip, meta row, status dot + label.
class _TaskTile extends StatefulWidget {
  const _TaskTile({required this.task});

  final TaskResponse task;

  @override
  State<_TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<_TaskTile> {
  bool _pressed = false;

  void _set(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final task = widget.task;
    final done = task.status == 'completed';

    return GestureDetector(
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: () {
        HapticFeedback.selectionClick();
        context.push('/tasks/${task.id}');
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: RadhaMotion.fast,
        curve: RadhaMotion.spring,
        child: Container(
          padding: const EdgeInsets.all(RadhaSpacing.space16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        decoration: done ? TextDecoration.lineThrough : null,
                        decorationColor: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: RadhaSpacing.space8),
                  _PriorityBadge(priority: task.priority),
                ],
              ),
              const SizedBox(height: RadhaSpacing.space12),
              Row(
                children: [
                  _StatusDot(status: task.status),
                  const SizedBox(width: RadhaSpacing.space8),
                  _StatusLabel(status: task.status),
                  const Spacer(),
                  if (task.dueDate != null) ...[
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: RadhaSpacing.space4),
                    Text(
                      _formatDate(
                        task.dueDate!,
                        Localizations.localeOf(context).toString(),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
              if (task.assigneeName != null) ...[
                const SizedBox(height: RadhaSpacing.space8),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: RadhaSpacing.space4),
                    Text(
                      task.assigneeName!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (task.requiresEvidence == true) ...[
                      const SizedBox(width: RadhaSpacing.space12),
                      Icon(
                        Icons.photo_camera_outlined,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: RadhaSpacing.space4),
                      Text(
                        l10n.taskEvidence,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String iso, String localeName) {
    try {
      return DateFormat('d MMM', localeName).format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }
}

/// Colored priority chip (danger = high, warn = medium, success = low).
class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({this.priority});

  final String? priority;

  @override
  Widget build(BuildContext context) {
    if (priority == null) return const SizedBox.shrink();
    final color = _priorityColor(priority!);
    final label = _priorityLabel(AppLocalizations.of(context), priority!);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: _statusColor(context, status),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = _statusLabel(AppLocalizations.of(context), status);
    return Text(
      label,
      style: theme.textTheme.bodySmall?.copyWith(
        color: _statusColor(context, status),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

Color _statusColor(BuildContext context, String? status) {
  switch (status) {
    case 'completed':
      return RadhaColors.success;
    case 'in_progress':
      return RadhaColors.primary;
    case 'cancelled':
      return Theme.of(context).colorScheme.onSurfaceVariant;
    default:
      return RadhaColors.warning;
  }
}

/// Localized display label for a task priority enum (shared severity labels).
/// Unknown values fall back to a capitalized form of the raw string.
String _priorityLabel(AppLocalizations l10n, String priority) {
  switch (priority) {
    case 'high':
      return l10n.priorityHigh;
    case 'urgent':
      return l10n.priorityUrgent;
    case 'medium':
      return l10n.priorityMedium;
    case 'low':
      return l10n.priorityLow;
    default:
      return priority.isEmpty
          ? priority
          : priority[0].toUpperCase() + priority.substring(1);
  }
}

/// Localized display label for a task status enum. Never surfaces a raw
/// backend value; unknown statuses fall back to a humanized capitalization.
String _statusLabel(AppLocalizations l10n, String? status) {
  switch (status) {
    case 'open':
      return l10n.taskStatusOpen;
    case 'pending':
      return l10n.taskStatusPending;
    case 'in_progress':
      return l10n.taskStatusInProgress;
    case 'completed':
      return l10n.taskStatusCompleted;
    case 'cancelled':
      return l10n.taskStatusCancelled;
    default:
      final raw = (status ?? 'open').replaceAll('_', ' ');
      return raw.isEmpty ? raw : raw[0].toUpperCase() + raw.substring(1);
  }
}

/// Returns the brand-mapped color for a task priority string.
Color _priorityColor(String priority) {
  switch (priority) {
    case 'high':
    case 'urgent':
      return RadhaColors.danger;
    case 'medium':
      return RadhaColors.warning;
    case 'low':
      return RadhaColors.success;
    default:
      return RadhaColors.inkMuted;
  }
}

// ─── Loading / empty / error ─────────────────────────────────────────────────

class _TaskListSkeleton extends StatelessWidget {
  const _TaskListSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        RadhaSpacing.space20,
        RadhaSpacing.space12,
        RadhaSpacing.space20,
        RadhaSpacing.space32,
      ),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: RadhaSpacing.space12),
      itemBuilder: (_, _) => Container(
        height: 96,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
          border: Border.all(color: theme.colorScheme.outline),
        ),
      ),
    );
  }
}

// _EmptyIllustration removed — empty states now use MorCompanion.

class _TaskError extends StatelessWidget {
  const _TaskError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RadhaSpacing.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MorCompanion(
              mood: MorMood.concern,
              size: 96,
              semanticLabel: l10n.expiryCouldNotLoadSemantic,
            ),
            const SizedBox(height: RadhaSpacing.space16),
            Text(l10n.tasksLoadError, style: theme.textTheme.bodyMedium),
            const SizedBox(height: RadhaSpacing.space16),
            OutlinedButton(onPressed: onRetry, child: Text(l10n.tryAgain)),
          ],
        ),
      ),
    );
  }
}

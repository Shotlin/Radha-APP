import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:radha_app/core/network/api_client.dart';
import 'package:radha_app/core/network/dto/task_dto.dart';
import 'package:radha_app/core/router/app_router.dart';
import 'package:radha_app/design/app_assets.dart';
import 'package:radha_app/design/tokens.dart';
import 'package:radha_app/design/widgets/error_state.dart';
import 'package:radha_app/design/widgets/mor_companion.dart';
import 'package:radha_app/design/widgets/skeleton_loader.dart';

// ─── Provider ────────────────────────────────────────────────────────────────

final _auditorTasksProvider =
    FutureProvider.autoDispose<List<TaskResponse>>((ref) async {
  final client = ref.watch(apiClientProvider);
  return client.getTasks(status: 'open', limit: 20);
});

// ─── Screen ──────────────────────────────────────────────────────────────────

class AuditorDashboardScreen extends ConsumerWidget {
  const AuditorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(_auditorTasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Auditor View')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(_auditorTasksProvider),
        child: ListView(
          padding: const EdgeInsets.all(RadhaSpacing.space16),
          children: [
            // Section 1 — Mission card
            _MissionCard(tasksAsync: tasksAsync),
            const SizedBox(height: RadhaSpacing.space16),

            // Section 2 — EAN Audit quick-start
            _EanAuditCard(),
            const SizedBox(height: RadhaSpacing.space16),

            // Section 3 — Open tasks list
            _OpenTasksList(tasksAsync: tasksAsync, ref: ref),
            const SizedBox(height: RadhaSpacing.space32),
          ],
        ),
      ),
    );
  }
}

// ─── Mission card ─────────────────────────────────────────────────────────────

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.tasksAsync});
  final AsyncValue<List<TaskResponse>> tasksAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      decoration: BoxDecoration(
        color: RadhaColors.primary,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusXl),
      ),
      child: Row(
        children: [
          Expanded(
            child: tasksAsync.when(
              loading: () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonLoader(width: 100, height: 12),
                  SizedBox(height: RadhaSpacing.space8),
                  SkeletonLoader(width: 180, height: 22),
                ],
              ),
              error: (_, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TODAY'S MISSION",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: RadhaColors.onPrimary.withValues(alpha: 0.7),
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: RadhaSpacing.space8),
                  Text(
                    'Check your tasks',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: RadhaColors.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              data: (tasks) {
                final n = tasks.length;
                final isEmpty = n == 0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEmpty ? 'ALL CLEAR' : "TODAY'S MISSION",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: RadhaColors.onPrimary.withValues(alpha: 0.7),
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: RadhaSpacing.space8),
                    Text(
                      isEmpty
                          ? 'Shelf is in order\nRun a spot audit'
                          : '$n task${n == 1 ? '' : 's'} waiting',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: RadhaColors.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: RadhaSpacing.space12),
                    _WhiteCtaPill(
                      label: isEmpty ? 'Start EAN Audit' : 'View Tasks',
                      onTap: () {
                        if (isEmpty) {
                          context.push(AppRoute.eanAudit);
                        } else {
                          context.push(AppRoute.tasks);
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: RadhaSpacing.space16),
          const MorCompanion(mood: MorMood.work, size: 80),
        ],
      ),
    );
  }
}

// ─── EAN audit card ───────────────────────────────────────────────────────────

class _EanAuditCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PressableCard(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push(AppRoute.eanAudit);
      },
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: RadhaColors.primaryTint.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(RadhaRadii.radiusSm),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              size: 24,
              color: RadhaColors.primaryDeep,
            ),
          ),
          const SizedBox(width: RadhaSpacing.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EAN Verification Audit',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: RadhaSpacing.space2),
                Text(
                  'Scan shelf products against approved list',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

// ─── Open tasks list ──────────────────────────────────────────────────────────

class _OpenTasksList extends StatelessWidget {
  const _OpenTasksList({required this.tasksAsync, required this.ref});
  final AsyncValue<List<TaskResponse>> tasksAsync;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Open Tasks',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: RadhaSpacing.space12),
        tasksAsync.when(
          loading: () => Column(
            children: const [
              SkeletonLoader(height: 56),
              SizedBox(height: RadhaSpacing.space8),
              SkeletonLoader(height: 56),
              SizedBox(height: RadhaSpacing.space8),
              SkeletonLoader(height: 56),
            ],
          ),
          error: (_, _) => Center(
            child: ErrorState(
              title: 'Could not load tasks',
              onRetry: () => ref.invalidate(_auditorTasksProvider),
            ),
          ),
          data: (tasks) {
            if (tasks.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: RadhaSpacing.space32),
                  child: Column(
                    children: [
                      const MorCompanion(mood: MorMood.greet, size: 64),
                      const SizedBox(height: RadhaSpacing.space12),
                      Text(
                        'No tasks assigned — check with your manager',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: [
                for (var i = 0; i < tasks.length; i++) ...[
                  _AuditorTaskRow(task: tasks[i]),
                  if (i != tasks.length - 1) const SizedBox(height: RadhaSpacing.space8),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AuditorTaskRow extends StatelessWidget {
  const _AuditorTaskRow({required this.task});
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
                if (task.dueDate != null) ...[
                  const SizedBox(height: RadhaSpacing.space2),
                  Text(
                    'Due ${task.dueDate!}',
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

// ─── White CTA pill ───────────────────────────────────────────────────────────

class _WhiteCtaPill extends StatelessWidget {
  const _WhiteCtaPill({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: RadhaColors.onPrimary,
      borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
      child: InkWell(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: RadhaSpacing.space16,
            vertical: RadhaSpacing.space8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: RadhaColors.primaryDeep,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: RadhaSpacing.space4),
              const Icon(Icons.arrow_forward_rounded, size: 16, color: RadhaColors.primaryDeep),
            ],
          ),
        ),
      ),
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

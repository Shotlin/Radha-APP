import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/network/api_client.dart';
import '../../core/network/dto/task_dto.dart';
import '../../design/tokens.dart';
import '../../design/widgets/mor_celebration.dart';
import '../../design/widgets/primary_button.dart';
import '../../l10n/generated/app_localizations.dart';

/// Maps a backend task-status code to its localized label. Shared shape with
/// tasks_list_screen so no raw enum string reaches the UI.
String _statusLabel(AppLocalizations l10n, String? status) {
  switch (status) {
    case 'pending':
      return l10n.taskStatusPending;
    case 'in_progress':
      return l10n.taskStatusInProgress;
    case 'completed':
      return l10n.taskStatusCompleted;
    case 'cancelled':
      return l10n.taskStatusCancelled;
    default:
      return l10n.taskStatusOpen;
  }
}

/// Maps a backend priority code to its localized severity label.
String _priorityLabel(AppLocalizations l10n, String priority) {
  switch (priority) {
    case 'urgent':
      return l10n.priorityUrgent;
    case 'high':
      return l10n.priorityHigh;
    case 'medium':
      return l10n.priorityMedium;
    case 'low':
      return l10n.priorityLow;
    default:
      return priority;
  }
}

/// Provider that fetches a single task by ID.
final _taskDetailProvider = FutureProvider.autoDispose
    .family<TaskResponse, String>((ref, id) async {
      final client = ref.watch(apiClientProvider);
      return client.getTask(id);
    });

/// Task detail — status + title header, a hairline-separated details card, an
/// evidence section, a transition timeline, and a pinned bottom action bar.
/// Transitions are gated on legal moves per R16:
///   pending → in_progress (Start)
///   in_progress → completed (Complete) | cancelled (Cancel)
///   completed / cancelled → read-only
class TaskDetailScreen extends ConsumerStatefulWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  bool _isUpdating = false;

  Future<void> _transitionTo(String newStatus, TaskResponse task) async {
    String? evidenceUrl;
    if (newStatus == 'completed' && task.requiresEvidence == true) {
      evidenceUrl = await _captureEvidence();
      if (evidenceUrl == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).taskEvidenceRequiredSnack,
              ),
            ),
          );
        }
        return;
      }
    }

    HapticFeedback.lightImpact();
    setState(() => _isUpdating = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.updateTask(
        widget.taskId,
        UpdateTaskDto(status: newStatus, evidenceUrl: evidenceUrl),
      );
      ref.invalidate(_taskDetailProvider(widget.taskId));
      if (mounted) {
        HapticFeedback.mediumImpact();
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.taskMovedTo(_statusLabel(l10n, newStatus))),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).taskUpdateError),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<String?> _captureEvidence() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked == null) return null;
    // Full impl: POST /media/presign → PUT bytes → return final URL.
    return picked.path;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taskAsync = ref.watch(_taskDetailProvider(widget.taskId));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: taskAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _ErrorBody(
          onRetry: () => ref.invalidate(_taskDetailProvider(widget.taskId)),
        ),
        data: (task) => _buildBody(context, task),
      ),
    );
  }

  Widget _buildBody(BuildContext context, TaskResponse task) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final localeName = Localizations.localeOf(context).languageCode;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              RadhaSpacing.space20,
              RadhaSpacing.space8,
              RadhaSpacing.space20,
              RadhaSpacing.space24,
            ),
            children: [
              // A warm win-beat crowns a completed task — Mor celebrates the
              // finished job (reduced-motion shows a static celebrate frame).
              if (task.status == 'completed') ...[
                const Center(child: MorCelebration(size: 96)),
                const SizedBox(height: RadhaSpacing.space8),
              ],
              // Status pill + title.
              _StatusPill(status: task.status),
              const SizedBox(height: RadhaSpacing.space12),
              Text(
                task.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              if (task.assigneeName != null || task.dueDate != null) ...[
                const SizedBox(height: RadhaSpacing.space8),
                Text(
                  [
                    if (task.assigneeName != null)
                      l10n.taskAssignedTo(task.assigneeName!),
                    if (task.dueDate != null)
                      l10n.taskDueOn(_formatDate(task.dueDate!, localeName)),
                  ].join(' · '),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: RadhaSpacing.space20),

              // Details card.
              _DetailsCard(task: task),

              if (task.description != null &&
                  task.description!.isNotEmpty) ...[
                const SizedBox(height: RadhaSpacing.space20),
                Text(
                  l10n.taskDescriptionLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space8),
                Text(
                  task.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    height: 1.5,
                  ),
                ),
              ],

              if (task.requiresEvidence == true) ...[
                const SizedBox(height: RadhaSpacing.space20),
                _EvidenceSection(task: task),
              ],

              const SizedBox(height: RadhaSpacing.space20),
              _TransitionTimeline(status: task.status),
            ],
          ),
        ),
        if (!_isUpdating) _ActionBar(task: task, onTransition: _transitionTo),
        if (_isUpdating)
          const Padding(
            padding: EdgeInsets.all(RadhaSpacing.space24),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      ],
    );
  }

  String _formatDate(String iso, String localeName) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('d MMM y', localeName).format(dt);
    } catch (_) {
      return iso;
    }
  }
}

// ─── Status pill ─────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  const _StatusPill({this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context, status);
    final label = _statusLabel(AppLocalizations.of(context), status);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: RadhaSpacing.space12,
          vertical: RadhaSpacing.space4,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: RadhaSpacing.space8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Details card ────────────────────────────────────────────────────────────

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.task});

  final TaskResponse task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final rows = <(String, Widget)>[
      if (task.type != null) (l10n.taskTypeLabel, Text(_titleCase(task.type!))),
      if (task.priority != null)
        (
          l10n.taskPriorityLabel,
          Text(
            _priorityLabel(l10n, task.priority!),
            style: TextStyle(
              color: _priorityColor(task.priority!),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      (
        l10n.taskEvidenceLabel,
        Text(
          task.requiresEvidence == true
              ? l10n.taskEvidencePhotoRequired
              : l10n.taskEvidenceNotRequired,
        ),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: RadhaSpacing.space16,
                vertical: RadhaSpacing.space12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rows[i].$1,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  DefaultTextStyle.merge(
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    child: rows[i].$2,
                  ),
                ],
              ),
            ),
            if (i != rows.length - 1)
              Divider(height: 1, color: theme.colorScheme.outline),
          ],
        ],
      ),
    );
  }

  String _titleCase(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─── Evidence ────────────────────────────────────────────────────────────────

class _EvidenceSection extends StatelessWidget {
  const _EvidenceSection({required this.task});

  final TaskResponse task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final hasEvidence =
        task.evidenceUrls != null && task.evidenceUrls!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.taskEvidenceLabel,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: RadhaSpacing.space8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(RadhaSpacing.space16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
            border: Border.all(
              color: theme.colorScheme.outline,
              style: hasEvidence ? BorderStyle.solid : BorderStyle.none,
            ),
          ),
          child: Row(
            children: [
              Icon(
                hasEvidence
                    ? Icons.check_circle_rounded
                    : Icons.photo_camera_outlined,
                size: 22,
                color: hasEvidence
                    ? RadhaColors.success
                    : RadhaColors.primary,
              ),
              const SizedBox(width: RadhaSpacing.space12),
              Expanded(
                child: Text(
                  hasEvidence
                      ? l10n.taskEvidencePhotosAttached(
                          task.evidenceUrls!.length,
                        )
                      : l10n.taskEvidencePhotoNeeded,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Transition timeline ─────────────────────────────────────────────────────

class _TransitionTimeline extends StatelessWidget {
  const _TransitionTimeline({this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    // Determine which steps are done based on the current status.
    final isCancelled = status == 'cancelled';
    final startedDone =
        status == 'in_progress' || status == 'completed' || isCancelled;
    final completedDone = status == 'completed';

    final steps = <(String, bool)>[
      (l10n.taskTimelineCreated, true),
      (
        isCancelled ? l10n.taskStatusCancelled : l10n.taskTimelineStarted,
        startedDone,
      ),
      (l10n.taskStatusCompleted, completedDone),
    ];

    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          _TimelineDot(label: steps[i].$1, done: steps[i].$2),
          if (i != steps.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(
                  horizontal: RadhaSpacing.space4,
                ),
                color: steps[i + 1].$2
                    ? RadhaColors.success
                    : theme.colorScheme.outline,
              ),
            ),
        ],
      ],
    );
  }
}

class _TimelineDot extends StatelessWidget {
  const _TimelineDot({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: done ? RadhaColors.success : theme.colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: done ? RadhaColors.success : theme.colorScheme.outline,
              width: 2,
            ),
          ),
          child: done
              ? const Icon(
                  Icons.check_rounded,
                  size: 12,
                  color: RadhaColors.onPrimary,
                )
              : null,
        ),
        const SizedBox(height: RadhaSpacing.space4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: done
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ─── Action bar ──────────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.task, required this.onTransition});

  final TaskResponse task;
  final Future<void> Function(String, TaskResponse) onTransition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final status = task.status;

    Widget? content;
    if (status == 'pending') {
      content = PrimaryButton(
        label: l10n.taskActionStart,
        icon: Icons.play_arrow_rounded,
        expand: true,
        onPressed: () => onTransition('in_progress', task),
      );
    } else if (status == 'in_progress') {
      content = Row(
        children: [
          Expanded(
            flex: 2,
            child: PrimaryButton(
              label: l10n.taskActionComplete,
              icon: Icons.check_rounded,
              expand: true,
              onPressed: () => onTransition('completed', task),
            ),
          ),
          const SizedBox(width: RadhaSpacing.space12),
          Expanded(
            child: OutlinedButton(
              onPressed: () => onTransition('cancelled', task),
              style: OutlinedButton.styleFrom(
                foregroundColor: RadhaColors.danger,
                side: BorderSide(
                  color: RadhaColors.danger.withValues(alpha: 0.5),
                ),
                minimumSize: const Size(0, kMinTouchTarget),
              ),
              child: Text(l10n.cancel),
            ),
          ),
        ],
      );
    }

    if (content == null) {
      // Read-only terminal state — no action bar.
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        RadhaSpacing.space20,
        RadhaSpacing.space12,
        RadhaSpacing.space20,
        RadhaSpacing.space12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outline)),
      ),
      child: content,
    );
  }
}

// ─── Error ───────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});

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
            Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: RadhaSpacing.space16),
            Text(l10n.taskLoadFailed, style: theme.textTheme.bodyMedium),
            const SizedBox(height: RadhaSpacing.space16),
            OutlinedButton(onPressed: onRetry, child: Text(l10n.tryAgain)),
          ],
        ),
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

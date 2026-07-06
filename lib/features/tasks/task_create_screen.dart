// Task creation screen (manager / admin only).
//
// Lets an authorised user create a task and (optionally) assign it. Restricted
// to `manager` / `admin` roles — staff see a calm "not authorised" state.
//
// Design rules (from tokens.dart):
//   * One orange accent (#EA580C) — the priority/type selection state and the
//     primary CTA. Priority "urgent" leans on the functional danger red.
//   * 44pt+ touch targets, haptics, staggered entrance, reduce-motion aware.
//   * Plus Jakarta Sans via theme; no emoji-as-icon.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/network/api_client.dart';
import '../../core/network/dto/task_dto.dart';
import '../../design/tokens.dart';
import '../../design/widgets/primary_button.dart';
import '../../l10n/generated/app_localizations.dart';

/// Maps a backend task-type code to its localized label.
String _taskTypeLabel(AppLocalizations l10n, String id) {
  switch (id) {
    case 'ean_audit':
      return l10n.taskTypeEanAudit;
    case 'expiry_check':
      return l10n.taskTypeExpiryCheck;
    case 'inventory_count':
      return l10n.taskTypeInventoryCount;
    case 'display_verification':
      return l10n.taskTypeDisplayVerification;
    default:
      return l10n.taskTypeCustom;
  }
}

/// Maps a backend priority code to its localized severity label.
String _priorityLabel(AppLocalizations l10n, String id) {
  switch (id) {
    case 'urgent':
      return l10n.priorityUrgent;
    case 'high':
      return l10n.priorityHigh;
    case 'medium':
      return l10n.priorityMedium;
    case 'low':
      return l10n.priorityLow;
    default:
      return id;
  }
}

/// Task creation screen — restricted to manager and admin roles.
class TaskCreateScreen extends ConsumerStatefulWidget {
  const TaskCreateScreen({super.key});

  @override
  ConsumerState<TaskCreateScreen> createState() => _TaskCreateScreenState();
}

class _TaskCreateScreenState extends ConsumerState<TaskCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _assigneeController = TextEditingController();

  String _type = 'custom';
  String _priority = 'medium';
  DateTime? _dueDate;
  bool _requiresEvidence = false;
  bool _isSubmitting = false;

  static const _taskTypeIds = [
    'ean_audit',
    'expiry_check',
    'inventory_count',
    'display_verification',
    'custom',
  ];

  static const _priorityIds = ['low', 'medium', 'high', 'urgent'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assigneeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.lightImpact();
    setState(() => _isSubmitting = true);
    try {
      final currentUser = ref.read(currentUserProvider);
      final client = ref.read(apiClientProvider);

      await client.createTask(
        CreateTaskDto(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          type: _type,
          priority: _priority,
          storeId: currentUser?.selectedStoreId,
          assigneeId: _assigneeController.text.trim().isEmpty
              ? null
              : _assigneeController.text.trim(),
          dueDate: _dueDate?.toIso8601String(),
          requiresEvidence: _requiresEvidence,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).taskCreatedSnack),
          ),
        );
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).taskCreateError),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final currentUser = ref.watch(currentUserProvider);
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final isAuthorized =
        currentUser?.roles.contains('owner') == true ||
        currentUser?.roles.contains('manager') == true ||
        currentUser?.roles.contains('admin') == true;

    if (!isAuthorized) {
      return Scaffold(
        appBar: _appBar(context),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(RadhaSpacing.space24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 28,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space16),
                Text(
                  l10n.taskNotAuthorizedTitle,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: RadhaSpacing.space8),
                Text(
                  l10n.taskNotAuthorizedBody,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _appBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(RadhaSpacing.space24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StaggerIn(
                  index: 0,
                  reduceMotion: reduceMotion,
                  child: TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: l10n.taskTitleLabel,
                      hintText: l10n.taskTitleHint,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.taskTitleRequired
                        : null,
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space16),
                _StaggerIn(
                  index: 1,
                  reduceMotion: reduceMotion,
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.taskDescriptionLabel,
                      hintText: l10n.taskDescriptionHint,
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space24),

                // Type chips
                _StaggerIn(
                  index: 2,
                  reduceMotion: reduceMotion,
                  child: _FieldLabel(label: l10n.taskTypeLabel),
                ),
                const SizedBox(height: RadhaSpacing.space8),
                _StaggerIn(
                  index: 3,
                  reduceMotion: reduceMotion,
                  child: Wrap(
                    spacing: RadhaSpacing.space8,
                    runSpacing: RadhaSpacing.space8,
                    children: [
                      for (final t in _taskTypeIds)
                        _SelectChip(
                          label: _taskTypeLabel(l10n, t),
                          selected: _type == t,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _type = t);
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space24),

                // Priority chips
                _StaggerIn(
                  index: 4,
                  reduceMotion: reduceMotion,
                  child: _FieldLabel(label: l10n.taskPriorityLabel),
                ),
                const SizedBox(height: RadhaSpacing.space8),
                _StaggerIn(
                  index: 5,
                  reduceMotion: reduceMotion,
                  child: Wrap(
                    spacing: RadhaSpacing.space8,
                    runSpacing: RadhaSpacing.space8,
                    children: [
                      for (final p in _priorityIds)
                        _SelectChip(
                          label: _priorityLabel(l10n, p),
                          selected: _priority == p,
                          accent: p == 'urgent'
                              ? RadhaColors.danger
                              : p == 'high'
                                  ? RadhaColors.warning
                                  : null,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _priority = p);
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space24),

                // Store (pre-filled from session, read-only)
                _StaggerIn(
                  index: 6,
                  reduceMotion: reduceMotion,
                  child: TextFormField(
                    initialValue:
                        currentUser?.selectedStoreName ??
                        currentUser?.selectedStoreId ??
                        '',
                    decoration: InputDecoration(labelText: l10n.taskStoreLabel),
                    enabled: false,
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space16),

                // Assignee (text input for now)
                _StaggerIn(
                  index: 7,
                  reduceMotion: reduceMotion,
                  child: TextFormField(
                    controller: _assigneeController,
                    decoration: InputDecoration(
                      labelText: l10n.taskAssigneeLabel,
                      hintText: l10n.taskAssigneeHint,
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space16),

                // Due date picker
                _StaggerIn(
                  index: 8,
                  reduceMotion: reduceMotion,
                  child: InkWell(
                    onTap: _pickDueDate,
                    borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.taskDueDateLabel,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _dueDate == null
                                  ? l10n.taskSelectDate
                                  : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: _dueDate == null
                                    ? scheme.onSurfaceVariant
                                    : scheme.onSurface,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 20,
                            color: scheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space8),

                // Evidence toggle
                _StaggerIn(
                  index: 9,
                  reduceMotion: reduceMotion,
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.taskRequiresEvidence),
                    subtitle: Text(
                      l10n.taskRequiresEvidenceSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    value: _requiresEvidence,
                    activeThumbColor: scheme.primary,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      setState(() => _requiresEvidence = v);
                    },
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space32),

                // Submit
                _StaggerIn(
                  index: 10,
                  reduceMotion: reduceMotion,
                  child: PrimaryButton(
                    label: l10n.taskCreateCta,
                    icon: Icons.add_task_rounded,
                    expand: true,
                    loading: _isSubmitting,
                    onPressed: _isSubmitting ? null : _submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => context.pop(),
      ),
      title: Text(
        AppLocalizations.of(context).taskCreateTitle,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Small uppercase field label sitting above a chip cluster.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        letterSpacing: 1.2,
      ),
    );
  }
}

/// Single-select chip with a tactile press-scale. `accent` overrides the
/// default orange when a priority needs a functional colour (high → amber,
/// urgent → danger).
class _SelectChip extends StatefulWidget {
  const _SelectChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.accent,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? accent;

  @override
  State<_SelectChip> createState() => _SelectChipState();
}

class _SelectChipState extends State<_SelectChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = widget.accent ?? scheme.primary;
    final selected = widget.selected;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final scale = _pressed && !reduceMotion ? 0.95 : 1.0;

    return AnimatedScale(
      scale: scale,
      duration: RadhaMotion.fast,
      curve: RadhaMotion.easeOut,
      child: AnimatedContainer(
        duration: RadhaMotion.fast,
        curve: RadhaMotion.easeOut,
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: 0.06)
              : scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
          border: Border.all(
            color: selected ? accent : scheme.outline,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: (v) => setState(() => _pressed = v),
            borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: kMinTouchTarget),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: RadhaSpacing.space16,
                  vertical: RadhaSpacing.space8,
                ),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    widget.label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: selected ? accent : scheme.onSurface,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Staggered fade + rise used for each form field. Honours reduce-motion by
/// rendering the child immediately, and caps the per-field delay.
class _StaggerIn extends StatefulWidget {
  const _StaggerIn({
    required this.index,
    required this.reduceMotion,
    required this.child,
  });

  final int index;
  final bool reduceMotion;
  final Widget child;

  @override
  State<_StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<_StaggerIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: RadhaMotion.medium,
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _c,
    curve: RadhaMotion.easeOut,
  );
  late final Animation<Offset> _offset = Tween<Offset>(
    begin: const Offset(0, 0.06),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _c, curve: RadhaMotion.easeOut));

  @override
  void initState() {
    super.initState();
    if (widget.reduceMotion) {
      _c.value = 1;
    } else {
      final delay = (40 * widget.index).clamp(0, 320);
      Future<void>.delayed(Duration(milliseconds: delay), () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reduceMotion) return widget.child;
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}

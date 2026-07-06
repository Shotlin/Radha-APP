import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:radha_app/core/network/api_client.dart';
import 'package:radha_app/core/network/dto/misc_dto.dart';
import 'package:radha_app/design/tokens.dart';
import 'package:radha_app/design/app_assets.dart';
import 'package:radha_app/design/widgets/mor_companion.dart';
import 'package:radha_app/design/widgets/skeleton_loader.dart';
import 'package:radha_app/design/widgets/error_state.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────

typedef _FamilyMember = FamilyMemberDto;

final _familyMembersProvider =
    FutureProvider.autoDispose<List<_FamilyMember>>((ref) async {
  final client = ref.watch(apiClientProvider);
  return client.getFamilyMembers();
});

// ─── Screen ───────────────────────────────────────────────────────────────────

class FamilySharingScreen extends ConsumerWidget {
  const FamilySharingScreen({super.key});

  static const int _maxFreeMembers = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(_familyMembersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Sharing'),
        actions: [
          IconButton(
            tooltip: 'Add member',
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showInviteSheet(context, ref);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(_familyMembersProvider),
        child: membersAsync.when(
          loading: () => _LoadingBody(),
          error: (_, _) => Center(
            child: ErrorState(
              title: 'Could not load family members',
              onRetry: () => ref.invalidate(_familyMembersProvider),
            ),
          ),
          data: (members) => _Body(
            members: members,
            onInvite: () => _showInviteSheet(context, ref),
            onRemove: (member) => _confirmRemove(context, ref, member),
          ),
        ),
      ),
    );
  }

  void _showInviteSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InviteSheet(onSuccess: () => ref.invalidate(_familyMembersProvider)),
    );
  }

  void _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    _FamilyMember member,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove member?'),
        content: Text(
          '${member.name} will lose access to shared family benefits.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _doRemove(context, ref, member);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _doRemove(
    BuildContext context,
    WidgetRef ref,
    _FamilyMember member,
  ) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.removeFamilyMember(member.id);
      ref.invalidate(_familyMembersProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${member.name} removed from your family plan'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not remove member — try again'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({
    required this.members,
    required this.onInvite,
    required this.onRemove,
  });

  final List<_FamilyMember> members;
  final VoidCallback onInvite;
  final void Function(_FamilyMember member) onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usedSlots = members.length;
    final slotsLeft = (FamilySharingScreen._maxFreeMembers - usedSlots)
        .clamp(0, FamilySharingScreen._maxFreeMembers);

    return ListView(
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      children: [
        _PlanBanner(usedSlots: usedSlots, totalSlots: FamilySharingScreen._maxFreeMembers),
        const SizedBox(height: RadhaSpacing.space16),

        if (members.isEmpty) ...[
          _EmptyState(onInvite: onInvite),
        ] else ...[
          Text(
            'Members (${members.length}/${FamilySharingScreen._maxFreeMembers})',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: RadhaSpacing.space12),
          for (final m in members) ...[
            _MemberRow(member: m, onRemove: () => onRemove(m)),
            const SizedBox(height: RadhaSpacing.space8),
          ],
          if (slotsLeft > 0) ...[
            const SizedBox(height: RadhaSpacing.space8),
            _AddMoreRow(onTap: onInvite, slotsLeft: slotsLeft),
          ],
        ],
        const SizedBox(height: RadhaSpacing.space24),
        _BenefitsCard(),
        const SizedBox(height: RadhaSpacing.space32),
      ],
    );
  }
}

// ─── Plan banner ──────────────────────────────────────────────────────────────

class _PlanBanner extends StatelessWidget {
  const _PlanBanner({required this.usedSlots, required this.totalSlots});
  final int usedSlots;
  final int totalSlots;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = usedSlots / totalSlots;

    return Container(
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
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: RadhaSpacing.space8,
                  vertical: RadhaSpacing.space4,
                ),
                decoration: BoxDecoration(
                  color: RadhaColors.primaryTint.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
                ),
                child: Text(
                  'FREE PLAN',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: RadhaColors.primaryDeep,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '$usedSlots / $totalSlots members',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: RadhaSpacing.space12),
          ClipRRect(
            borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: theme.colorScheme.outline,
              valueColor: AlwaysStoppedAnimation<Color>(
                pct >= 1.0 ? RadhaColors.warning : RadhaColors.primary,
              ),
            ),
          ),
          const SizedBox(height: RadhaSpacing.space8),
          Text(
            pct >= 1.0
                ? 'Slot limit reached — upgrade for unlimited members'
                : 'Share RADHA benefits with up to $totalSlots family members',
            style: theme.textTheme.bodySmall?.copyWith(
              color: pct >= 1.0
                  ? RadhaColors.warning
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onInvite});
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: RadhaSpacing.space24),
      child: Column(
        children: [
          const MorCompanion(mood: MorMood.greet, size: 80),
          const SizedBox(height: RadhaSpacing.space16),
          Text(
            'Share with family',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: RadhaSpacing.space8),
          Text(
            'Invite up to 5 family members to share\nyour allergen profiles, expiry alerts, and scan history.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: RadhaSpacing.space24),
          FilledButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              onInvite();
            },
            icon: const Icon(Icons.person_add_outlined, size: 18),
            label: const Text('Invite a Family Member'),
            style: FilledButton.styleFrom(
              backgroundColor: RadhaColors.primary,
              foregroundColor: RadhaColors.onPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: RadhaSpacing.space24,
                vertical: RadhaSpacing.space12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Member row ───────────────────────────────────────────────────────────────

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member, required this.onRemove});
  final _FamilyMember member;
  final VoidCallback onRemove;

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return RadhaColors.success;
      case 'pending':
        return RadhaColors.warning;
      default:
        return RadhaColors.inkMuted;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'pending':
        return 'Invite sent';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        side: BorderSide(color: theme.colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: RadhaSpacing.space16,
          vertical: RadhaSpacing.space12,
        ),
        child: Row(
          children: [
            _MiniAvatar(seed: member.name),
            const SizedBox(width: RadhaSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: RadhaSpacing.space2),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _statusColor(member.status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: RadhaSpacing.space4),
                      Text(
                        _statusLabel(member.status),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, size: 20),
              color: theme.colorScheme.error,
              tooltip: 'Remove',
              onPressed: () {
                HapticFeedback.selectionClick();
                onRemove();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  const _MiniAvatar({required this.seed});
  final String seed;

  @override
  Widget build(BuildContext context) {
    final initial = seed.isNotEmpty ? seed[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: 20,
      backgroundColor: RadhaColors.primaryTint.withValues(alpha: 0.4),
      child: Text(
        initial,
        style: const TextStyle(
          color: RadhaColors.primaryDeep,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    );
  }
}

// ─── Add more row ──────────────────────────────────────────────────────────────

class _AddMoreRow extends StatelessWidget {
  const _AddMoreRow({required this.onTap, required this.slotsLeft});
  final VoidCallback onTap;
  final int slotsLeft;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        side: BorderSide(
          color: RadhaColors.primary.withValues(alpha: 0.4),
          style: BorderStyle.solid,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: RadhaSpacing.space16,
            vertical: RadhaSpacing.space12,
          ),
          child: Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                color: RadhaColors.primary,
                size: 20,
              ),
              const SizedBox(width: RadhaSpacing.space12),
              Text(
                'Add another member ($slotsLeft ${slotsLeft == 1 ? 'slot' : 'slots'} left)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: RadhaColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Benefits card ────────────────────────────────────────────────────────────

class _BenefitsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What family members get',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: RadhaSpacing.space12),
          for (final item in _benefits)
            Padding(
              padding: const EdgeInsets.only(bottom: RadhaSpacing.space8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.$1, size: 18, color: RadhaColors.primary),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      item.$2,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static const _benefits = [
    (Icons.shield_outlined, 'Shared allergen profile — family members get your allergy alerts on scanned products'),
    (Icons.notifications_outlined, 'Expiry reminders — get notified when shared household items are about to expire'),
    (Icons.qr_code_scanner_outlined, 'Scan history — see what each family member scanned and when'),
    (Icons.star_outline_rounded, 'Premium features — family members on free plan gain access to your subscription tier'),
  ];
}

// ─── Loading body ─────────────────────────────────────────────────────────────

class _LoadingBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      children: const [
        SkeletonLoader(height: 96),
        SizedBox(height: RadhaSpacing.space16),
        SkeletonLoader(height: 16, width: 140),
        SizedBox(height: RadhaSpacing.space12),
        SkeletonLoader(height: 64),
        SizedBox(height: RadhaSpacing.space8),
        SkeletonLoader(height: 64),
        SizedBox(height: RadhaSpacing.space8),
        SkeletonLoader(height: 64),
      ],
    );
  }
}

// ─── Invite sheet ─────────────────────────────────────────────────────────────

class _InviteSheet extends ConsumerStatefulWidget {
  const _InviteSheet({required this.onSuccess});
  final VoidCallback onSuccess;

  @override
  ConsumerState<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends ConsumerState<_InviteSheet> {
  final _phoneController = TextEditingController();
  bool _isSending = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      setState(() => _error = 'Enter a valid 10-digit mobile number');
      return;
    }

    setState(() {
      _isSending = true;
      _error = null;
    });

    try {
      final client = ref.read(apiClientProvider);
      await client.inviteFamilyMember({'mobile': phone});
      widget.onSuccess();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invite sent — ask them to open RADHA and accept'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      final msg = e.toString();
      String label;
      if (msg.contains('409') || msg.contains('already')) {
        label = 'This number is already in your family plan';
      } else if (msg.contains('403') || msg.contains('limit')) {
        label = 'Member limit reached — upgrade your plan for more';
      } else {
        label = 'Could not send invite — check the number and try again';
      }
      if (mounted) setState(() => _error = label);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: RadhaSpacing.space24,
        right: RadhaSpacing.space24,
        top: RadhaSpacing.space8,
        bottom: mq.viewInsets.bottom + RadhaSpacing.space32,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(RadhaRadii.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: RadhaSpacing.space16),
              decoration: BoxDecoration(
                color: theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
              ),
            ),
          ),
          Text(
            'Invite a family member',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: RadhaSpacing.space4),
          Text(
            'They\'ll receive an invite and can join your family plan.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: RadhaSpacing.space20),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: InputDecoration(
              hintText: '10-digit mobile number',
              prefixIcon: const Icon(Icons.phone_outlined),
              prefixText: '+91  ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
              ),
              errorText: _error,
            ),
          ),
          const SizedBox(height: RadhaSpacing.space24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSending ? null : _send,
              style: FilledButton.styleFrom(
                backgroundColor: RadhaColors.primary,
                foregroundColor: RadhaColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: RadhaSpacing.space16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
                ),
              ),
              child: _isSending
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Send Invite', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

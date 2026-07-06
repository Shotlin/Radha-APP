import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:radha_app/core/auth/auth_controller.dart';
import 'package:radha_app/core/network/api_client.dart';
import 'package:radha_app/core/router/app_router.dart';
import 'package:radha_app/design/app_assets.dart';
import 'package:radha_app/design/tokens.dart';
import 'package:radha_app/design/widgets/mor_companion.dart';
import 'package:radha_app/design/widgets/primary_button.dart';

class StaffManagementScreen extends ConsumerWidget {
  const StaffManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final storeName = user?.selectedStoreName ?? 'Your Store';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff & Team'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.only(left: RadhaSpacing.space16, bottom: RadhaSpacing.space8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                label: Text(storeName, style: theme.textTheme.labelSmall),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          _showInviteSheet(context, ref);
        },
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Invite'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(RadhaSpacing.space16),
        children: [
          // Free tier info card
          Container(
            padding: const EdgeInsets.all(RadhaSpacing.space16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Row(
              children: [
                Icon(Icons.group_outlined, color: RadhaColors.primary, size: 24),
                const SizedBox(width: RadhaSpacing.space12),
                Expanded(
                  child: Text(
                    'Up to 5 team members · Free tier',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push(AppRoute.subscription),
                  child: const Text('Upgrade'),
                ),
              ],
            ),
          ),
          const SizedBox(height: RadhaSpacing.space32),

          // Placeholder state
          Center(
            child: Column(
              children: [
                const MorCompanion(mood: MorMood.work, size: 80),
                const SizedBox(height: RadhaSpacing.space16),
                Text(
                  'Build your team',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: RadhaSpacing.space32),
                  child: Text(
                    'Invite staff, managers, and auditors to your store. '
                    'They\'ll see tasks, run audits, and keep your store running.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space24),
                PrimaryButton(
                  label: 'Invite a Team Member',
                  onPressed: () => _showInviteSheet(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: RadhaSpacing.space32),

          // Role guide
          Text(
            'Roles',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: RadhaSpacing.space12),
          _RoleInfoRow(
            icon: Icons.manage_accounts_outlined,
            role: 'Manager',
            description: 'Can assign tasks, view reports, create GRNs',
          ),
          const SizedBox(height: RadhaSpacing.space8),
          _RoleInfoRow(
            icon: Icons.badge_outlined,
            role: 'Staff',
            description: 'Scans, expiry entries, task completion',
          ),
          const SizedBox(height: RadhaSpacing.space8),
          _RoleInfoRow(
            icon: Icons.fact_check_outlined,
            role: 'Auditor',
            description: 'EAN verification audits, shelf checks',
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showInviteSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _InviteSheetContent(),
    );
  }
}

// ─── Role info row ────────────────────────────────────────────────────────────

class _RoleInfoRow extends StatelessWidget {
  const _RoleInfoRow({
    required this.icon,
    required this.role,
    required this.description,
  });
  final IconData icon;
  final String role;
  final String description;

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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: RadhaColors.primaryTint.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(RadhaRadii.radiusSm),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: RadhaColors.primaryDeep),
          ),
          const SizedBox(width: RadhaSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(role, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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

// ─── Invite bottom sheet ──────────────────────────────────────────────────────

class _InviteSheetContent extends ConsumerStatefulWidget {
  const _InviteSheetContent();

  @override
  ConsumerState<_InviteSheetContent> createState() => _InviteSheetContentState();
}

class _InviteSheetContentState extends ConsumerState<_InviteSheetContent> {
  final _phoneController = TextEditingController();
  String _selectedRole = 'staff';
  bool _isSending = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _roleDescription(String role) {
    switch (role) {
      case 'manager':
        return 'Can assign tasks, view all reports, and create GRNs';
      case 'auditor':
        return 'Can run EAN verification audits and log findings';
      default:
        return 'Can scan products, update expiry, and complete tasks';
    }
  }

  Future<void> _sendInvite() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit mobile number')),
      );
      return;
    }
    setState(() => _isSending = true);
    try {
      final user = ref.read(currentUserProvider);
      final storeId = user?.selectedStoreId ?? '';
      final client = ref.read(apiClientProvider);
      await client.grantStoreAccess(storeId, {'mobile': phone, 'role': _selectedRole});
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invite sent — ask them to open RADHA and join your store'),
          ),
        );
      }
    } catch (e) {
      final msg = e.toString();
      String snack;
      if (msg.contains('409')) {
        snack = 'This number is already in your team';
      } else if (msg.contains('403')) {
        snack = 'Member limit reached. Upgrade your plan to add more.';
      } else {
        snack = 'Could not send invite. Please try again.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(snack)));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);

    return Container(
      margin: const EdgeInsets.all(RadhaSpacing.space8),
      padding: EdgeInsets.only(
        left: RadhaSpacing.space16,
        right: RadhaSpacing.space16,
        top: RadhaSpacing.space24,
        bottom: mq.viewInsets.bottom + RadhaSpacing.space24,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusXl),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invite a Team Member',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: RadhaSpacing.space20),

          // Phone field
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Mobile number',
              hintText: '10-digit number',
              prefixText: '+91 ',
              counterText: '',
            ),
          ),
          const SizedBox(height: RadhaSpacing.space20),

          // Role chips
          Text('Role', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: RadhaSpacing.space8),
          Wrap(
            spacing: RadhaSpacing.space8,
            children: [
              for (final role in ['manager', 'staff', 'auditor'])
                ChoiceChip(
                  label: Text(role[0].toUpperCase() + role.substring(1)),
                  selected: _selectedRole == role,
                  onSelected: (v) {
                    if (v) setState(() => _selectedRole = role);
                  },
                ),
            ],
          ),
          const SizedBox(height: RadhaSpacing.space8),
          Text(
            _roleDescription(_selectedRole),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: RadhaSpacing.space24),

          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: _isSending ? 'Sending…' : 'Send Invite',
              onPressed: _isSending ? null : _sendInvite,
            ),
          ),
        ],
      ),
    );
  }
}


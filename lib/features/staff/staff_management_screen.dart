import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:radha_app/core/auth/auth_controller.dart';
import 'package:radha_app/core/network/api_client.dart';
import 'package:radha_app/core/network/api_exception.dart';
import 'package:radha_app/core/router/app_router.dart';
import 'package:radha_app/core/store/store_providers.dart';
import 'package:radha_app/design/app_assets.dart';
import 'package:radha_app/design/tokens.dart';
import 'package:radha_app/design/widgets/mor_companion.dart';
import 'package:radha_app/design/widgets/primary_button.dart';

String _roleLabel(String role) => role.isEmpty
    ? role
    : role[0].toUpperCase() + role.substring(1);

class StaffManagementScreen extends ConsumerWidget {
  const StaffManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final storeId = user?.selectedStoreId;
    final storeName = storeId == null
        ? null
        : ref.watch(storeDetailsProvider(storeId)).valueOrNull?.name;
    final theme = Theme.of(context);
    final staffAsync =
        storeId == null ? null : ref.watch(storeStaffProvider(storeId));

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
                label: Text(storeName ?? 'Your Store', style: theme.textTheme.labelSmall),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: storeId == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                _showInviteSheet(context, ref, storeId);
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

          if (storeId == null)
            const SizedBox.shrink()
          else
            staffAsync!.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(RadhaSpacing.space32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (_, _) => _EmptyTeamState(
                onInvite: () => _showInviteSheet(context, ref, storeId),
              ),
              data: (staff) => staff.isEmpty
                  ? _EmptyTeamState(
                      onInvite: () => _showInviteSheet(context, ref, storeId),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Team (${staff.length})',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: RadhaSpacing.space12),
                        for (final member in staff) ...[
                          _StaffMemberRow(
                            member: member,
                            onRemove: () => _removeMember(
                              context,
                              ref,
                              storeId,
                              member,
                            ),
                          ),
                          const SizedBox(height: RadhaSpacing.space8),
                        ],
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

  void _showInviteSheet(BuildContext context, WidgetRef ref, String storeId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InviteSheetContent(storeId: storeId),
    ).then((invited) {
      if (invited == true) ref.invalidate(storeStaffProvider(storeId));
    });
  }

  Future<void> _removeMember(
    BuildContext context,
    WidgetRef ref,
    String storeId,
    StaffMemberResponse member,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove team member?'),
        content: Text(
          '${member.name?.isNotEmpty == true ? member.name : member.email ?? member.mobile ?? 'This person'} '
          'will lose access to this store.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(apiClientProvider).revokeStoreAccess(storeId, member.userId);
      ref.invalidate(storeStaffProvider(storeId));
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not remove team member. Please try again.')),
        );
      }
    }
  }
}

class _EmptyTeamState extends StatelessWidget {
  const _EmptyTeamState({required this.onInvite});
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
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
          PrimaryButton(label: 'Invite a Team Member', onPressed: onInvite),
        ],
      ),
    );
  }
}

class _StaffMemberRow extends StatelessWidget {
  const _StaffMemberRow({required this.member, required this.onRemove});
  final StaffMemberResponse member;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final identity = (member.name?.isNotEmpty ?? false)
        ? member.name!
        : member.email ?? member.mobile ?? 'Team member';
    return Container(
      padding: const EdgeInsets.all(RadhaSpacing.space12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: RadhaColors.primaryTint.withValues(alpha: 0.45),
            child: Text(
              identity.isNotEmpty ? identity[0].toUpperCase() : '?',
              style: TextStyle(color: RadhaColors.primaryDeep, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: RadhaSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(identity, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                if (member.email != null && member.email!.isNotEmpty && identity != member.email)
                  Text(
                    member.email!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          Chip(
            label: Text(_roleLabel(member.role)),
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            tooltip: 'Remove',
            onPressed: onRemove,
          ),
        ],
      ),
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

enum _EmailCheckState { idle, checking, found, notFound, error }

class _InviteSheetContent extends ConsumerStatefulWidget {
  const _InviteSheetContent({required this.storeId});
  final String storeId;

  @override
  ConsumerState<_InviteSheetContent> createState() => _InviteSheetContentState();
}

class _InviteSheetContentState extends ConsumerState<_InviteSheetContent> {
  final _emailController = TextEditingController();
  String _selectedRole = 'staff';
  bool _isSending = false;

  Timer? _debounce;
  _EmailCheckState _checkState = _EmailCheckState.idle;
  String? _resolvedUserId;
  String? _resolvedName;
  bool _alreadyMember = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _emailController.dispose();
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

  void _onEmailChanged(String value) {
    _debounce?.cancel();
    _resolvedUserId = null;
    _resolvedName = null;
    _alreadyMember = false;
    final email = value.trim();
    if (!_looksLikeEmail(email)) {
      setState(() => _checkState = _EmailCheckState.idle);
      return;
    }
    setState(() => _checkState = _EmailCheckState.checking);
    _debounce = Timer(const Duration(milliseconds: 500), () => _checkEmail(email));
  }

  bool _looksLikeEmail(String value) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);

  Future<void> _checkEmail(String email) async {
    try {
      final client = ref.read(apiClientProvider);
      final result = await client.lookupStoreUserByEmail(widget.storeId, email);
      if (!mounted || _emailController.text.trim() != email) return;
      setState(() {
        if (result.exists) {
          _checkState = _EmailCheckState.found;
          _resolvedUserId = result.userId;
          _resolvedName = result.displayName;
          _alreadyMember = result.alreadyMember ?? false;
        } else {
          _checkState = _EmailCheckState.notFound;
        }
      });
    } catch (_) {
      if (!mounted || _emailController.text.trim() != email) return;
      setState(() => _checkState = _EmailCheckState.error);
    }
  }

  Future<void> _sendInvite() async {
    if (_checkState != _EmailCheckState.found || _resolvedUserId == null) return;
    setState(() => _isSending = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.grantStoreAccess(widget.storeId, {
        'userId': _resolvedUserId,
        'role': _selectedRole,
      });
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to your team')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not send invite. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Widget? _emailSuffixIcon() {
    switch (_checkState) {
      case _EmailCheckState.idle:
        return null;
      case _EmailCheckState.checking:
        return const Padding(
          padding: EdgeInsets.all(14),
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      case _EmailCheckState.found:
        return Icon(
          Icons.check_circle,
          color: _alreadyMember ? RadhaColors.warning : RadhaColors.success,
        );
      case _EmailCheckState.notFound:
      case _EmailCheckState.error:
        return const Icon(Icons.error_outline, color: RadhaColors.danger);
    }
  }

  String? _emailHelperText() {
    switch (_checkState) {
      case _EmailCheckState.found:
        if (_alreadyMember) return 'Already on this store — this will update their role';
        return _resolvedName != null && _resolvedName!.isNotEmpty
            ? 'Found: $_resolvedName'
            : 'Found — this person has a RADHA account';
      case _EmailCheckState.notFound:
        return 'No RADHA account with this email yet — ask them to sign up first';
      case _EmailCheckState.error:
        return 'Could not check this email. Try again.';
      case _EmailCheckState.idle:
      case _EmailCheckState.checking:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    final canSend = _checkState == _EmailCheckState.found && !_isSending;

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

          // Email field, live-verified against existing accounts.
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            onChanged: _onEmailChanged,
            decoration: InputDecoration(
              labelText: 'Email address',
              hintText: 'their.name@gmail.com',
              suffixIcon: _emailSuffixIcon(),
              helperText: _emailHelperText(),
              helperMaxLines: 2,
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
              label: _isSending ? 'Adding…' : 'Add to Team',
              onPressed: canSend ? _sendInvite : null,
            ),
          ),
        ],
      ),
    );
  }
}

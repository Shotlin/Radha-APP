import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/widgets/connectivity_banner.dart';
import '../../design/widgets/radha_bottom_navigation.dart';
import '../../features/sync/sync_status_banner.dart';
import '../../l10n/generated/app_localizations.dart';
import '../mode/app_mode_provider.dart';
import '../offline/sync_service.dart';

// Auditor gets a 3-tab shell: Expiry (branch 2), Tasks (branch 3), Profile (branch 4).
// Display indices 0/1/2 map to StatefulShellBranch indices 2/3/4.
const _kAuditorBranches = [2, 3, 4];

/// Five-tab bottom-navigation shell that hosts the primary feature surfaces:
/// Home, Scan, Expiry, Tasks, Profile. Wired up in `app_router.dart` as the
/// builder for a [StatefulShellRoute.indexedStack].
///
/// In auditor mode, the shell collapses to 3 tabs (Expiry, Tasks, Profile)
/// mapped to branch indices 2–4. Display index 0 → branch 2, etc.
class RootShell extends ConsumerWidget {
  const RootShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(syncBootstrapProvider);

    final mode = ref.watch(appModeProvider);
    final isAuditor = mode == AppMode.auditor;

    // For auditor mode, map the current branch index back to a display index.
    final branchIdx = navigationShell.currentIndex;
    final displayIndex = isAuditor
        ? _kAuditorBranches.indexOf(branchIdx).clamp(0, 2)
        : branchIdx;

    return Scaffold(
      body: Column(
        children: [
          const SyncStatusBanner(),
          Expanded(child: navigationShell),
          const ConnectivityBanner(),
        ],
      ),
      bottomNavigationBar: RadhaBottomNavigation(
        currentIndex: displayIndex,
        destinations: _destinations(context, isAuditor),
        onDestinationSelected: (displayIdx) {
          HapticFeedback.selectionClick();
          final targetBranch =
              isAuditor ? _kAuditorBranches[displayIdx] : displayIdx;
          navigationShell.goBranch(
            targetBranch,
            initialLocation: targetBranch == navigationShell.currentIndex,
          );
        },
      ),
    );
  }

  List<RadhaNavDestination> _destinations(BuildContext context, bool isAuditor) {
    final l10n = AppLocalizations.of(context);
    if (isAuditor) {
      return [
        RadhaNavDestination(
          icon: Icons.event_outlined,
          selectedIcon: Icons.event_rounded,
          label: l10n.expiry,
        ),
        RadhaNavDestination(
          icon: Icons.checklist_outlined,
          selectedIcon: Icons.checklist_rounded,
          label: l10n.tasks,
        ),
        RadhaNavDestination(
          icon: Icons.person_outline_rounded,
          selectedIcon: Icons.person_rounded,
          label: l10n.profile,
        ),
      ];
    }
    return [
      RadhaNavDestination(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: l10n.home,
      ),
      RadhaNavDestination(
        icon: Icons.qr_code_scanner_rounded,
        selectedIcon: Icons.qr_code_scanner_rounded,
        label: l10n.scan,
        emphasized: true,
      ),
      RadhaNavDestination(
        icon: Icons.event_outlined,
        selectedIcon: Icons.event_rounded,
        label: l10n.expiry,
      ),
      RadhaNavDestination(
        icon: Icons.checklist_outlined,
        selectedIcon: Icons.checklist_rounded,
        label: l10n.tasks,
      ),
      RadhaNavDestination(
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        label: l10n.profile,
      ),
    ];
  }
}

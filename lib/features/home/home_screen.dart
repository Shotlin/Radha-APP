import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:radha_app/core/auth/auth_controller.dart';
import 'package:radha_app/core/mode/app_mode_provider.dart';
import 'package:radha_app/core/network/dto/task_dto.dart';
import 'package:radha_app/core/router/app_router.dart';
import 'package:radha_app/design/app_assets.dart';
import 'package:radha_app/design/theme.dart';
import 'package:radha_app/design/tokens.dart';
import 'package:radha_app/design/widgets/branded_image.dart';
import 'package:radha_app/design/widgets/mor_companion.dart';
import 'package:radha_app/design/widgets/radha_icon_tile.dart';
import 'package:radha_app/design/widgets/skeleton_loader.dart';
import 'package:radha_app/l10n/generated/app_localizations.dart';
import 'package:radha_app/features/catalog/catalog_search_screen.dart';
import 'package:radha_app/features/catalog/featured_rail.dart';

import '../business/business_dashboard_screen.dart';
import 'data/home_catalog.dart';
import 'providers/home_summary_providers.dart';

/// Home dashboard — the anchor screen (VISUAL_SCREENS/08_home.md).
///
/// Single shell, two faces. Mode is resolved from auth roles + selected store
/// (see `appModeProvider`). Consumer mode shows the food-health engagement
/// loop; business mode shows the retail-ops command center. Same 5-tab
/// navigation, same wiring — only the content set changes.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    // Invalidate all home providers — both modes.
    ref.invalidate(nearExpiryCountProvider);
    ref.invalidate(openTasksCountProvider);
    ref.invalidate(lowStockCountProvider);
    ref.invalidate(savedProductsCountProvider);
    ref.invalidate(recallAlertsCountProvider);
    ref.invalidate(recentTasksProvider);
    ref.invalidate(homeOhsProvider);
    await Future.wait<void>([
      ref.read(nearExpiryCountProvider.future).catchError((_) => 0),
      ref.read(openTasksCountProvider.future).catchError((_) => 0),
      ref.read(lowStockCountProvider.future).catchError((_) => 0),
      ref.read(savedProductsCountProvider.future).catchError((_) => 0),
      ref.read(recallAlertsCountProvider.future).catchError((_) => 0),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appModeProvider);

    // Business mode: delegate to the full command-center dashboard (OHS score,
    // activity charts, KPI grid, quick actions, recent tasks). Embedded without
    // a standalone Scaffold so it sits inside the shell's existing bottom-nav.
    if (mode == AppMode.business) {
      return SafeArea(
        bottom: false,
        child: const BusinessDashboardScreen(),
      );
    }

    final user = ref.watch(currentUserProvider);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: RadhaColors.primary,
        onRefresh: () => _refresh(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(
            RadhaSpacing.space20,
            RadhaSpacing.space16,
            RadhaSpacing.space20,
            RadhaSpacing.space32,
          ),
          children: [
                  // ── Consumer: food health engagement loop ──────────────
                  _Stagger(index: 0, child: _HeroGreeting(user: user)),
                  const SizedBox(height: RadhaSpacing.space16),
                  _Stagger(index: 1, child: const CatalogSearchBar()),
                  const SizedBox(height: RadhaSpacing.space20),
                  _Stagger(
                    index: 2,
                    child: const _KpiRow(mode: AppMode.consumer),
                  ),
                  const SizedBox(height: RadhaSpacing.space20),
                  _Stagger(
                    index: 3,
                    child: const _StoryBanner(mode: AppMode.consumer),
                  ),
                  const SizedBox(height: RadhaSpacing.space24),
                  _Stagger(
                    index: 4,
                    child: const _QuickActionsSection(
                      mode: AppMode.consumer,
                    ),
                  ),
                  const SizedBox(height: RadhaSpacing.space24),
                  _Stagger(
                    index: 5,
                    child: const _PromoBannerCarousel(
                      mode: AppMode.consumer,
                    ),
                  ),
                  const SizedBox(height: RadhaSpacing.space24),
                  _Stagger(index: 6, child: const _CategoriesSection()),
                  const SizedBox(height: RadhaSpacing.space24),
                  _Stagger(index: 7, child: const FeaturedProductsRail()),
                  const SizedBox(height: RadhaSpacing.space24),
                  _Stagger(
                    index: 8,
                    child: const _ConsumerEngagementSection(),
                  ),
                ],
        ),
      ),
    );
  }
}

// ─── Staggered entrance wrapper ──────────────────────────────────────────────

/// Fades + rises its child in, staggered by `index`. One-shot. Uses an
/// Interval-based curve on a single controller started in `initState` (no
/// `Future.delayed`) so widget tests that pump a single frame don't trip over
/// a dangling Timer. Respects `disableAnimations`.
class _Stagger extends StatefulWidget {
  const _Stagger({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_Stagger> createState() => _StaggerState();
}

class _StaggerState extends State<_Stagger>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final Animation<double> _fade;
  late final Animation<Offset> _rise;

  @override
  void initState() {
    super.initState();
    final start = (widget.index * 0.1).clamp(0.0, 0.6);
    final curve = CurvedAnimation(
      parent: _c,
      curve: Interval(start, 1, curve: Curves.easeOut),
    );
    _fade = curve;
    _rise = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(curve);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _c.value = 1;
    } else if (!_c.isAnimating && _c.value == 0) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) return widget.child;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _rise, child: widget.child),
    );
  }
}

// ─── Hero greeting band ──────────────────────────────────────────────────────

/// The authored "human beat": a warm storefront band with a personalised
/// greeting, the store-picker chip (business), and the avatar. Renders
/// identically in both modes — mode content starts at the KPI row.
class _HeroGreeting extends StatelessWidget {
  const _HeroGreeting({required this.user});

  final CurrentUser? user;

  String _timeGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.homeGreetingMorning;
    if (hour < 17) return l10n.homeGreetingAfternoon;
    return l10n.homeGreetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final fallback = l10n.homeGreetingFallbackName;
    final rawName = user?.userId.split('-').first ?? fallback;
    final name = rawName.isEmpty ? fallback : rawName;
    final storeName = user?.selectedStoreName;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusXl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            RadhaColors.primaryTint.withValues(alpha: 0.38),
            theme.colorScheme.surface,
          ],
        ),
      ),
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      child: Stack(
        children: [
          // Storefront motif, top-right. The source illustration is a
          // landscape scene with a solid warm background, so we (a) clip it to
          // the card's rounded rect via the parent's `clipBehavior`, and
          // (b) dissolve its hard left/bottom edges with a diagonal alpha mask
          // so it melts into the band instead of reading as a pasted box.
          Positioned(
            right: -10,
            top: -10,
            child: IgnorePointer(
              child: ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Colors.white, Colors.transparent],
                  stops: [0.0, 0.50],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: Opacity(
                  opacity: 0.50,
                  child: Image.asset(
                    RadhaAssets.illoHomeStorefront,
                    height: 104,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                    cacheHeight: 312,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _timeGreeting(l10n),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: RadhaSpacing.space2),
                    Text(
                      name,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (storeName != null) ...[
                      const SizedBox(height: RadhaSpacing.space12),
                      _StorePickerChip(storeName: storeName),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: RadhaSpacing.space12),
              _AvatarTile(name: name),
            ],
          ),
        ],
      ),
    );
  }
}

class _StorePickerChip extends StatelessWidget {
  const _StorePickerChip({required this.storeName});

  final String storeName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          context.push(AppRoute.selectStore);
        },
        borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: RadhaSpacing.space12,
            vertical: RadhaSpacing.space8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.storefront_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: RadhaSpacing.space8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180),
                child: Text(
                  storeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: RadhaSpacing.space4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarTile extends StatelessWidget {
  const _AvatarTile({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'R';
    return Semantics(
      button: true,
      label: AppLocalizations.of(context).profile,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          context.push(AppRoute.profile);
        },
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            shape: BoxShape.circle,
            border: Border.all(color: theme.colorScheme.outline),
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── KPI row ─────────────────────────────────────────────────────────────────

class _KpiRow extends ConsumerWidget {
  const _KpiRow({required this.mode});

  final AppMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (mode == AppMode.consumer) {
      final saved = ref.watch(savedProductsCountProvider);
      final nearExpiry = ref.watch(nearExpiryCountProvider);
      final recalls = ref.watch(recallAlertsCountProvider);

      return Row(
        children: [
          Expanded(
            child: _KpiTile(
              value: saved,
              label: l10n.homeKpiSaved,
              icon: Icons.bookmark_border_rounded,
              tint: RadhaColors.complement,
              onTap: () => context.push(AppRoute.savedProducts),
            ),
          ),
          const SizedBox(width: RadhaSpacing.space12),
          Expanded(
            child: _KpiTile(
              value: nearExpiry,
              label: l10n.homeKpiNearExpiry,
              icon: Icons.schedule_rounded,
              tint: RadhaColors.warning,
              onTap: () => context.push(AppRoute.expiryCalendar),
            ),
          ),
          const SizedBox(width: RadhaSpacing.space12),
          Expanded(
            child: _KpiTile(
              value: recalls,
              label: l10n.homeKpiRecallAlerts,
              icon: Icons.warning_amber_rounded,
              tint: RadhaColors.primary,
              onTap: () => context.push(AppRoute.recallAlerts),
            ),
          ),
        ],
      );
    }

    // Business mode — ops KPIs.
    final nearExpiry = ref.watch(nearExpiryCountProvider);
    final openTasks = ref.watch(openTasksCountProvider);
    final lowStock = ref.watch(lowStockCountProvider);

    return Row(
      children: [
        Expanded(
          child: _KpiTile(
            value: openTasks,
            label: l10n.homeKpiOpenTasks,
            icon: Icons.checklist_rounded,
            tint: RadhaColors.primary,
            onTap: () => context.push(AppRoute.tasks),
          ),
        ),
        const SizedBox(width: RadhaSpacing.space12),
        Expanded(
          child: _KpiTile(
            value: nearExpiry,
            label: l10n.homeKpiNearExpiry,
            icon: Icons.schedule_rounded,
            tint: RadhaColors.warning,
            onTap: () => context.push(AppRoute.expiry),
          ),
        ),
        const SizedBox(width: RadhaSpacing.space12),
        Expanded(
          child: _KpiTile(
            value: lowStock,
            label: l10n.homeKpiLowStock,
            icon: Icons.inventory_2_rounded,
            tint: RadhaColors.complement,
            onTap: () => context.push(AppRoute.inventory),
          ),
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
    required this.tint,
    required this.onTap,
  });

  final AsyncValue<int> value;
  final String label;
  final IconData icon;
  final Color tint;
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
          RadhaIconTile(icon: icon, tint: tint),
          const SizedBox(height: RadhaSpacing.space12),
          _KpiValue(value: value, tint: tint),
          const SizedBox(height: RadhaSpacing.space4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero Story Banner (Mor's daily mission) ─────────────────────────────────

/// The showpiece (VISUAL_SCREENS/08_home.md Z2). Mor hands the user today's
/// real, backend-driven mission. No scan-to-earn / rewards.
///
/// Consumer mode: food-health missions (recall → near-expiry → scan CTA).
/// Business mode: ops missions (expiry → tasks → low-stock → audit CTA).
class _StoryBanner extends ConsumerWidget {
  const _StoryBanner({required this.mode});

  final AppMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    String eyebrow;
    String headline;
    String cta;
    VoidCallback onTap;
    MorMood mood;

    if (mode == AppMode.consumer) {
      // Consumer missions — priority: recall > near-expiry > scan CTA.
      final recalls = ref.watch(recallAlertsCountProvider).valueOrNull;
      final nearExpiry = ref.watch(nearExpiryCountProvider).valueOrNull;
      final loading = recalls == null && nearExpiry == null;

      if ((recalls ?? 0) > 0) {
        eyebrow = l10n.homeEyebrowFoodSafety;
        headline = l10n.homeStoryRecall(recalls!);
        cta = l10n.homeCtaViewRecallAlerts;
        onTap = () => context.push(AppRoute.recallAlerts);
        mood = MorMood.concern;
      } else if ((nearExpiry ?? 0) > 0) {
        eyebrow = l10n.homeEyebrowToday;
        headline = l10n.homeStoryNearExpiryConsumer(nearExpiry!);
        cta = l10n.homeCtaCheckExpiry;
        onTap = () => context.push(AppRoute.expiryCalendar);
        mood = MorMood.guard;
      } else if (loading) {
        eyebrow = l10n.homeEyebrowHealthScan;
        headline = l10n.homeStoryKnowWhatYouEat;
        cta = l10n.scanTitle;
        onTap = () => context.go(AppRoute.scan);
        mood = MorMood.greet;
      } else {
        eyebrow = l10n.homeEyebrowScanToLearn;
        headline = l10n.homeStoryScanInside;
        cta = l10n.scanTitle;
        onTap = () => context.go(AppRoute.scan);
        mood = MorMood.greet;
      }
    } else {
      // Business mode — ops missions.
      final nearExpiry = ref.watch(nearExpiryCountProvider).valueOrNull;
      final openTasks = ref.watch(openTasksCountProvider).valueOrNull;
      final lowStock = ref.watch(lowStockCountProvider).valueOrNull;
      final loading =
          nearExpiry == null && openTasks == null && lowStock == null;

      if ((nearExpiry ?? 0) > 0) {
        eyebrow = l10n.homeEyebrowToday;
        headline = l10n.homeStoryNearExpiryBusiness(nearExpiry!);
        cta = l10n.homeCtaOpenExpiry;
        onTap = () => context.push(AppRoute.expiry);
        mood = MorMood.guard;
      } else if ((openTasks ?? 0) > 0) {
        headline = l10n.homeStoryOpenTasks(openTasks!);
        eyebrow = l10n.homeEyebrowToday;
        cta = l10n.homeCtaViewTasks;
        onTap = () => context.push(AppRoute.tasks);
        mood = MorMood.work;
      } else if ((lowStock ?? 0) > 0) {
        eyebrow = l10n.homeEyebrowToday;
        headline = l10n.homeStoryLowStock(lowStock!);
        cta = l10n.homeCtaCheckInventory;
        onTap = () => context.push(AppRoute.inventory);
        mood = MorMood.think;
      } else if (loading) {
        eyebrow = l10n.homeEyebrowToday;
        headline = l10n.homeStoreToday;
        cta = l10n.homeCtaOpenTasks;
        onTap = () => context.push(AppRoute.tasks);
        mood = MorMood.greet;
      } else {
        eyebrow = l10n.homeEyebrowAllClear;
        headline = l10n.homeStoreAllGood;
        cta = l10n.homeCtaRunAudit;
        onTap = () => context.go(AppRoute.scan);
        mood = MorMood.celebrate;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: RadhaColors.primary,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusXl),
      ),
      padding: const EdgeInsets.all(RadhaSpacing.space20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: RadhaColors.primaryTint,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space8),
                Text(
                  headline,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: RadhaColors.onPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space16),
                _WhiteCtaPill(label: cta, onTap: onTap),
              ],
            ),
          ),
          const SizedBox(width: RadhaSpacing.space12),
          MorCompanion(mood: mood, size: 84),
        ],
      ),
    );
  }
}

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
              const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: RadhaColors.primaryDeep,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Quick actions section ───────────────────────────────────────────────────

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection({required this.mode});

  final AppMode mode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final actions = mode == AppMode.consumer
        ? <_QuickActionData>[
            _QuickActionData(
              icon: Icons.qr_code_scanner_rounded,
              label: l10n.homeQuickScan,
              accent: true,
              onTap: () {
                HapticFeedback.lightImpact();
                context.go(AppRoute.scan);
              },
            ),
            _QuickActionData(
              icon: Icons.bookmark_border_rounded,
              label: l10n.homeKpiSaved,
              onTap: () => context.push(AppRoute.savedProducts),
            ),
            _QuickActionData(
              icon: Icons.event_available_outlined,
              label: l10n.expiry,
              onTap: () => context.push(AppRoute.expiryCalendar),
            ),
            _QuickActionData(
              icon: Icons.shopping_cart_outlined,
              label: l10n.homeQuickShopping,
              onTap: () => context.push(AppRoute.shoppingList),
            ),
          ]
        : <_QuickActionData>[
            _QuickActionData(
              icon: Icons.qr_code_scanner_rounded,
              label: l10n.homeQuickScan,
              accent: true,
              onTap: () {
                HapticFeedback.lightImpact();
                context.go(AppRoute.scan);
              },
            ),
            _QuickActionData(
              icon: Icons.event_available_outlined,
              label: l10n.homeQuickAddExpiry,
              onTap: () => context.push(AppRoute.expiryNew),
            ),
            _QuickActionData(
              icon: Icons.add_task_outlined,
              label: l10n.homeQuickNewTask,
              onTap: () => context.push(AppRoute.taskCreate),
            ),
            _QuickActionData(
              icon: Icons.move_to_inbox_outlined,
              label: 'Stock in',
              onTap: () => context.push(AppRoute.grnCreate),
            ),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeQuickActions,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: RadhaSpacing.space12),
        Row(
          children: [
            for (var i = 0; i < actions.length; i++) ...[
              Expanded(
                child: _QuickAction(
                  icon: actions[i].icon,
                  label: actions[i].label,
                  accent: actions[i].accent,
                  onTap: actions[i].onTap,
                ),
              ),
              if (i < actions.length - 1)
                const SizedBox(width: RadhaSpacing.space12),
            ],
          ],
        ),
      ],
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
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

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tileColor = accent
        ? RadhaColors.primaryTint.withValues(alpha: 0.9)
        : RadhaColors.primaryTint.withValues(alpha: 0.45);
    return _PressableCard(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space8,
        vertical: RadhaSpacing.space16,
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: BorderRadius.circular(RadhaRadii.radiusSm),
              boxShadow: RadhaShadows.tile(RadhaColors.primaryDeep),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: RadhaColors.primaryDeep),
          ),
          const SizedBox(height: RadhaSpacing.space8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Consumer engagement section ─────────────────────────────────────────────

/// Replaces the tasks section in consumer mode. A prominent scan CTA card
/// that drives the core scan → health card → learn loop. No fake data.
class _ConsumerEngagementSection extends StatelessWidget {
  const _ConsumerEngagementSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeHowHelps,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: RadhaSpacing.space12),
        _PressableCard(
          onTap: () {
            HapticFeedback.lightImpact();
            context.go(AppRoute.scan);
          },
          padding: const EdgeInsets.all(RadhaSpacing.space16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: RadhaColors.primaryTint,
                  borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 28,
                  color: RadhaColors.primaryDeep,
                ),
              ),
              const SizedBox(width: RadhaSpacing.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeScanBarcodeTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: RadhaSpacing.space2),
                    Text(
                      l10n.homeScanBarcodeBody,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: RadhaSpacing.space8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: RadhaColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: RadhaSpacing.space8),
        _PressableCard(
          onTap: () => context.push(AppRoute.recallAlerts),
          padding: const EdgeInsets.all(RadhaSpacing.space16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: RadhaColors.primaryTint.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.shield_outlined,
                  size: 28,
                  color: RadhaColors.primaryDeep,
                ),
              ),
              const SizedBox(width: RadhaSpacing.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeRecallTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: RadhaSpacing.space2),
                    Text(
                      l10n.homeRecallBody,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: RadhaSpacing.space8),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Shared pressable card primitive ─────────────────────────────────────────

/// A rounded surface with a spring press-scale (0.97). Used by every tappable
/// card on the dashboard so the tactile feel is consistent. Honors
/// `disableAnimations` via `AnimatedScale`.
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
        duration: RadhaMotion.fast,
        curve: RadhaMotion.spring,
        child: AnimatedContainer(
          duration: RadhaMotion.fast,
          curve: RadhaMotion.easeOut,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
            boxShadow: RadhaShadows.card,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ─── KPI value (last-known-value resilient) ──────────────────────────────────

/// Renders a KPI count that survives backend hiccups. Once a real value has
/// loaded it stays on screen through any later refresh or error — Riverpod
/// retains the previous value across reloads, and we read it via
/// `valueOrNull`, so the tile never flickers back to a dash mid-session. The
/// skeleton shows only on the genuine first load; a dash appears only if that
/// very first fetch fails with nothing cached yet.
class _KpiValue extends StatelessWidget {
  const _KpiValue({required this.value, required this.tint});

  final AsyncValue<int> value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final lastKnown = value.valueOrNull;
    if (lastKnown != null) {
      return Text(
        '$lastKnown',
        style: radhaMonoStyle(
          fontSize: 28,
          weight: FontWeight.w700,
          color: tint,
        ),
      );
    }
    if (value.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: RadhaSpacing.space4),
        child: SkeletonLoader(width: 36, height: 24),
      );
    }
    return Text(
      '–',
      style: radhaMonoStyle(
        fontSize: 28,
        weight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

// ─── Pressable scale (chrome-less press feel) ────────────────────────────────

/// Scale-on-press wrapper for image-led surfaces (banners, category tiles) that
/// want the same tactile feel as `_PressableCard` without its card background.
class _PressableScale extends StatefulWidget {
  const _PressableScale({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _pressed = false;

  void _set(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: RadhaMotion.fast,
        curve: RadhaMotion.spring,
        child: widget.child,
      ),
    );
  }
}

// ─── Promo banner carousel ───────────────────────────────────────────────────

/// Evergreen, image-led promo banners (the owner's v3 hero art). Distinct from
/// the dynamic `_StoryBanner` above: these are brand/marketing moments, not the
/// data-driven "today" mission. Manual-swipe (no auto-advance timer — keeps the
/// widget tree free of pending timers for tests and battery-cheap at rest).
class _PromoBannerCarousel extends StatefulWidget {
  const _PromoBannerCarousel({required this.mode});

  final AppMode mode;

  @override
  State<_PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<_PromoBannerCarousel> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_PromoBanner> _banners(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (widget.mode == AppMode.consumer) {
      return [
        _PromoBanner(
          asset: RadhaAssets.bannerHealthMission,
          eyebrow: l10n.homePromoKnowFoodEyebrow,
          headline: l10n.homePromoKnowFoodHeadline,
          cta: l10n.homePromoKnowFoodCta,
          onTap: () => context.go(AppRoute.scan),
        ),
        _PromoBanner(
          asset: RadhaAssets.bannerExpiryMission,
          eyebrow: l10n.homePromoExpiryEyebrow,
          headline: l10n.homePromoExpiryHeadline,
          cta: l10n.homePromoExpiryCta,
          onTap: () => context.push(AppRoute.expiryCalendar),
        ),
        _PromoBanner(
          asset: RadhaAssets.bannerFestive,
          eyebrow: l10n.homePromoFestiveEyebrow,
          headline: l10n.homePromoFestiveHeadline,
          cta: l10n.homePromoFestiveCta,
          onTap: () => context.push(AppRoute.catalogSearch),
        ),
      ];
    }
    return [
      _PromoBanner(
        asset: RadhaAssets.bannerHomeMission,
        eyebrow: l10n.homePromoBazaarEyebrow,
        headline: l10n.homePromoBazaarHeadline,
        cta: l10n.homePromoBazaarCta,
        onTap: () => context.go(AppRoute.scan),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final banners = _banners(context);
    final width = MediaQuery.sizeOf(context).width - RadhaSpacing.space20 * 2;
    final height = width * 9 / 16;
    final cacheW = (width * MediaQuery.devicePixelRatioOf(context)).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          child: PageView.builder(
            controller: _controller,
            itemCount: banners.length,
            physics: banners.length > 1
                ? const BouncingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) => RepaintBoundary(
              child: _PromoBannerCard(banner: banners[i], cacheWidth: cacheW),
            ),
          ),
        ),
        if (banners.length > 1) ...[
          const SizedBox(height: RadhaSpacing.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < banners.length; i++) _Dot(active: i == _page),
            ],
          ),
        ],
      ],
    );
  }
}

class _PromoBanner {
  const _PromoBanner({
    required this.asset,
    required this.eyebrow,
    required this.headline,
    required this.cta,
    required this.onTap,
  });

  final String asset;
  final String eyebrow;
  final String headline;
  final String cta;
  final VoidCallback onTap;
}

class _PromoBannerCard extends StatelessWidget {
  const _PromoBannerCard({required this.banner, required this.cacheWidth});

  final _PromoBanner banner;
  final int cacheWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        banner.onTap();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusXl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Editorial art, downscaled at decode. Degrades to a calm branded
            // tile (never a red error box) if the asset is ever missing.
            BrandedImage(
              asset: banner.asset,
              cacheWidth: cacheWidth,
              fallbackIcon: Icons.photo_size_select_actual_outlined,
            ),
            // Bottom-up ink scrim so overlaid copy stays legible on any frame.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    RadhaColors.ink.withValues(alpha: 0.82),
                    RadhaColors.ink.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.72],
                ),
              ),
            ),
            Positioned(
              left: RadhaSpacing.space16,
              right: RadhaSpacing.space16,
              bottom: RadhaSpacing.space16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banner.eyebrow,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: RadhaColors.primaryTint,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: RadhaSpacing.space4),
                  Text(
                    banner.headline,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: RadhaColors.onPrimary,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: RadhaSpacing.space12),
                  _BannerCtaPill(label: banner.cta),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Non-interactive CTA pill — the whole banner is the tap target, so this is
/// purely a visual affordance (avoids nested gesture arenas).
class _BannerCtaPill extends StatelessWidget {
  const _BannerCtaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space16,
        vertical: RadhaSpacing.space8,
      ),
      decoration: BoxDecoration(
        color: RadhaColors.onPrimary,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
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
          const Icon(
            Icons.arrow_forward_rounded,
            size: 16,
            color: RadhaColors.primaryDeep,
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: RadhaMotion.medium,
      curve: RadhaMotion.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: active ? 18 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active
            ? RadhaColors.primary
            : RadhaColors.primary.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
      ),
    );
  }
}

// ─── Shop by category ────────────────────────────────────────────────────────

/// Image-led category rail. Backed by static bundled cutouts (`kRadhaCategories`),
/// so it paints on the first frame with zero network dependency. Tapping a tile
/// opens a quick-view sheet (scan CTA today; product browse lands with the
/// catalog endpoint).
class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeShopByCategory,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: RadhaSpacing.space4),
        Text(
          l10n.homeShopByCategorySubtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: RadhaSpacing.space16),
        SizedBox(
          height: 112,
          child: RepaintBoundary(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              padding: EdgeInsets.zero,
              itemCount: kRadhaCategories.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: RadhaSpacing.space12),
              itemBuilder: (context, i) =>
                  _CategoryTile(category: kRadhaCategories[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final RadhaCategory category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cacheW = (64 * MediaQuery.devicePixelRatioOf(context)).round();
    return _PressableScale(
      onTap: () {
        HapticFeedback.selectionClick();
        context.push('/catalog/${category.id}');
      },
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: BrandedImage(
                asset: category.asset,
                cacheWidth: cacheW,
                label: categoryLabel(AppLocalizations.of(context), category.id),
                fallbackIcon: Icons.category_outlined,
              ),
            ),
            const SizedBox(height: RadhaSpacing.space8),
            Text(
              categoryLabel(AppLocalizations.of(context), category.id),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// (Category tap now navigates to the full ProductBrowseScreen via
// `/catalog/:category` — the earlier quick-view bottom sheet was removed.)


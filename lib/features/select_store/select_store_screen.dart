// Real `/select-store` screen.
//
// After OTP verification the auth session carries a `List<StoreAccess>` but
// no `selectedStoreId`. The router parks the user here until they pick one.
// On tap we call `authController.selectStore(storeId)`; the auth state flips,
// `refreshListenable` fires, and the global redirect handler in `app_router`
// pushes the user to `/home`.
//
// Design rules (from tokens.dart):
//   * One orange accent (#EA580C) for the selected indicator.
//   * No emoji, no gradient, no centered hero.
//   * 44pt+ touch targets, tactile press-scale, staggered entrance, and
//     reduce-motion awareness.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/auth/auth_session.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/error_codes.dart';
import '../../core/router/app_router.dart';
import '../../design/app_assets.dart';
import '../../design/tokens.dart';
import '../../design/widgets/empty_state.dart';
import '../../design/widgets/mor_companion.dart';
import '../../l10n/generated/app_localizations.dart';

/// Drives the "select store" route. Reads the user's accessible stores from
/// `currentUserProvider` (via the underlying auth session), renders them as
/// rows, and persists the choice on tap.
class SelectStoreScreen extends ConsumerStatefulWidget {
  const SelectStoreScreen({super.key});

  @override
  ConsumerState<SelectStoreScreen> createState() => _SelectStoreScreenState();
}

class _SelectStoreScreenState extends ConsumerState<SelectStoreScreen> {
  /// `storeId` currently being persisted. While non-null, the row is shown
  /// in a "selecting" state and the rest of the list is disabled to prevent
  /// double-taps producing a race.
  String? _selectingId;

  /// Locally pinned error message after a `selectStore` call fails. The auth
  /// controller swallows the error into its `AsyncValue` so we mirror that
  /// here for inline display.
  String? _errorText;

  Future<void> _onPick(StoreAccess store) async {
    if (_selectingId != null) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectingId = store.storeId;
      _errorText = null;
    });

    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);

    try {
      await ref
          .read(authControllerProvider.notifier)
          .selectStore(store.storeId);
      // The auth state change ripples through `refreshListenable` and the
      // router redirects to /home automatically. We still call go() as a
      // belt-and-braces fallback so navigation feels immediate even if the
      // refresh listener is microtask-delayed in tests.
      if (!mounted) return;
      context.go(AppRoute.home);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = userMessageForCode(
          e.code,
          l10n: l10n,
          fallback: e.message,
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorText = userMessageForCode(null, l10n: l10n);
      });
    } finally {
      if (mounted) {
        setState(() => _selectingId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).valueOrNull;
    final stores = session?.stores ?? const <StoreAccess>[];
    final selectedStoreId = session?.selectedStoreId;
    final theme = Theme.of(context);
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select store',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: stores.isEmpty
            ? const _EmptyStores()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StaggerIn(
                    index: 0,
                    reduceMotion: reduceMotion,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        RadhaSpacing.space24,
                        RadhaSpacing.space24,
                        RadhaSpacing.space24,
                        RadhaSpacing.space8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose a store',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: RadhaSpacing.space4),
                          Text(
                            'Pick where you’re working today. You can switch '
                            'stores later from your profile.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_errorText != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: RadhaSpacing.space24,
                        vertical: RadhaSpacing.space8,
                      ),
                      child: Text(
                        _errorText!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        RadhaSpacing.space16,
                        RadhaSpacing.space16,
                        RadhaSpacing.space16,
                        RadhaSpacing.space24,
                      ),
                      itemCount: stores.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: RadhaSpacing.space8),
                      itemBuilder: (context, index) {
                        final store = stores[index];
                        return _StaggerIn(
                          index: index + 1,
                          reduceMotion: reduceMotion,
                          child: _StoreRow(
                            store: store,
                            isSelected: store.storeId == selectedStoreId,
                            isLoading: _selectingId == store.storeId,
                            isLocked: _selectingId != null,
                            reduceMotion: reduceMotion,
                            onTap: () => _onPick(store),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Single tappable row inside the store list. Renders the store name, a
/// role badge, and a leading check mark when the row matches the currently
/// selected store. Adds a tactile press-scale.
class _StoreRow extends StatefulWidget {
  const _StoreRow({
    required this.store,
    required this.isSelected,
    required this.isLoading,
    required this.isLocked,
    required this.reduceMotion,
    required this.onTap,
  });

  final StoreAccess store;
  final bool isSelected;
  final bool isLoading;
  final bool isLocked;
  final bool reduceMotion;
  final VoidCallback onTap;

  @override
  State<_StoreRow> createState() => _StoreRowState();
}

class _StoreRowState extends State<_StoreRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = widget.isSelected ? scheme.primary : scheme.outline;

    final disabled = widget.isLocked && !widget.isLoading;
    final scale = _pressed && !widget.reduceMotion ? 0.98 : 1.0;

    return AnimatedScale(
      scale: scale,
      duration: RadhaMotion.fast,
      curve: RadhaMotion.easeOut,
      child: AnimatedContainer(
        duration: RadhaMotion.fast,
        curve: RadhaMotion.easeOut,
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
          border: Border.all(color: accent, width: widget.isSelected ? 2 : 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: disabled ? null : widget.onTap,
            onHighlightChanged: disabled
                ? null
                : (v) => setState(() => _pressed = v),
            borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
            child: Padding(
              padding: const EdgeInsets.all(RadhaSpacing.space16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? scheme.primary.withValues(alpha: 0.12)
                          : scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(
                        RadhaRadii.radiusFull,
                      ),
                    ),
                    child: Icon(
                      Icons.storefront_outlined,
                      size: 20,
                      color: widget.isSelected
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: RadhaSpacing.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.store.storeName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: scheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: RadhaSpacing.space4),
                        _RoleBadge(role: widget.store.role),
                      ],
                    ),
                  ),
                  const SizedBox(width: RadhaSpacing.space12),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: widget.isLoading
                        ? CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              scheme.primary,
                            ),
                          )
                        : Icon(
                            widget.isSelected
                                ? Icons.check_circle
                                : Icons.chevron_right_rounded,
                            size: 20,
                            color: widget.isSelected
                                ? scheme.primary
                                : scheme.onSurfaceVariant,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pill rendering the user's role at a given store. Roles are server-defined
/// (`manager`, `staff`, `auditor`, etc.) so we render the raw value title-cased
/// rather than enumerating, but anything we don't recognise still gets the
/// neutral muted styling.
class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final label = role.isEmpty
        ? 'Member'
        : role[0].toUpperCase() + role.substring(1);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
        border: Border.all(color: scheme.outline),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: scheme.onSurfaceVariant,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// Shown when the user has no `StoreAccess` rows. They can't proceed without
/// a manager granting access, so we surface that as the only available path.
class _EmptyStores extends StatelessWidget {
  const _EmptyStores();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space16,
        vertical: RadhaSpacing.space24,
      ),
      child: EmptyState(
        illustration: const MorCompanion(mood: MorMood.concern, size: 104),
        title: AppLocalizations.of(context).selectStoreEmpty,
        body: AppLocalizations.of(context).selectStoreEmptyDetail,
        actionLabel: AppLocalizations.of(context).selectStoreContactManager,
        actionIcon: Icons.support_agent_outlined,
        onAction: () {
          // The empty state has no destination route in V1 — surface a
          // small toast so taps feel responsive without lying about
          // navigating somewhere.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).selectStoreEmptyBody,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Staggered fade + rise used for the header and each store row. Honours the
/// platform reduce-motion flag by rendering the child immediately.
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
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _c, curve: RadhaMotion.easeOut));

  @override
  void initState() {
    super.initState();
    if (widget.reduceMotion) {
      _c.value = 1;
    } else {
      final delay = (60 * widget.index).clamp(0, 360);
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

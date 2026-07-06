// Allergen profile management screen (Task 17 / BE-37).
//
// Lets the signed-in user record the allergens they react to. The chosen tags
// are stored on the backend via PUT /allergens/profile/{userId} and feed the
// product-detail allergen check (`product_detail_screen.dart`) so matches
// against the user's profile are surfaced visually with a warning.
//
// Design rules:
//   * Single orange accent (#EA580C). Selected chips show an orange ring on a
//     6%-alpha orange background with a tactile press-scale + checkmark.
//   * 44pt+ touch targets; chips use 16px horizontal / 8px vertical padding.
//   * No emoji, no rainbow. Plus Jakarta Sans via theme.
//   * The list of allergens is the BE-37 canonical vocabulary.
//   * Staggered entrance + reduce-motion awareness, matching the rest of the
//     app's screen polish.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/network/api_client.dart';
import '../../core/network/dto/allergen_profile_dto.dart';
import '../../design/tokens.dart';
import '../../design/widgets/error_state.dart';
import '../../design/widgets/primary_button.dart';
import '../../l10n/generated/app_localizations.dart';

/// Canonical allergen vocabulary mirrored from `ALLERGEN_TAGS` in
/// `server/src/modules/allergen/types/allergen.types.ts`. Keep this list in
/// sync if BE-37 evolves its vocabulary.
const List<AllergenOption> kAllergenOptions = [
  AllergenOption(tag: 'peanut', label: 'Peanut'),
  AllergenOption(tag: 'tree_nut', label: 'Tree nut'),
  AllergenOption(tag: 'dairy', label: 'Dairy'),
  AllergenOption(tag: 'eggs', label: 'Eggs'),
  AllergenOption(tag: 'soy', label: 'Soy'),
  AllergenOption(tag: 'wheat', label: 'Wheat'),
  AllergenOption(tag: 'fish', label: 'Fish'),
  AllergenOption(tag: 'shellfish', label: 'Shellfish'),
  AllergenOption(tag: 'sesame', label: 'Sesame'),
  AllergenOption(tag: 'gluten', label: 'Gluten'),
  AllergenOption(tag: 'mustard', label: 'Mustard'),
  AllergenOption(tag: 'celery', label: 'Celery'),
  AllergenOption(tag: 'lupin', label: 'Lupin'),
  AllergenOption(tag: 'molluscs', label: 'Molluscs'),
  AllergenOption(tag: 'sulphites', label: 'Sulphites'),
];

/// Localized display label for a canonical allergen tag. Falls back to the
/// option's English label (or the raw tag) for any unmapped value so the chip
/// never renders blank if BE-37 adds a tag ahead of the translations.
String allergenLabel(AppLocalizations l10n, AllergenOption option) {
  switch (option.tag) {
    case 'peanut':
      return l10n.allergenPeanut;
    case 'tree_nut':
      return l10n.allergenTreeNut;
    case 'dairy':
      return l10n.allergenDairy;
    case 'eggs':
      return l10n.allergenEggs;
    case 'soy':
      return l10n.allergenSoy;
    case 'wheat':
      return l10n.allergenWheat;
    case 'fish':
      return l10n.allergenFish;
    case 'shellfish':
      return l10n.allergenShellfish;
    case 'sesame':
      return l10n.allergenSesame;
    case 'gluten':
      return l10n.allergenGluten;
    case 'mustard':
      return l10n.allergenMustard;
    case 'celery':
      return l10n.allergenCelery;
    case 'lupin':
      return l10n.allergenLupin;
    case 'molluscs':
      return l10n.allergenMolluscs;
    case 'sulphites':
      return l10n.allergenSulphites;
    default:
      return option.label;
  }
}

/// Family-level provider for the user's allergen profile. Other features
/// (notably the product detail allergen check) read this to compare a
/// product's allergen list against the user's own.
final allergenProfileProvider =
    FutureProvider.family<AllergenProfileResponse, String>((ref, userId) async {
      final client = ref.watch(apiClientProvider);
      return client.getAllergenProfile(userId);
    });

class AllergenProfileScreen extends ConsumerStatefulWidget {
  const AllergenProfileScreen({super.key});

  @override
  ConsumerState<AllergenProfileScreen> createState() =>
      _AllergenProfileScreenState();
}

class _AllergenProfileScreenState extends ConsumerState<AllergenProfileScreen> {
  /// Tags the user has currently toggled on. Mirrors the chips' selected
  /// state — flushed to the backend on Save.
  final Set<String> _selected = <String>{};

  /// `true` while the initial profile load is in flight or the save is
  /// being submitted. Drives the inline progress indicator on the Save
  /// button.
  bool _saving = false;

  /// Snapshot of whether we've finished hydrating from the backend yet —
  /// used to gate the "Save" CTA and avoid wiping a profile we never read.
  bool _hydrated = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final profileAsync = ref.watch(allergenProfileProvider(user.userId));

    return profileAsync.when(
      loading: () => Scaffold(
        appBar: _appBar(context),
        body: const _AllergenSkeleton(),
      ),
      error: (error, _) => Scaffold(
        appBar: _appBar(context),
        body: ErrorState(
          title: AppLocalizations.of(context).allergenLoadError,
          onRetry: () => ref.invalidate(allergenProfileProvider(user.userId)),
        ),
      ),
      data: (profile) {
        if (!_hydrated) {
          _selected
            ..clear()
            ..addAll(profile.allergens);
          _hydrated = true;
        }
        return _buildScaffold(context, user.userId);
      },
    );
  }

  AppBar _appBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: Text(
        AppLocalizations.of(context).allergenTitle,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Scaffold _buildScaffold(BuildContext context, String userId) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Scaffold(
      appBar: _appBar(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  RadhaSpacing.space16,
                  RadhaSpacing.space24,
                  RadhaSpacing.space16,
                  RadhaSpacing.space16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StaggerIn(
                      index: 0,
                      reduceMotion: reduceMotion,
                      child: Text(
                        l10n.allergenHeading,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: RadhaSpacing.space8),
                    _StaggerIn(
                      index: 1,
                      reduceMotion: reduceMotion,
                      child: Text(
                        l10n.allergenIntro,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: RadhaSpacing.space16),
                    _StaggerIn(
                      index: 2,
                      reduceMotion: reduceMotion,
                      child: _SelectionSummary(count: _selected.length),
                    ),
                    const SizedBox(height: RadhaSpacing.space24),
                    _StaggerIn(
                      index: 3,
                      reduceMotion: reduceMotion,
                      child: Wrap(
                        spacing: RadhaSpacing.space8,
                        runSpacing: RadhaSpacing.space8,
                        children: [
                          for (final option in kAllergenOptions)
                            _AllergenChip(
                              option: option,
                              selected: _selected.contains(option.tag),
                              reduceMotion: reduceMotion,
                              onTap: () => _toggle(option.tag),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _SaveBar(
              enabled: _hydrated && !_saving,
              saving: _saving,
              onPressed: () => _onSave(userId),
            ),
          ],
        ),
      ),
    );
  }

  void _toggle(String tag) {
    HapticFeedback.selectionClick();
    setState(() {
      if (!_selected.add(tag)) _selected.remove(tag);
    });
  }

  Future<void> _onSave(String userId) async {
    HapticFeedback.lightImpact();
    setState(() => _saving = true);
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.updateAllergenProfile(
        userId,
        UpdateAllergenProfileDto(allergens: _selected.toList()),
      );

      // Re-seed the family provider so other features pick up the change
      // without a refetch. We mirror the server response rather than the
      // local optimistic copy in case the backend canonicalised tags.
      ref.invalidate(allergenProfileProvider(userId));

      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.allergens.isEmpty
                ? l10n.allergenSavedCleared
                : l10n.allergenSaved,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).allergenSaveError)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class AllergenOption {
  const AllergenOption({required this.tag, required this.label});
  final String tag;
  final String label;
}

/// Small banner reflecting how many allergens are currently selected. Sits
/// between the intro copy and the chip cloud so the screen reads as a live,
/// stateful form rather than a static list.
class _SelectionSummary extends StatelessWidget {
  const _SelectionSummary({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final active = count > 0;

    return AnimatedContainer(
      duration: RadhaMotion.medium,
      curve: RadhaMotion.easeOut,
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space16,
        vertical: RadhaSpacing.space12,
      ),
      decoration: BoxDecoration(
        color: active
            ? scheme.primary.withValues(alpha: 0.06)
            : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        border: Border.all(
          color: active ? scheme.primary.withValues(alpha: 0.4) : scheme.outline,
        ),
      ),
      child: Row(
        children: [
          Icon(
            active ? Icons.shield_outlined : Icons.shield_moon_outlined,
            size: 20,
            color: active ? scheme.primary : scheme.onSurfaceVariant,
          ),
          const SizedBox(width: RadhaSpacing.space12),
          Expanded(
            child: Text(
              active
                  ? l10n.allergenTracked(count)
                  : l10n.allergenNoneTracked,
              style: theme.textTheme.titleSmall?.copyWith(
                color: active ? scheme.primary : scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Single multi-select chip honouring the design rules: rounded-full, orange
/// border + 6%-alpha orange fill when selected, neutral hairline + surface
/// container fill when unselected. Adds a tactile press-scale, an animated
/// checkmark, and colour cross-fade. Touch target stays >= 44pt.
class _AllergenChip extends StatefulWidget {
  const _AllergenChip({
    required this.option,
    required this.selected,
    required this.reduceMotion,
    required this.onTap,
  });

  final AllergenOption option;
  final bool selected;
  final bool reduceMotion;
  final VoidCallback onTap;

  @override
  State<_AllergenChip> createState() => _AllergenChipState();
}

class _AllergenChipState extends State<_AllergenChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final selected = widget.selected;
    final label = allergenLabel(l10n, widget.option);

    final background = selected
        ? scheme.primary.withValues(alpha: 0.06)
        : scheme.surfaceContainer;
    final borderColor = selected ? scheme.primary : scheme.outline;
    final borderWidth = selected ? 1.5 : 1.0;
    final foreground = selected ? scheme.primary : scheme.onSurface;

    final scale = _pressed && !widget.reduceMotion ? 0.95 : 1.0;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: AnimatedScale(
        scale: scale,
        duration: RadhaMotion.fast,
        curve: RadhaMotion.easeOut,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: kMinTouchTarget),
          child: AnimatedContainer(
            duration: RadhaMotion.fast,
            curve: RadhaMotion.easeOut,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onHighlightChanged: (v) => setState(() => _pressed = v),
                borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: RadhaSpacing.space16,
                    vertical: RadhaSpacing.space8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSize(
                        duration: RadhaMotion.fast,
                        curve: RadhaMotion.easeOut,
                        child: selected
                            ? Padding(
                                padding: const EdgeInsets.only(
                                  right: RadhaSpacing.space8,
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: scheme.primary,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      Text(
                        label,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: foreground,
                        ),
                      ),
                    ],
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

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.enabled,
    required this.saving,
    required this.onPressed,
  });

  final bool enabled;
  final bool saving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        RadhaSpacing.space16,
        RadhaSpacing.space12,
        RadhaSpacing.space16,
        RadhaSpacing.space16,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outline)),
      ),
      child: PrimaryButton(
        label: AppLocalizations.of(context).save,
        expand: true,
        loading: saving,
        onPressed: enabled ? onPressed : null,
      ),
    );
  }
}

/// Lightweight skeleton shown while the profile hydrates. Mirrors the final
/// layout (header + chip cloud) so the load feels like the page filling in
/// rather than a spinner-then-jump.
class _AllergenSkeleton extends StatelessWidget {
  const _AllergenSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget bar(double w, double h) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusSm),
      ),
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          RadhaSpacing.space16,
          RadhaSpacing.space24,
          RadhaSpacing.space16,
          RadhaSpacing.space16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bar(180, 28),
            const SizedBox(height: RadhaSpacing.space12),
            bar(double.infinity, 16),
            const SizedBox(height: RadhaSpacing.space8),
            bar(220, 16),
            const SizedBox(height: RadhaSpacing.space24),
            Wrap(
              spacing: RadhaSpacing.space8,
              runSpacing: RadhaSpacing.space8,
              children: [
                for (final w in const [84.0, 96.0, 72.0, 110.0, 64.0, 88.0, 100.0, 78.0])
                  Container(
                    width: w,
                    height: 40,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Staggered fade + rise used for the screen's primary blocks. Honours the
/// platform reduce-motion flag by skipping the animation entirely.
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
  // Stagger baked into an Interval on a single controller started in
  // initState — never `Future.delayed` (steering §2.5/§12: delayed timers are
  // timer-leaky under widget tests).
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    final start = ((60 * widget.index).clamp(0, 400)) / 800;
    final curve = CurvedAnimation(
      parent: _c,
      curve: Interval(start, 1, curve: RadhaMotion.easeOut),
    );
    _opacity = curve;
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(curve);
    if (widget.reduceMotion) {
      _c.value = 1;
    } else {
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
    if (widget.reduceMotion) return widget.child;
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}

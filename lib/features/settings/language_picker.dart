// Language picker (Task 19 — consumes BE-42).
//
// Lists the six supported languages in their native scripts. Selecting one
// flips the in-memory locale via `LocaleController` (so the UI rebuilds
// immediately) and fires `PUT /api/v1/user/language` to persist server-side.
//
// Two surfaces are exposed:
//   * `LanguagePickerScreen` — full-page route used at `/settings/language`.
//   * `showLanguagePickerSheet(context)` — modal bottom sheet wrapper, used
//     from the Profile tab "Language" row.
//
// Design rules (from tokens.dart):
//   * One orange accent (#EA580C) — selected row carries an orange ring,
//     6%-alpha orange fill, and an animated check.
//   * Native script rendered at title size; English gloss as muted subtitle.
//   * 44pt+ touch targets, haptics on select, reduce-motion awareness.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/locale_controller.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dto/misc_dto.dart';
import '../../design/tokens.dart';
import '../../l10n/generated/app_localizations.dart';

/// Display metadata for a single language option. Native names use the
/// language's own script so the picker reads correctly even when the user
/// hasn't yet selected the matching locale.
class _LanguageOption {
  const _LanguageOption({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.glyph,
  });

  final String code;
  final String nativeName;
  final String englishName;

  /// Short script glyph rendered in the leading circle. Uses the language's
  /// own first letter so the row reads as a native cue, not an emoji flag.
  final String glyph;
}

/// The six options. Order is fixed: English first, then Indian languages by
/// approximate speaker base. Native scripts are spelled per official usage.
const List<_LanguageOption> _kLanguageOptions = <_LanguageOption>[
  _LanguageOption(
    code: 'en',
    nativeName: 'English',
    englishName: 'English',
    glyph: 'A',
  ),
  _LanguageOption(
    code: 'hi',
    nativeName: 'हिंदी',
    englishName: 'Hindi',
    glyph: 'अ',
  ),
  _LanguageOption(
    code: 'bn',
    nativeName: 'বাংলা',
    englishName: 'Bengali',
    glyph: 'অ',
  ),
  _LanguageOption(
    code: 'mr',
    nativeName: 'मराठी',
    englishName: 'Marathi',
    glyph: 'म',
  ),
  _LanguageOption(
    code: 'ta',
    nativeName: 'தமிழ்',
    englishName: 'Tamil',
    glyph: 'அ',
  ),
  _LanguageOption(
    code: 'te',
    nativeName: 'తెలుగు',
    englishName: 'Telugu',
    glyph: 'అ',
  ),
];

/// Full-page language picker route. Use with go_router under
/// `/settings/language`.
class LanguagePickerScreen extends ConsumerWidget {
  const LanguagePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Language',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(RadhaSpacing.space16),
          itemCount: _kLanguageOptions.length,
          separatorBuilder: (_, _) =>
              const SizedBox(height: RadhaSpacing.space8),
          itemBuilder: (context, index) => _StaggerIn(
            index: index,
            reduceMotion: reduceMotion,
            child: _LanguageRow(option: _kLanguageOptions[index]),
          ),
        ),
      ),
    );
  }
}

/// Shows the language picker as a modal bottom sheet. Returns when the user
/// dismisses the sheet (no value — the new locale is observable via
/// `localeControllerProvider`).
Future<void> showLanguagePickerSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          RadhaSpacing.space16,
          0,
          RadhaSpacing.space16,
          RadhaSpacing.space16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                0,
                RadhaSpacing.space8,
                0,
                RadhaSpacing.space12,
              ),
              child: Text(
                'Choose language',
                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            for (final option in _kLanguageOptions) ...[
              _LanguageRow(option: option),
              const SizedBox(height: RadhaSpacing.space8),
            ],
          ],
        ),
      ),
    ),
  );
}

class _LanguageRow extends ConsumerStatefulWidget {
  const _LanguageRow({required this.option});

  final _LanguageOption option;

  @override
  ConsumerState<_LanguageRow> createState() => _LanguageRowState();
}

class _LanguageRowState extends ConsumerState<_LanguageRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final option = widget.option;
    final currentLocale = ref.watch(localeControllerProvider);
    final isSelected = currentLocale.languageCode == option.code;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final scale = _pressed && !reduceMotion ? 0.98 : 1.0;

    return AnimatedScale(
      scale: scale,
      duration: RadhaMotion.fast,
      curve: RadhaMotion.easeOut,
      child: AnimatedContainer(
        duration: RadhaMotion.fast,
        curve: RadhaMotion.easeOut,
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primary.withValues(alpha: 0.06)
              : scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
          border: Border.all(
            color: isSelected ? scheme.primary : scheme.outline,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _select(context, ref),
            onHighlightChanged: (v) => setState(() => _pressed = v),
            borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: kMinTouchTarget),
              child: Padding(
                padding: const EdgeInsets.all(RadhaSpacing.space12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? scheme.primary.withValues(alpha: 0.12)
                            : scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(
                          RadhaRadii.radiusFull,
                        ),
                      ),
                      child: Text(
                        option.glyph,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isSelected
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: RadhaSpacing.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            option.nativeName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: scheme.onSurface,
                            ),
                          ),
                          if (option.code != 'en') ...[
                            const SizedBox(height: 2),
                            Text(
                              option.englishName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: RadhaMotion.fast,
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: isSelected
                          ? Icon(
                              Icons.check_circle_rounded,
                              key: const ValueKey('sel'),
                              color: scheme.primary,
                            )
                          : const SizedBox(
                              key: ValueKey('unsel'),
                              width: 24,
                              height: 24,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _select(BuildContext context, WidgetRef ref) async {
    HapticFeedback.selectionClick();
    // Flip the in-memory locale first so the UI rebuilds without waiting
    // on the network round-trip.
    await ref
        .read(localeControllerProvider.notifier)
        .setLocaleByCode(widget.option.code);

    // Persist server-side. Failure is non-fatal — the user's local choice
    // is already applied; we only surface a snackbar so they know the
    // server didn't get the update.
    try {
      final api = ref.read(apiClientProvider);
      await api.updateUserLanguage(
        UpdateLanguageDto(language: widget.option.code),
      );
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).languageSavedLocallyError(e.message),
          ),
        ),
      );
      return;
    } catch (_) {
      // Network/unknown — same swallow-with-toast story.
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).languageSavedLocally),
        ),
      );
      return;
    }

    if (!context.mounted) return;
    // Close the sheet (if open). For the full-page route this is a no-op
    // because there's nothing to pop — `canPop` guards us.
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}

/// Staggered fade + rise used for each language row in the full-page route.
/// Honours the platform reduce-motion flag by rendering immediately.
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
      Future<void>.delayed(
        Duration(milliseconds: 50 * widget.index),
        () {
          if (mounted) _c.forward();
        },
      );
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

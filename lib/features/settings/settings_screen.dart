// Settings hub (FE-32 / FE-33).
//
// Replaces the placeholder previously wired at `/settings`. Sections:
//   1. Notifications — push, recall alerts, weekly digest toggles. Persists
//      to flutter_secure_storage via [notificationPrefsProvider]. FCM
//      subscription wiring lands in a later task.
//   2. Appearance — theme (system/light/dark), language (-> /settings/language),
//      text size (small/standard/large). Theme + text-scale flip the live
//      app via [themeModeProvider] / [textScaleProvider] which `main.dart`
//      reads.
//   3. Data & privacy — allergen profile, sign-out from all devices, delete
//      account. Sign-out-all falls back to the regular `logout()` since the
//      `logoutAllDevices()` endpoint isn't wired today (open question).
//      Delete-account surfaces a "Contact support" path because the
//      `DELETE /auth/account` endpoint isn't on `ApiClient` either.
//   4. About — terms, privacy policy (external HTTPS via url_launcher),
//      app version (read-only), and a Support entry (-> /support).
//
// Visual rules:
//   * One orange accent (#EA580C). Destructive rows use `colorScheme.error`.
//   * 56pt+ rows, 24px outer padding, no centered hero.
//   * Plus Jakarta Sans inherited from the global theme; no inline fonts.
//   * Mirrors the visual treatment Agent D shipped on saved-products
//     (sectioned ListView, hairline-bordered cards on grouped controls).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/router/app_router.dart';
import '../../design/tokens.dart';
import '../../design/widgets/settings_row.dart';
import '../../l10n/generated/app_localizations.dart';
import 'settings_preferences.dart';

/// Cached `PackageInfo` provider — used to render the version row.
/// Identical pattern to the profile screen; reading both providers is a
/// no-op at runtime since the underlying `PackageInfo` is cached after the
/// first resolve.
final _settingsPackageInfoProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});

/// External URLs the About section deep-links into. Centralised so a future
/// rebrand only edits this one spot.
const String _termsUrl = 'https://radha.app/terms';
const String _privacyUrl = 'https://radha.app/privacy';

/// Settings hub. Replaces the placeholder previously wired at `/settings`.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifPrefs = ref.watch(notificationPrefsProvider);
    final themeMode = ref.watch(themeModeProvider);
    final textScale = ref.watch(textScaleProvider);
    final user = ref.watch(currentUserProvider);
    final packageInfoAsync = ref.watch(_settingsPackageInfoProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settingsTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            vertical: RadhaSpacing.space16,
          ),
          children: [
            // ─── Notifications ─────────────────────────────────────────
            SettingsSectionLabel(label: l10n.settingsNotifications),
            _ToggleRow(
              icon: Icons.notifications_outlined,
              label: l10n.settingsPushNotifications,
              subtitle: l10n.settingsPushNotificationsHint,
              value: notifPrefs.pushEnabled,
              onChanged: (v) => ref
                  .read(notificationPrefsProvider.notifier)
                  .setPushEnabled(v),
            ),
            _ToggleRow(
              icon: Icons.warning_amber_outlined,
              label: l10n.settingsRecallAlerts,
              subtitle: l10n.settingsRecallAlertsHint,
              value: notifPrefs.recallAlerts,
              onChanged: (v) => ref
                  .read(notificationPrefsProvider.notifier)
                  .setRecallAlerts(v),
            ),
            _ToggleRow(
              icon: Icons.calendar_view_week_outlined,
              label: l10n.settingsWeeklyDigest,
              subtitle: l10n.settingsWeeklyDigestHint,
              value: notifPrefs.weeklyDigest,
              onChanged: (v) => ref
                  .read(notificationPrefsProvider.notifier)
                  .setWeeklyDigest(v),
            ),

            const SizedBox(height: RadhaSpacing.space24),

            // ─── Appearance ─────────────────────────────────────────────
            SettingsSectionLabel(label: l10n.settingsAppearance),
            // [DISABLED] Theme picker hidden — app is locked to light mode.
            // Restore by uncommenting the block below.
            // _ThemePickerRow(
            //   themeMode: themeMode,
            //   onChanged: (mode) =>
            //       ref.read(themeModeProvider.notifier).setThemeMode(mode),
            // ),
            SettingsRow(
              icon: Icons.language_outlined,
              label: l10n.settingsLanguage,
              onTap: () => context.push(AppRoute.settingsLanguage),
            ),
            _TextSizePickerRow(
              scale: textScale,
              onChanged: (s) =>
                  ref.read(textScaleProvider.notifier).setTextScale(s),
            ),

            const SizedBox(height: RadhaSpacing.space24),

            // ─── Data & privacy ─────────────────────────────────────────
            SettingsSectionLabel(label: l10n.settingsDataPrivacy),
            SettingsRow(
              icon: Icons.no_food_outlined,
              label: l10n.settingsAllergens,
              subtitle: l10n.settingsAllergensHint,
              onTap: () => context.push(AppRoute.allergens),
            ),
            _DestructiveActionRow(
              icon: Icons.devices_outlined,
              label: l10n.settingsSignOutAll,
              onTap: () => _confirmSignOutAll(context, ref),
            ),
            _DestructiveActionRow(
              icon: Icons.delete_forever_outlined,
              label: l10n.settingsDeleteAccount,
              onTap: () => _confirmDeleteAccount(context, ref, user),
            ),

            const SizedBox(height: RadhaSpacing.space24),

            // ─── About ──────────────────────────────────────────────────
            SettingsSectionLabel(label: l10n.settingsAbout),
            SettingsRow(
              icon: Icons.description_outlined,
              label: l10n.settingsTerms,
              onTap: () => _openExternalUrl(context, _termsUrl),
            ),
            SettingsRow(
              icon: Icons.privacy_tip_outlined,
              label: l10n.settingsPrivacyPolicy,
              onTap: () => _openExternalUrl(context, _privacyUrl),
            ),
            SettingsRow(
              icon: Icons.info_outline_rounded,
              label: l10n.settingsVersion,
              subtitle: packageInfoAsync.when(
                loading: () => '…',
                error: (_, _) => '—',
                data: (info) => l10n.settingsVersionValue(
                  info.version,
                  info.buildNumber,
                ),
              ),
              showChevron: false,
            ),
            SettingsRow(
              icon: Icons.support_agent_outlined,
              label: l10n.settingsSupport,
              subtitle: l10n.settingsSupportHint,
              onTap: () => context.push(AppRoute.support),
            ),
            const SizedBox(height: RadhaSpacing.space32),
          ],
        ),
      ),
    );
  }

  // ── External link launching ─────────────────────────────────────────────

  Future<void> _openExternalUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final l10n = AppLocalizations.of(context);
    try {
      final ok = await launchUrl(
        uri,
        // Webview package isn't in pubspec — externalApplication mode hands
        // the user off to the device's default browser, which is the
        // calmest treatment for V1.
        mode: LaunchMode.externalApplication,
      );
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsLinkOpenFailed)),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsLinkOpenFailed)),
      );
    }
  }

  // ── Sign out from all devices ──────────────────────────────────────────

  Future<void> _confirmSignOutAll(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.settingsSignOutAllConfirmTitle),
          content: Text(l10n.settingsSignOutAllConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.signOut),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;

    // The api_client doesn't expose a `logoutAllDevices` endpoint today —
    // use the regular `logout()` so the local session wipes immediately.
    // Open question logged in the FE-32 summary to add the endpoint.
    await ref.read(authControllerProvider.notifier).logout();
    if (!context.mounted) return;
    context.go(AppRoute.authOtp);
  }

  // ── Delete account ─────────────────────────────────────────────────────

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    WidgetRef ref,
    CurrentUser? user,
  ) async {
    final l10n = AppLocalizations.of(context);
    // No `DELETE /auth/account` endpoint on api_client yet — surface a
    // calm "contact support" path instead of a fake confirm dialog.
    final goSupport = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.settingsDeleteAccountTitle),
          content: Text(l10n.settingsDeleteAccountUnavailable),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.settingsDeleteAccountContact),
            ),
          ],
        );
      },
    );
    if (goSupport != true || !context.mounted) return;
    context.push(AppRoute.support);
  }
}

// ─── Toggle row ───────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      icon: icon,
      label: label,
      subtitle: subtitle,
      onTap: () => onChanged(!value),
      showChevron: false,
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

// ─── Destructive row (rose-tinted) ───────────────────────────────────────

class _DestructiveActionRow extends StatelessWidget {
  const _DestructiveActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      icon: icon,
      label: label,
      onTap: onTap,
      destructive: true,
    );
  }
}

// ─── Theme picker ────────────────────────────────────────────────────────

class _ThemePickerRow extends StatelessWidget {
  const _ThemePickerRow({required this.themeMode, required this.onChanged});

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _SegmentedRow(
      icon: Icons.brightness_6_outlined,
      label: l10n.settingsTheme,
      options: <_SegmentOption<ThemeMode>>[
        _SegmentOption(value: ThemeMode.system, label: l10n.settingsThemeSystem),
        _SegmentOption(value: ThemeMode.light, label: l10n.settingsThemeLight),
        _SegmentOption(value: ThemeMode.dark, label: l10n.settingsThemeDark),
      ],
      selectedValue: themeMode,
      onChanged: onChanged,
    );
  }
}

// ─── Text-size picker ────────────────────────────────────────────────────

class _TextSizePickerRow extends StatelessWidget {
  const _TextSizePickerRow({required this.scale, required this.onChanged});

  final TextScalePreference scale;
  final ValueChanged<TextScalePreference> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _SegmentedRow(
      icon: Icons.format_size_outlined,
      label: l10n.settingsTextSize,
      options: <_SegmentOption<TextScalePreference>>[
        _SegmentOption(
          value: TextScalePreference.small,
          label: l10n.settingsTextSizeSmall,
        ),
        _SegmentOption(
          value: TextScalePreference.standard,
          label: l10n.settingsTextSizeStandard,
        ),
        _SegmentOption(
          value: TextScalePreference.large,
          label: l10n.settingsTextSizeLarge,
        ),
      ],
      selectedValue: scale,
      onChanged: onChanged,
    );
  }
}

// ─── Generic segmented row ───────────────────────────────────────────────

class _SegmentOption<T> {
  const _SegmentOption({required this.value, required this.label});
  final T value;
  final String label;
}

class _SegmentedRow<T> extends StatelessWidget {
  const _SegmentedRow({
    required this.icon,
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final List<_SegmentOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space24,
        vertical: RadhaSpacing.space12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: scheme.onSurface),
              const SizedBox(width: RadhaSpacing.space16),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: RadhaSpacing.space12),
          Container(
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
              border: Border.all(color: scheme.outline, width: 1),
            ),
            child: Row(
              children: [
                for (var i = 0; i < options.length; i++)
                  Expanded(
                    child: _SegmentButton<T>(
                      option: options[i],
                      selected: options[i].value == selectedValue,
                      onTap: () => onChanged(options[i].value),
                      isFirst: i == 0,
                      isLast: i == options.length - 1,
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

class _SegmentButton<T> extends StatelessWidget {
  const _SegmentButton({
    required this.option,
    required this.selected,
    required this.onTap,
    required this.isFirst,
    required this.isLast,
  });

  final _SegmentOption<T> option;
  final bool selected;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final radiusLeft = isFirst
        ? const Radius.circular(RadhaRadii.radiusMd - 1)
        : Radius.zero;
    final radiusRight = isLast
        ? const Radius.circular(RadhaRadii.radiusMd - 1)
        : Radius.zero;

    return InkWell(
      onTap: () {
        if (!selected) HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.horizontal(
        left: radiusLeft,
        right: radiusRight,
      ),
      child: AnimatedContainer(
        duration: RadhaMotion.fast,
        curve: RadhaMotion.easeOut,
        height: kMinTouchTarget,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: radiusLeft,
            right: radiusRight,
          ),
        ),
        child: AnimatedDefaultTextStyle(
          duration: RadhaMotion.fast,
          style:
              theme.textTheme.labelLarge?.copyWith(
                color: selected ? scheme.primary : scheme.onSurface,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ) ??
              const TextStyle(),
          child: Text(option.label),
        ),
      ),
    );
  }
}

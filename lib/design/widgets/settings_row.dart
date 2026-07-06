// Settings row primitive (FE-32).
//
// Hoisted out of `profile_screen.dart`'s `_ActionRow` so the new
// Settings hub can reuse the same visual treatment. Profile retains
// its private copy for now — it can adopt this widget in a follow-up
// without touching the user-visible layout.
//
// Visual rules:
//   * 56pt minimum height (above the 44pt touch-target floor).
//   * 24px horizontal padding to match the section labels.
//   * Single-line title (titleSmall), optional subtitle (bodySmall).
//   * No emoji icons; consume Material `Icons.*_outlined` only.
//   * `destructive: true` re-tints the icon, label, and chevron with
//     `colorScheme.error` (rose) for sign-out and delete actions.

import 'package:flutter/material.dart';

import '../tokens.dart';

/// Tappable settings list row. Renders an icon, title, optional subtitle,
/// and a trailing chevron — or a custom `trailing` widget (e.g. a Switch).
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.destructive = false,
    this.showChevron = true,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool destructive;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = destructive ? scheme.error : scheme.onSurface;
    final mutedColor = destructive
        ? scheme.error.withValues(alpha: 0.7)
        : scheme.onSurfaceVariant;

    final effectiveTrailing =
        trailing ??
        (showChevron && onTap != null
            ? Icon(Icons.chevron_right_rounded, size: 22, color: mutedColor)
            : null);

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(
          horizontal: RadhaSpacing.space24,
          vertical: RadhaSpacing.space12,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: RadhaSpacing.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(color: color),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: mutedColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (effectiveTrailing != null) ...[
              const SizedBox(width: RadhaSpacing.space8),
              effectiveTrailing,
            ],
          ],
        ),
      ),
    );
  }
}

/// All-caps settings section label. Sits above a group of [SettingsRow]s.
class SettingsSectionLabel extends StatelessWidget {
  const SettingsSectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        RadhaSpacing.space24,
        RadhaSpacing.space8,
        RadhaSpacing.space24,
        RadhaSpacing.space8,
      ),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

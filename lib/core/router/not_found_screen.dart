import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design/app_assets.dart';
import '../../design/tokens.dart';
import '../../design/widgets/mor_companion.dart';
import '../../l10n/generated/app_localizations.dart';
import 'app_router.dart';

/// Branded 404 surface for GoRouter's `errorBuilder`.
///
/// Replaces the default bare Material scaffold: Mor (concern mood) + warm copy
/// + a single clear way back home, all on brand tokens. A dead-end route never
/// drops the user onto an off-brand grey error page.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, this.location});

  /// The unmatched location, shown only as muted fine print for debugging.
  final String? location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(RadhaSpacing.space24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MorCompanion(
                  mood: MorMood.concern,
                  size: 120,
                  semanticLabel: l10n.notFoundSemantic,
                ),
                const SizedBox(height: RadhaSpacing.space24),
                Text(
                  l10n.notFoundTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space8),
                Text(
                  l10n.notFoundBody,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space24),
                FilledButton(
                  onPressed: () => context.go(AppRoute.home),
                  child: Text(l10n.notFoundBackHome),
                ),
                if (location != null && location!.isNotEmpty) ...[
                  const SizedBox(height: RadhaSpacing.space24),
                  Text(
                    location!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

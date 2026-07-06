import 'package:flutter/material.dart';

import '../tokens.dart';

/// Editorial section header. Optional eyebrow above the title and an action
/// slot on the trailing edge for "See all" / "Add" affordances.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.action,
    this.padding,
  });

  final String title;
  final String? eyebrow;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: RadhaSpacing.space24,
            vertical: RadhaSpacing.space16,
          ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (eyebrow != null) ...[
                  Text(
                    eyebrow!.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: RadhaSpacing.space4),
                ],
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: RadhaSpacing.space12),
            action!,
          ],
        ],
      ),
    );
  }
}

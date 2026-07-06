import 'package:flutter/material.dart';

import '../tokens.dart';

/// Outlined variant of `PrimaryButton`. Same metrics, 1px outline using the
/// `outline` token through the theme.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabled = loading || onPressed == null;

    final child = AnimatedSwitcher(
      duration: RadhaMotion.fast,
      switchInCurve: RadhaMotion.easeOut,
      switchOutCurve: RadhaMotion.easeOut,
      child: loading
          ? SizedBox(
              key: const ValueKey('loading'),
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: RadhaSpacing.space8),
                ],
                Text(label),
              ],
            ),
    );

    final button = OutlinedButton(
      onPressed: disabled ? null : onPressed,
      child: child,
    );

    if (expand) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

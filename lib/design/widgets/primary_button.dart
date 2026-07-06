import 'package:flutter/material.dart';

import '../tokens.dart';

/// Brand primary CTA. Wraps `FilledButton` with a `loading` state that swaps
/// the label for a 16px progress indicator and a leading `icon` slot.
///
/// Always reads from the global theme — no inline color literals.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
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
                  theme.colorScheme.onPrimary,
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

    final button = FilledButton(
      onPressed: disabled ? null : onPressed,
      child: child,
    );

    if (expand) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

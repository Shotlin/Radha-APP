import 'package:flutter/material.dart';

import '../tokens.dart';

/// Semantic tone for a [RadhaStatusChip]. Maps to the brand's functional
/// palette — never an arbitrary colour.
enum RadhaStatusTone { neutral, info, success, warning, danger }

/// The one status-pill grammar for the whole app.
///
/// Consolidates the private `_StatusChip` / `_StatusPill` / `_Tag` copies that
/// live in grn / reports / tasks / scan-audit (and more). Renders a tonal-tint
/// pill: the tone colour at low alpha behind a bold, same-tone label.
///
/// **Not colour-alone:** the label text always carries the meaning, and an
/// optional leading [icon] can reinforce it for users who can't distinguish the
/// tint — satisfying the accessibility contract. Map wire values to a localized
/// [label] at the call site; this widget never translates.
///
/// Reads colour only from tokens, so it renders correctly on light and dark
/// surfaces (the functional swatches are shared across both).
class RadhaStatusChip extends StatelessWidget {
  const RadhaStatusChip({
    super.key,
    required this.label,
    this.tone = RadhaStatusTone.neutral,
    this.icon,
    this.dense = true,
  });

  final String label;
  final RadhaStatusTone tone;

  /// Optional leading glyph so the state reads without relying on colour.
  final IconData? icon;

  /// Tighter padding/typography for inline use inside dense list rows.
  final bool dense;

  Color _toneColor() => switch (tone) {
    RadhaStatusTone.neutral => RadhaColors.inkMuted,
    RadhaStatusTone.info => RadhaColors.complement,
    RadhaStatusTone.success => RadhaColors.success,
    RadhaStatusTone.warning => RadhaColors.warning,
    RadhaStatusTone.danger => RadhaColors.danger,
  };

  @override
  Widget build(BuildContext context) {
    final color = _toneColor();
    final fontSize = dense ? 11.0 : 12.0;

    return Semantics(
      label: label,
      container: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: dense ? RadhaSpacing.space8 : RadhaSpacing.space12,
          vertical: dense ? 2 : RadhaSpacing.space4,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: fontSize + 3, color: color),
              const SizedBox(width: RadhaSpacing.space4),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

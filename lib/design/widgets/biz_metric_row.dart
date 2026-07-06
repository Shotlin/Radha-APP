import 'package:flutter/material.dart';
import '../tokens.dart';
import 'radha_icon_tile.dart';

/// Data for a single metric card in a [BizMetricRow].
class BizMetric {
  const BizMetric({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;
}

/// Horizontal row of 2–3 colored metric stat cards.
/// Used at the top of every business screen below the hero image.
class BizMetricRow extends StatelessWidget {
  const BizMetricRow({
    super.key,
    required this.metrics,
    this.padding = const EdgeInsets.fromLTRB(
      RadhaSpacing.space16,
      RadhaSpacing.space16,
      RadhaSpacing.space16,
      RadhaSpacing.space4,
    ),
  });

  final List<BizMetric> metrics;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          for (int i = 0; i < metrics.length; i++) ...[
            if (i > 0) const SizedBox(width: RadhaSpacing.space8),
            Expanded(child: _BizMetricCard(metric: metrics[i])),
          ],
        ],
      ),
    );
  }
}

class _BizMetricCard extends StatelessWidget {
  const _BizMetricCard({required this.metric});

  final BizMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space12,
        vertical: RadhaSpacing.space12,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        boxShadow: RadhaShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          RadhaIconTile(icon: metric.icon, tint: metric.color, size: 36),
          const SizedBox(height: RadhaSpacing.space8),
          Text(
            metric.value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: metric.color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            metric.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.2,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

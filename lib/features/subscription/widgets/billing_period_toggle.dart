// Segmented toggle for switching between Monthly Plans and 1-Day Passes.

import 'package:flutter/material.dart';

import '../../../design/tokens.dart';
import '../models/plan_model.dart';

class BillingPeriodToggle extends StatelessWidget {
  const BillingPeriodToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final BillingPeriod selected;
  final ValueChanged<BillingPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SegmentedButton<BillingPeriod>(
      segments: const [
        ButtonSegment(
          value: BillingPeriod.monthly,
          label: Text('Monthly Plans'),
          icon: Icon(Icons.calendar_month_rounded, size: 16),
        ),
        ButtonSegment(
          value: BillingPeriod.day,
          label: Text('1-Day Passes'),
          icon: Icon(Icons.bolt_rounded, size: 16),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (s) => onChanged(s.first),
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: RadhaColors.primary,
        selectedForegroundColor: RadhaColors.onPrimary,
        foregroundColor: theme.colorScheme.onSurfaceVariant,
        side: BorderSide(color: theme.colorScheme.outline),
        textStyle: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Sync status banner.
//
// 32px sticky strip rendered at the top of every authenticated screen,
// driven by [pendingWriteCountStreamProvider]. Renders nothing when the
// queue is empty so screens never lose vertical real estate during the
// happy path.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/offline/db.dart';
import '../../design/tokens.dart';

/// Thin banner that surfaces the pending-write queue depth. Watched count
/// flows from Drift via [pendingWriteCountStreamProvider]; the widget hides
/// itself when the count is zero or the stream is in an unsettled state.
class SyncStatusBanner extends ConsumerWidget {
  const SyncStatusBanner({super.key});

  /// Banner height. Spec calls for "thin (32px) banner".
  static const double height = 32.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCount = ref.watch(pendingWriteCountStreamProvider);
    final count = asyncCount.valueOrNull ?? 0;
    if (count <= 0) return const SizedBox.shrink();

    final label = count == 1
        ? '1 pending write — syncing…'
        : '$count pending writes — syncing…';

    return Material(
      color: RadhaColors.warning.withValues(alpha: 0.18),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    RadhaColors.warning,
                  ),
                ),
              ),
              const SizedBox(width: RadhaSpacing.space8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: RadhaColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

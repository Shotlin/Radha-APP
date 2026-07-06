// Recall alerts screen (Task 17 / BE-39).
//
// Lists active product recalls relevant to the signed-in tenant. Each row
// shows the product, severity badge, recall date and a one-line reason; tap
// drills into the product detail screen via the product's EAN.
//
// Design rules (from tokens.dart):
//   * Single orange accent (#EA580C). Severity uses danger red for
//     critical/high, warn amber for medium, neutral grey for low/unknown —
//     functional colour, never a second brand accent.
//   * Severity badges: small uppercase text, 6%-alpha tinted background, and
//     a matching leading colour stripe so the list scans by urgency.
//   * 44pt+ touch targets, no emoji, Plus Jakarta Sans via theme.
//   * Skeleton loaders, staggered entrance, tactile press-scale, and
//     reduce-motion awareness, matching the rest of the app.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_client.dart';
import '../../core/network/dto/misc_dto.dart';
import '../../design/app_assets.dart';
import '../../design/tokens.dart';
import '../../design/widgets/empty_state.dart';
import '../../design/widgets/error_state.dart';
import '../../design/widgets/mor_companion.dart';
import '../../l10n/generated/app_localizations.dart';

/// Provider for the list of active recall alerts. Uses
/// `apiClient.getRecalls()` which maps to `GET /api/v1/recalls`.
final recallsProvider = FutureProvider<List<RecallResponse>>((ref) async {
  final client = ref.watch(apiClientProvider);
  return client.getRecalls();
});

class RecallAlertsScreen extends ConsumerWidget {
  const RecallAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recallsAsync = ref.watch(recallsProvider);
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).recallTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(recallsProvider.future),
          child: recallsAsync.when(
            loading: () => const _RecallSkeleton(),
            error: (error, _) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 80),
                ErrorState(
                  title: AppLocalizations.of(context).recallLoadError,
                  onRetry: () => ref.invalidate(recallsProvider),
                ),
              ],
            ),
            data: (recalls) {
              if (recalls.isEmpty) {
                return ListView(
                  // RefreshIndicator needs a scrollable child even when
                  // there's nothing to show, so wrap the empty state.
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 80),
                    EmptyState(
                      illustration: const MorCompanion(
                        mood: MorMood.guard,
                        size: 104,
                      ),
                      title: AppLocalizations.of(context).recallEmpty,
                      body: AppLocalizations.of(context).recallEmptyBody,
                    ),
                  ],
                );
              }
              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: RadhaSpacing.space16,
                  vertical: RadhaSpacing.space16,
                ),
                itemCount: recalls.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: RadhaSpacing.space8),
                itemBuilder: (context, index) => _StaggerIn(
                  index: index,
                  reduceMotion: reduceMotion,
                  child: _RecallTile(
                    recall: recalls[index],
                    reduceMotion: reduceMotion,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RecallTile extends StatefulWidget {
  const _RecallTile({required this.recall, required this.reduceMotion});

  final RecallResponse recall;
  final bool reduceMotion;

  @override
  State<_RecallTile> createState() => _RecallTileState();
}

class _RecallTileState extends State<_RecallTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final recall = widget.recall;
    final title = recall.productName?.isNotEmpty == true
        ? recall.productName!
        : AppLocalizations.of(context).recallProductFallback(_short(recall.productId));
    final ean = recall.productEan;
    final tappable = ean != null && ean.isNotEmpty;
    final stripe = _severityColor(context, recall.severity);

    final scale = _pressed && !widget.reduceMotion ? 0.98 : 1.0;

    return AnimatedScale(
      scale: scale,
      duration: RadhaMotion.fast,
      curve: RadhaMotion.easeOut,
      child: Material(
        color: scheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
          side: BorderSide(color: scheme.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
          onTap: tappable
              ? () {
                  HapticFeedback.selectionClick();
                  context.push('/scan/result/$ean');
                }
              : null,
          onHighlightChanged: tappable
              ? (v) => setState(() => _pressed = v)
              : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: kMinTouchTarget),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Leading severity stripe — lets the list scan by urgency.
                  Container(width: 4, color: stripe),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(RadhaSpacing.space16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: theme.textTheme.titleSmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: RadhaSpacing.space8),
                              SeverityBadge(severity: recall.severity),
                            ],
                          ),
                          if (recall.recalledAt != null &&
                              recall.recalledAt!.isNotEmpty) ...[
                            const SizedBox(height: RadhaSpacing.space4),
                            Text(
                              AppLocalizations.of(context)
                                  .recallDate(_formatDate(recall.recalledAt!)),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          if (recall.reason != null &&
                              recall.reason!.isNotEmpty) ...[
                            const SizedBox(height: RadhaSpacing.space8),
                            Text(
                              recall.reason!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (tappable) ...[
                            const SizedBox(height: RadhaSpacing.space8),
                            Row(
                              children: [
                                Text(
                                  AppLocalizations.of(context).recallViewProduct,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: scheme.primary,
                                  ),
                                ),
                                const SizedBox(width: RadhaSpacing.space4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: scheme.primary,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Maps a severity string to its functional colour for the leading stripe.
  Color _severityColor(BuildContext context, String? severity) {
    final norm = (severity ?? '').toLowerCase().trim();
    switch (norm) {
      case 'critical':
      case 'high':
        return RadhaColors.danger;
      case 'medium':
      case 'warning':
        return RadhaColors.warning;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  /// Trims a UUID-ish identifier down to its first 8 chars for the
  /// fallback title when the backend hasn't denormalised the product
  /// name onto the alert row.
  String _short(String id) {
    if (id.length <= 8) return id;
    return id.substring(0, 8);
  }

  /// Renders an ISO-8601 date as a stable, locale-neutral `YYYY-MM-DD`. The
  /// app's design contract avoids relying on the device locale here so
  /// alerts read identically across Indian English and Hindi.
  String _formatDate(String iso) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    final y = parsed.year.toString().padLeft(4, '0');
    final m = parsed.month.toString().padLeft(2, '0');
    final d = parsed.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

/// Severity badge — small uppercase pill with a 6%-alpha tinted background.
/// Exposed so other surfaces (e.g. product detail) can reuse the same visual
/// vocabulary if they later surface recall metadata.
class SeverityBadge extends StatelessWidget {
  const SeverityBadge({super.key, required this.severity});

  final String? severity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final norm = (severity ?? '').toLowerCase().trim();

    final Color color;
    final String label;
    switch (norm) {
      case 'critical':
      case 'high':
        color = RadhaColors.danger;
        label = norm == 'critical' ? 'CRITICAL' : 'HIGH';
        break;
      case 'medium':
      case 'warning':
        color = RadhaColors.warning;
        label = 'MEDIUM';
        break;
      case 'low':
      case 'info':
        color = scheme.onSurfaceVariant;
        label = 'LOW';
        break;
      default:
        color = scheme.onSurfaceVariant;
        label = 'INFO';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space8,
        vertical: RadhaSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

/// Skeleton list shown while recalls load. Mirrors the tile layout (stripe +
/// title + badge + reason) so the load reads as the page filling in.
class _RecallSkeleton extends StatelessWidget {
  const _RecallSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget bar(double w, double h) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusSm),
      ),
    );

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space16,
        vertical: RadhaSpacing.space16,
      ),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: RadhaSpacing.space8),
      itemBuilder: (_, _) => Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
          border: Border.all(color: scheme.outline),
        ),
        padding: const EdgeInsets.all(RadhaSpacing.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: bar(double.infinity, 16)),
                const SizedBox(width: RadhaSpacing.space8),
                bar(56, 16),
              ],
            ),
            const SizedBox(height: RadhaSpacing.space12),
            bar(120, 12),
            const SizedBox(height: RadhaSpacing.space8),
            bar(double.infinity, 12),
          ],
        ),
      ),
    );
  }
}

/// Staggered fade + rise for list rows. Honours reduce-motion by rendering the
/// child immediately. Caps the per-row delay so long lists don't drag.
class _StaggerIn extends StatefulWidget {
  const _StaggerIn({
    required this.index,
    required this.reduceMotion,
    required this.child,
  });

  final int index;
  final bool reduceMotion;
  final Widget child;

  @override
  State<_StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<_StaggerIn>
    with SingleTickerProviderStateMixin {
  // Stagger baked into an Interval on a single controller started in
  // initState — never `Future.delayed` (steering §2.5/§12: delayed timers are
  // timer-leaky under widget tests).
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    final start = ((40 * widget.index).clamp(0, 320)) / 700;
    final curve = CurvedAnimation(
      parent: _c,
      curve: Interval(start, 1, curve: RadhaMotion.easeOut),
    );
    _opacity = curve;
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(curve);
    if (widget.reduceMotion) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reduceMotion) return widget.child;
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}

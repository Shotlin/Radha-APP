import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/network/api_client.dart';
import '../../core/network/dto/grn_dto.dart';
import '../../core/router/app_router.dart';
import '../../design/app_assets.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/widgets/biz_metric_row.dart';
import '../../design/widgets/biz_screen_hero.dart';
import '../../design/widgets/empty_state.dart';
import '../../design/widgets/mor_companion.dart';
import '../../l10n/generated/app_localizations.dart';

/// Maps a GRN filter-tab id (null = All) to its display label.
String _filterLabel(AppLocalizations l10n, String? id) {
  switch (id) {
    case 'open':
      return 'Open';
    case 'posted':
      return 'Completed';
    default:
      return 'All';
  }
}

/// Maps a backend GRN status code to its localized pill label.
String _statusLabel(AppLocalizations l10n, String status) {
  switch (status) {
    case 'draft':
      return l10n.grnFilterDraft;
    case 'pending_review':
      return l10n.grnStatusPending;
    case 'posted':
      return l10n.grnFilterPosted;
    default:
      return status;
  }
}

/// Paginated GRN list state — keeps loaded items + the page cursor so we can
/// append more rows on scroll without rebuilding the whole list.
class _GrnListState {
  const _GrnListState({
    required this.items,
    required this.cursor,
    required this.hasMore,
    required this.loadingMore,
  });

  final List<GrnResponse> items;
  final String? cursor;
  final bool hasMore;
  final bool loadingMore;

  _GrnListState copyWith({
    List<GrnResponse>? items,
    Object? cursor = _sentinel,
    bool? hasMore,
    bool? loadingMore,
  }) {
    return _GrnListState(
      items: items ?? this.items,
      cursor: identical(cursor, _sentinel) ? this.cursor : cursor as String?,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }

  static const _sentinel = Object();
}

/// Cursor-paginated GRN list controller (mirrors the inventory list pattern).
class _GrnListController extends AutoDisposeAsyncNotifier<_GrnListState> {
  static const _pageSize = 30;

  @override
  Future<_GrnListState> build() async {
    final client = ref.watch(apiClientProvider);
    final page = await client.getGrns(limit: _pageSize);
    return _GrnListState(
      items: page.items,
      cursor: page.cursor,
      hasMore: page.cursor != null && page.items.length >= _pageSize,
      loadingMore: false,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final client = ref.read(apiClientProvider);
      final page = await client.getGrns(limit: _pageSize);
      return _GrnListState(
        items: page.items,
        cursor: page.cursor,
        hasMore: page.cursor != null && page.items.length >= _pageSize,
        loadingMore: false,
      );
    });
  }

  /// Append the next page when a cursor is available. Errors keep the
  /// already-loaded rows in place (no data loss on a failed page).
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null) return;
    if (!current.hasMore || current.loadingMore) return;

    state = AsyncValue.data(current.copyWith(loadingMore: true));
    try {
      final client = ref.read(apiClientProvider);
      final page = await client.getGrns(cursor: current.cursor, limit: _pageSize);
      state = AsyncValue.data(
        _GrnListState(
          items: [...current.items, ...page.items],
          cursor: page.cursor,
          hasMore: page.cursor != null && page.items.length >= _pageSize,
          loadingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncValue.data(current.copyWith(loadingMore: false));
    }
  }
}

final _grnListControllerProvider =
    AsyncNotifierProvider.autoDispose<_GrnListController, _GrnListState>(
      _GrnListController.new,
    );

final _grnStatsProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final client = ref.read(apiClientProvider);
  final data = await client.getGrns(limit: 200);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  int open = 0, mismatch = 0, receivedToday = 0;
  for (final g in data.items) {
    if (g.status == 'draft' || g.status == 'pending_review') open++;
    if (g.status == 'pending_review') mismatch++;
    if (g.status == 'posted' && g.createdAt != null) {
      try {
        final created = DateTime.parse(g.createdAt!);
        if (DateTime(created.year, created.month, created.day).isAtSameMomentAs(today)) {
          receivedToday++;
        }
      } catch (_) {}
    }
  }
  return {'open': open, 'mismatch': mismatch, 'receivedToday': receivedToday};
});

/// GRN list — status filter tabs (Draft / Pending review / Posted), polished
/// supplier cards with status pills, invoice meta, and a mono rupee total.
class GrnListScreen extends ConsumerStatefulWidget {
  const GrnListScreen({super.key});

  @override
  ConsumerState<GrnListScreen> createState() => _GrnListScreenState();
}

class _GrnListScreenState extends ConsumerState<GrnListScreen> {
  String? _statusFilter;
  final _scrollController = ScrollController();

  /// Filter tab IDs: null = All, 'open' = Draft+Pending, 'posted' = Completed.
  static const _filterIds = <String?>[null, 'open', 'posted'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(_grnListControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final grnsAsync = ref.watch(_grnListControllerProvider);
    final filters = <(String?, String)>[
      for (final id in _filterIds) (id, _filterLabel(l10n, id)),
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          l10n.grnTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          BizScreenHero(
            assetPath: RadhaAssets.heroGoodsReceiving,
            headline: 'Receive every delivery with proof',
            subtitle: 'Verify, match and log goods received',
          ),
          const _GrnStatsRow(),
          const _GrnActionsRow(),
          _StatusTabs(
            filters: filters,
            selected: _statusFilter,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              setState(() => _statusFilter = value);
            },
          ),
          Expanded(
            child: grnsAsync.when(
              loading: () => const _GrnSkeleton(),
              error: (err, _) => _GrnError(
                onRetry: () =>
                    ref.read(_grnListControllerProvider.notifier).refresh(),
              ),
              data: (state) {
                var items = [...state.items];
                if (_statusFilter != null) {
                  if (_statusFilter == 'open') {
                    items = items
                        .where((g) => g.status == 'draft' || g.status == 'pending_review')
                        .toList();
                  } else {
                    items = items
                        .where((g) => g.status == _statusFilter)
                        .toList();
                  }
                }
                items.sort((a, b) {
                  final aDate = a.invoiceDate ?? a.createdAt ?? '';
                  final bDate = b.invoiceDate ?? b.createdAt ?? '';
                  return bDate.compareTo(aDate);
                });

                if (items.isEmpty) {
                  return RefreshIndicator(
                    color: RadhaColors.primary,
                    onRefresh: () async => ref
                        .read(_grnListControllerProvider.notifier)
                        .refresh(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.14,
                        ),
                        Center(
                          child: EmptyState(
                            illustration: const MorCompanion(
                              mood: MorMood.greet,
                              size: 104,
                            ),
                            title: l10n.grnEmptyTitle,
                            body: l10n.grnEmptyBody,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Only show the load-more footer when the full (unfiltered)
                // list has more pages — a client-side status filter shouldn't
                // imply more rows are coming.
                final showFooter = state.loadingMore && _statusFilter == null;
                return RefreshIndicator(
                  color: RadhaColors.primary,
                  onRefresh: () async => ref
                      .read(_grnListControllerProvider.notifier)
                      .refresh(),
                  child: ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(
                      RadhaSpacing.space20,
                      RadhaSpacing.space12,
                      RadhaSpacing.space20,
                      RadhaSpacing.space32 + 72,
                    ),
                    itemCount: items.length + (showFooter ? 1 : 0),
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: RadhaSpacing.space12),
                    itemBuilder: (context, index) {
                      if (index >= items.length) {
                        return const Padding(
                          padding: EdgeInsets.all(RadhaSpacing.space16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: RadhaColors.primary,
                            ),
                          ),
                        );
                      }
                      return _GrnTile(grn: items[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'grn_fab',
        backgroundColor: RadhaColors.primary,
        foregroundColor: RadhaColors.onPrimary,
        onPressed: () {
          HapticFeedback.lightImpact();
          context.push(AppRoute.grnCreate);
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.grnNew),
      ),
    );
  }
}

// ─── Stats row ───────────────────────────────────────────────────────────────

class _GrnStatsRow extends ConsumerWidget {
  const _GrnStatsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(_grnStatsProvider);
    return statsAsync.when(
      loading: () => BizMetricRow(metrics: const [
        BizMetric(value: '—', label: 'Open', icon: Icons.inbox_outlined, color: RadhaColors.primary),
        BizMetric(value: '—', label: 'Mismatch', icon: Icons.compare_arrows_rounded, color: RadhaColors.warning),
        BizMetric(value: '—', label: 'Received today', icon: Icons.check_circle_outline_rounded, color: RadhaColors.success),
      ]),
      error: (_, __) => BizMetricRow(metrics: const [
        BizMetric(value: '—', label: 'Open', icon: Icons.inbox_outlined, color: RadhaColors.primary),
        BizMetric(value: '—', label: 'Mismatch', icon: Icons.compare_arrows_rounded, color: RadhaColors.warning),
        BizMetric(value: '—', label: 'Received today', icon: Icons.check_circle_outline_rounded, color: RadhaColors.success),
      ]),
      data: (stats) => BizMetricRow(metrics: [
        BizMetric(value: '${stats['open'] ?? 0}', label: 'Open', icon: Icons.inbox_outlined, color: RadhaColors.primary),
        BizMetric(value: '${stats['mismatch'] ?? 0}', label: 'Mismatch', icon: Icons.compare_arrows_rounded, color: RadhaColors.warning),
        BizMetric(value: '${stats['receivedToday'] ?? 0}', label: 'Received today', icon: Icons.check_circle_outline_rounded, color: RadhaColors.success),
      ]),
    );
  }
}

class _GrnActionsRow extends StatelessWidget {
  const _GrnActionsRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        RadhaSpacing.space16,
        RadhaSpacing.space4,
        RadhaSpacing.space16,
        RadhaSpacing.space12,
      ),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: RadhaColors.primary,
                foregroundColor: RadhaColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: RadhaSpacing.space12),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                context.push(AppRoute.grnCreate);
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Create GRN', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: RadhaSpacing.space8),
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: RadhaSpacing.space12),
                side: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                context.push(AppRoute.scan);
              },
              icon: Icon(Icons.document_scanner_outlined, size: 18, color: Theme.of(context).colorScheme.onSurface),
              label: Text('Scan invoice', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Underline status tabs.
class _StatusTabs extends StatelessWidget {
  const _StatusTabs({
    required this.filters,
    required this.selected,
    required this.onChanged,
  });

  final List<(String?, String)> filters;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.colorScheme.outline)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: RadhaSpacing.space12),
        child: Row(
          children: filters.map((f) {
            final active = selected == f.$1;
            return GestureDetector(
              onTap: () => onChanged(f.$1),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: RadhaSpacing.space12,
                  vertical: RadhaSpacing.space12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      f.$2,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: active
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: active
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: RadhaSpacing.space8),
                    AnimatedContainer(
                      duration: RadhaMotion.fast,
                      curve: RadhaMotion.easeOut,
                      height: 2.5,
                      width: active ? 20 : 0,
                      decoration: BoxDecoration(
                        color: RadhaColors.primary,
                        borderRadius: BorderRadius.circular(
                          RadhaRadii.radiusFull,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Single GRN card.
class _GrnTile extends StatefulWidget {
  const _GrnTile({required this.grn});

  final GrnResponse grn;

  @override
  State<_GrnTile> createState() => _GrnTileState();
}

class _GrnTileState extends State<_GrnTile> {
  bool _pressed = false;

  void _set(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grn = widget.grn;

    return GestureDetector(
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: () {
        HapticFeedback.selectionClick();
        context.push('/grn/${grn.id}/items');
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: RadhaMotion.fast,
        curve: RadhaMotion.spring,
        child: Container(
          padding: const EdgeInsets.all(RadhaSpacing.space16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      grn.supplierName ??
                          AppLocalizations.of(context).grnSupplierFallback,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: RadhaSpacing.space8),
                  _StatusPill(status: grn.status),
                ],
              ),
              const SizedBox(height: RadhaSpacing.space8),
              Text(
                [
                  if (grn.invoiceNumber != null) grn.invoiceNumber,
                  if (grn.invoiceDate != null)
                    _formatDate(
                      grn.invoiceDate!,
                      Localizations.localeOf(context).languageCode,
                    ),
                ].whereType<String>().join(' · '),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: RadhaSpacing.space12),
              Row(
                children: [
                  Text(
                    '${grn.totalItems ?? 0} items',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\u20B9 ${_formatValue(grn.totalValue)}',
                    style: radhaMonoStyle(
                      fontSize: 15,
                      weight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: RadhaSpacing.space8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatValue(double? v) {
    if (v == null) return '0';
    // Indian grouping is nice-to-have; keep a clean integer with thousands.
    final whole = v.round();
    final s = whole.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String _formatDate(String iso, String localeName) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('d MMM', localeName).format(dt);
    } catch (_) {
      return iso;
    }
  }
}

/// Status pill.
class _StatusPill extends StatelessWidget {
  const _StatusPill({this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    if (status == null) return const SizedBox.shrink();
    final color = _statusColor(status!);
    final label = _statusLabel(AppLocalizations.of(context), status!);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'draft':
      return RadhaColors.inkMuted;
    case 'pending_review':
      return RadhaColors.warning;
    case 'posted':
      return RadhaColors.success;
    default:
      return RadhaColors.inkMuted;
  }
}


// ─── Loading / empty / error ─────────────────────────────────────────────────

class _GrnSkeleton extends StatelessWidget {
  const _GrnSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        RadhaSpacing.space20,
        RadhaSpacing.space12,
        RadhaSpacing.space20,
        RadhaSpacing.space32,
      ),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: RadhaSpacing.space12),
      itemBuilder: (_, _) => Container(
        height: 104,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
          border: Border.all(color: theme.colorScheme.outline),
        ),
      ),
    );
  }
}

// _EmptyIllustration removed — empty states now use MorCompanion.

class _GrnError extends StatelessWidget {
  const _GrnError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RadhaSpacing.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MorCompanion(
              mood: MorMood.concern,
              size: 96,
              semanticLabel: l10n.commonCouldNotLoad,
            ),
            const SizedBox(height: RadhaSpacing.space16),
            Text(l10n.grnLoadError, style: theme.textTheme.bodyMedium),
            const SizedBox(height: RadhaSpacing.space16),
            OutlinedButton(onPressed: onRetry, child: Text(l10n.tryAgain)),
          ],
        ),
      ),
    );
  }
}

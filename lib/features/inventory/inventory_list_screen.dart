import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_client.dart';
import '../../core/network/dto/inventory_dto.dart';
import '../../core/router/app_router.dart';
import '../../design/app_assets.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/widgets/biz_metric_row.dart';
import '../../design/widgets/biz_screen_hero.dart';
import '../../design/widgets/mor_companion.dart';
import '../../l10n/generated/app_localizations.dart';

/// State controller that hydrates the inventory list with cursor pagination
/// and exposes a single `AsyncValue<List<InventoryItemResponse>>` to the UI.
///
/// The store keeps the current page cursor + already-loaded items so we can
/// append more rows when the user scrolls without rewriting the whole list.
class _InventoryListState {
  const _InventoryListState({
    required this.items,
    required this.cursor,
    required this.hasMore,
    required this.loadingMore,
  });

  final List<InventoryItemResponse> items;
  final String? cursor;
  final bool hasMore;
  final bool loadingMore;

  _InventoryListState copyWith({
    List<InventoryItemResponse>? items,
    Object? cursor = _sentinel,
    bool? hasMore,
    bool? loadingMore,
  }) {
    return _InventoryListState(
      items: items ?? this.items,
      cursor: identical(cursor, _sentinel) ? this.cursor : cursor as String?,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }

  static const _sentinel = Object();
}

class _InventoryListController
    extends AutoDisposeAsyncNotifier<_InventoryListState> {
  static const _pageSize = 30;

  @override
  Future<_InventoryListState> build() async {
    final client = ref.watch(apiClientProvider);
    final page = await client.getInventory(limit: _pageSize);
    return _InventoryListState(
      items: page.items,
      cursor: page.cursor,
      hasMore: page.cursor != null && page.items.length >= _pageSize,
      loadingMore: false,
    );
  }

  /// Refresh the list from the top, discarding any loaded pages.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final client = ref.read(apiClientProvider);
      final page = await client.getInventory(limit: _pageSize);
      return _InventoryListState(
        items: page.items,
        cursor: page.cursor,
        hasMore: page.cursor != null && page.items.length >= _pageSize,
        loadingMore: false,
      );
    });
  }

  /// Append the next page if a cursor is available and we aren't already
  /// fetching one. Errors keep the existing items in place.
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null) return;
    if (!current.hasMore || current.loadingMore) return;

    state = AsyncValue.data(current.copyWith(loadingMore: true));

    try {
      final client = ref.read(apiClientProvider);
      final page = await client.getInventory(
        cursor: current.cursor,
        limit: _pageSize,
      );
      state = AsyncValue.data(
        _InventoryListState(
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

final _inventoryListControllerProvider =
    AsyncNotifierProvider.autoDispose<
      _InventoryListController,
      _InventoryListState
    >(_InventoryListController.new);

final _inventoryStatsProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final client = ref.read(apiClientProvider);
  final data = await client.getInventory(limit: 200);
  int skus = data.items.length;
  int lowStock = 0;
  int outOfStock = 0;
  for (final item in data.items) {
    if (item.quantity == 0) {
      outOfStock++;
    } else if (item.lowStockThreshold != null && item.quantity < item.lowStockThreshold!) {
      lowStock++;
    }
  }
  return {'skus': skus, 'lowStock': lowStock, 'outOfStock': outOfStock};
});

/// Inventory list screen showing current stock per product with a low-stock
/// badge, expandable batch breakdown, search-by-product/EAN filter, infinite
/// scroll across cursor pages, and quick links to stock movement + low-stock
/// alerts.
///
/// Consumes the inventory listing endpoint that backs Requirements R17 + R18
/// (current stock, low-stock flag).
class InventoryListScreen extends ConsumerStatefulWidget {
  const InventoryListScreen({super.key});

  @override
  ConsumerState<InventoryListScreen> createState() =>
      _InventoryListScreenState();
}

class _InventoryListScreenState extends ConsumerState<InventoryListScreen> {
  bool _showSearch = false;
  String _searchQuery = '';
  String? _stockFilter;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

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
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(_inventoryListControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final inventoryAsync = ref.watch(_inventoryListControllerProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: _showSearch
            ? _SearchField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                onClose: () => setState(() {
                  _showSearch = false;
                  _searchQuery = '';
                  _searchController.clear();
                }),
              )
            : Text(
                l10n.inventoryTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
        actions: [
          if (!_showSearch)
            IconButton(
              icon: const Icon(Icons.search_rounded),
              tooltip: l10n.inventorySearchTooltip,
              onPressed: () => setState(() => _showSearch = true),
            ),
        ],
      ),
      body: Column(
        children: [
          BizScreenHero(
            assetPath: RadhaAssets.heroInventory,
            headline: 'Know what is on every shelf',
            subtitle: 'Real-time stock visibility',
          ),
          const _InventoryStatsRow(),
          _InventoryQuickActions(
            onStockIn: () => context.push(AppRoute.inventoryStockMovement),
            onStockOut: () => context.push(AppRoute.inventoryStockMovement),
            onScan: () => context.push(AppRoute.scan),
          ),
          _InventoryFilterChips(
            selected: _stockFilter,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              setState(() => _stockFilter = v);
            },
          ),
          Expanded(
            child: inventoryAsync.when(
              loading: () => const _InventorySkeleton(),
              error: (err, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MorCompanion(
                      mood: MorMood.concern,
                      size: 96,
                      semanticLabel: l10n.expiryCouldNotLoadSemantic,
                    ),
                    const SizedBox(height: RadhaSpacing.space12),
                    Text(
                      l10n.inventoryLoadError,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: RadhaSpacing.space8),
                    FilledButton(
                      onPressed: () => ref
                          .read(_inventoryListControllerProvider.notifier)
                          .refresh(),
                      child: Text(l10n.tryAgain),
                    ),
                  ],
                ),
              ),
              data: (state) {
                final items = _filter(state.items, _searchQuery, _stockFilter);

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const MorCompanion(mood: MorMood.greet, size: 104),
                        const SizedBox(height: RadhaSpacing.space12),
                        Text(
                          _searchQuery.isEmpty
                              ? l10n.inventoryEmpty
                              : l10n.inventoryNoMatches(_searchQuery),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(_inventoryListControllerProvider.notifier)
                      .refresh(),
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      RadhaSpacing.space24,
                      RadhaSpacing.space12,
                      RadhaSpacing.space24,
                      RadhaSpacing.space24,
                    ),
                    itemCount: items.length + (state.loadingMore ? 1 : 0),
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: RadhaSpacing.space12),
                    itemBuilder: (context, index) {
                      if (index >= items.length) {
                        return const Padding(
                          padding: EdgeInsets.all(RadhaSpacing.space16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      return _InventoryTile(item: items[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Filters by search query + optional stock status tab.
  static List<InventoryItemResponse> _filter(
    List<InventoryItemResponse> items,
    String query,
    String? stockFilter,
  ) {
    var filtered = items;
    if (stockFilter == 'out_of_stock') {
      filtered = filtered.where((i) => i.quantity == 0).toList();
    } else if (stockFilter == 'low_stock') {
      filtered = filtered.where((i) => i.quantity > 0 && i.lowStockThreshold != null && i.quantity < i.lowStockThreshold!).toList();
    }
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return filtered;
    return filtered
        .where((i) => i.productId.toLowerCase().contains(trimmed))
        .toList();
  }
}

// ─── Stats row ───────────────────────────────────────────────────────────────

class _InventoryStatsRow extends ConsumerWidget {
  const _InventoryStatsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(_inventoryStatsProvider);
    return statsAsync.when(
      loading: () => BizMetricRow(metrics: const [
        BizMetric(value: '—', label: 'SKUs', icon: Icons.inventory_2_outlined, color: RadhaColors.primary),
        BizMetric(value: '—', label: 'Low stock', icon: Icons.warning_amber_rounded, color: RadhaColors.warning),
        BizMetric(value: '—', label: 'Out of stock', icon: Icons.remove_shopping_cart_outlined, color: RadhaColors.danger),
      ]),
      error: (_, __) => BizMetricRow(metrics: const [
        BizMetric(value: '—', label: 'SKUs', icon: Icons.inventory_2_outlined, color: RadhaColors.primary),
        BizMetric(value: '—', label: 'Low stock', icon: Icons.warning_amber_rounded, color: RadhaColors.warning),
        BizMetric(value: '—', label: 'Out of stock', icon: Icons.remove_shopping_cart_outlined, color: RadhaColors.danger),
      ]),
      data: (stats) => BizMetricRow(metrics: [
        BizMetric(value: '${stats['skus'] ?? 0}', label: 'SKUs', icon: Icons.inventory_2_outlined, color: RadhaColors.primary),
        BizMetric(value: '${stats['lowStock'] ?? 0}', label: 'Low stock', icon: Icons.warning_amber_rounded, color: RadhaColors.warning),
        BizMetric(value: '${stats['outOfStock'] ?? 0}', label: 'Out of stock', icon: Icons.remove_shopping_cart_outlined, color: RadhaColors.danger),
      ]),
    );
  }
}

class _InventoryQuickActions extends StatelessWidget {
  const _InventoryQuickActions({
    required this.onStockIn,
    required this.onStockOut,
    required this.onScan,
  });

  final VoidCallback onStockIn;
  final VoidCallback onStockOut;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        RadhaSpacing.space16,
        RadhaSpacing.space4,
        RadhaSpacing.space16,
        RadhaSpacing.space8,
      ),
      child: Row(
        children: [
          Expanded(child: _QuickActionBtn(icon: Icons.add_box_outlined, label: 'Stock in', onTap: onStockIn, filled: true)),
          const SizedBox(width: RadhaSpacing.space8),
          Expanded(child: _QuickActionBtn(icon: Icons.remove_circle_outline_rounded, label: 'Stock out', onTap: onStockOut)),
          const SizedBox(width: RadhaSpacing.space8),
          Expanded(child: _QuickActionBtn(icon: Icons.qr_code_scanner_rounded, label: 'Scan item', onTap: onScan)),
        ],
      ),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: RadhaSpacing.space12),
        decoration: BoxDecoration(
          color: filled ? RadhaColors.primary : theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
          border: Border.all(
            color: filled ? RadhaColors.primary : theme.colorScheme.outline,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: filled ? RadhaColors.onPrimary : RadhaColors.primary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: filled ? RadhaColors.onPrimary : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryFilterChips extends StatelessWidget {
  const _InventoryFilterChips({required this.selected, required this.onChanged});

  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chips = [
      (null, 'All'),
      ('low_stock', 'Low stock'),
      ('out_of_stock', 'Out of stock'),
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: RadhaSpacing.space16),
        child: Row(
          children: chips.map((chip) {
            final active = selected == chip.$1;
            return GestureDetector(
              onTap: () => onChanged(chip.$1),
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
                      chip.$2,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: active ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
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
                        borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
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

// ─────────────────────────────────────────────────────────────────────────────

/// Borderless search field used inside the AppBar title slot.
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClose,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextField(
      controller: controller,
      autofocus: true,
      decoration: InputDecoration(
        hintText: l10n.inventorySearchHint,
        border: InputBorder.none,
        suffixIcon: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClose,
        ),
      ),
      onChanged: onChanged,
    );
  }
}

/// Single inventory row. Tap to expand the batch / threshold breakdown and
/// reveal the low-stock badge for items below their threshold.
class _InventoryTile extends StatefulWidget {
  const _InventoryTile({required this.item});

  final InventoryItemResponse item;

  @override
  State<_InventoryTile> createState() => _InventoryTileState();
}

class _InventoryTileState extends State<_InventoryTile> {
  bool _expanded = false;

  bool get _isLowStock {
    final threshold = widget.item.lowStockThreshold;
    if (threshold == null) return false;
    return widget.item.quantity < threshold;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final item = widget.item;
    final low = _isLowStock;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _expanded = !_expanded);
        },
        child: Padding(
          padding: const EdgeInsets.all(RadhaSpacing.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(RadhaRadii.radiusSm),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: 22,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: RadhaSpacing.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.inventoryProductShort(item.productId),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: RadhaSpacing.space2),
                        Row(
                          children: [
                            Text(
                              low
                                  ? l10n.inventoryBelowThreshold
                                  : l10n.inventoryInStock,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: low
                                    ? RadhaColors.warning
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (low) ...[
                              const SizedBox(width: RadhaSpacing.space8),
                              const _LowStockBadge(),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: RadhaSpacing.space12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${item.quantity}',
                        style: radhaMonoStyle(
                          fontSize: 22,
                          weight: FontWeight.w700,
                          color: low
                              ? RadhaColors.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        l10n.inventoryUnitsLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: RadhaSpacing.space12),
                Divider(height: 1, color: theme.colorScheme.outline),
                const SizedBox(height: RadhaSpacing.space12),
                _DetailLine(
                  label: l10n.inventoryTotalQuantity,
                  value: l10n.inventoryQtyUnits(item.quantity),
                ),
                if (item.lowStockThreshold != null)
                  _DetailLine(
                    label: l10n.inventoryLowStockThreshold,
                    value: l10n.inventoryQtyUnits(item.lowStockThreshold!),
                  ),
                const SizedBox(height: RadhaSpacing.space4),
                Text(
                  l10n.inventoryBatchLedgerHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Label/value line used in the expanded inventory detail.
class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: RadhaSpacing.space4),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Rose pill badge shown when stock is below the configured threshold.
/// Background sits at ~12% alpha of the danger token, label at 600 weight.
class _LowStockBadge extends StatelessWidget {
  const _LowStockBadge();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space8,
        vertical: RadhaSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: RadhaColors.danger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
      ),
      child: Text(
        l10n.inventoryLowStockBadge,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: RadhaColors.danger,
        ),
      ),
    );
  }
}

/// Skeleton list shown while the first inventory page loads.
class _InventorySkeleton extends StatelessWidget {
  const _InventorySkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        RadhaSpacing.space24,
        RadhaSpacing.space12,
        RadhaSpacing.space24,
        RadhaSpacing.space24,
      ),
      itemCount: 7,
      separatorBuilder: (_, _) => const SizedBox(height: RadhaSpacing.space12),
      itemBuilder: (_, _) => Container(
        height: 80,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
          border: Border.all(color: theme.colorScheme.outline),
        ),
      ),
    );
  }
}

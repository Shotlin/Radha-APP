import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/dto/inventory_dto.dart';
import '../../design/app_assets.dart';
import '../../design/tokens.dart';
import '../../design/widgets/mor_companion.dart';
import '../../l10n/generated/app_localizations.dart';
import 'stock_movement_screen.dart';

/// Provider that fetches the inventory list and filters down to items whose
/// quantity has dropped at or below their configured threshold.
///
/// Mirrors Requirement R18.4: an item is "in alert" when
/// `current_stock <= threshold`. The backend is the source of truth for
/// alert lifecycle; this is the read-side view consumed by the screen.
final lowStockAlertsProvider =
    FutureProvider.autoDispose<List<InventoryItemResponse>>((ref) async {
      final client = ref.watch(apiClientProvider);
      final data = await client.getInventory(limit: 200);
      return data.items
          .where(
            (i) =>
                i.lowStockThreshold != null &&
                i.quantity <= i.lowStockThreshold!,
          )
          .toList();
    });

/// Low-stock alerts screen.
///
/// Lists the active low-stock alerts for the current store with a quick
/// "Restock" action that drops the operator straight into Stock Movement
/// with the product pre-filled. Refreshing rebuilds against the latest
/// inventory snapshot.
class LowStockAlertsScreen extends ConsumerWidget {
  const LowStockAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final alertsAsync = ref.watch(lowStockAlertsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          l10n.lowStockTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: alertsAsync.when(
        loading: () => const _AlertsSkeleton(),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MorCompanion(
                mood: MorMood.concern,
                size: 96,
                semanticLabel: l10n.commonCouldNotLoad,
              ),
              const SizedBox(height: RadhaSpacing.space12),
              Text(l10n.lowStockLoadError, style: theme.textTheme.bodyLarge),
              const SizedBox(height: RadhaSpacing.space8),
              FilledButton(
                onPressed: () => ref.invalidate(lowStockAlertsProvider),
                child: Text(l10n.tryAgain),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 56,
                    color: RadhaColors.success,
                  ),
                  const SizedBox(height: RadhaSpacing.space12),
                  Text(
                    l10n.lowStockEmpty,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(lowStockAlertsProvider),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.all(RadhaSpacing.space20),
              itemCount: items.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: RadhaSpacing.space12),
              itemBuilder: (context, index) => _AlertTile(item: items[index]),
            ),
          );
        },
      ),
    );
  }
}

/// Single low-stock alert tile.
///
/// Surfaces the current quantity vs. threshold and offers a "Restock" CTA
/// that pushes the Stock Movement screen with the product pre-filled, so
/// the operator can record a stock-in without retyping the SKU.
class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.item});

  final InventoryItemResponse item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      child: Row(
        children: [
          // Warning glyph.
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: RadhaColors.danger.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: RadhaColors.danger,
              size: 20,
            ),
          ),
          const SizedBox(width: RadhaSpacing.space12),
          // Product info.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.inventoryProductShort(item.productId),
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: RadhaSpacing.space4),
                Text(
                  l10n.lowStockCurrentThreshold(
                    item.quantity,
                    item.lowStockThreshold ?? 0,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: RadhaSpacing.space8),
          // Restock CTA.
          SizedBox(
            height: kMinTouchTarget,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        StockMovementScreen(productId: item.productId),
                  ),
                );
              },
              child: Text(l10n.lowStockRestock),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton list shown while the alerts query resolves.
class _AlertsSkeleton extends StatelessWidget {
  const _AlertsSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.separated(
      padding: const EdgeInsets.all(RadhaSpacing.space20),
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(height: RadhaSpacing.space12),
      itemBuilder: (_, _) => Container(
        height: 76,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
          border: Border.all(color: theme.colorScheme.outline),
        ),
      ),
    );
  }
}

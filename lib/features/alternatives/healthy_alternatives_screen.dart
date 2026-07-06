// Healthy Alternatives screen (FE-22).
//
// Full-screen route mounted at `/alternatives/:ean`. Reads up to three
// healthier candidates for a source EAN from
// `GET /api/v1/products/:ean/alternatives` (BE-41) and renders them as
// vertical cards.
//
// Visual rules:
//   * One orange accent (#EA580C) — used only on the primary "View" CTA and the
//     healthy-score chip when the score lands in the green band.
//   * 80x80 rounded product image (`CachedNetworkImage`).
//   * Health-score chip uses the existing colored-pill convention from
//     `HealthLabelChip` (green = healthy, amber = moderate,
//     rose = unhealthy).
//   * Pull-to-refresh wired (`RefreshIndicator`).
//   * No purple/blue gradients, no centered hero, no 3-equal-card grids.
//   * 44pt+ touch targets on every action.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:radha_app/core/network/api_client.dart';
import 'package:radha_app/core/network/api_exception.dart';
import 'package:radha_app/core/network/dto/ai_dto.dart';
import 'package:radha_app/core/network/dto/misc_dto.dart';
import 'package:radha_app/core/network/error_codes.dart';
import 'package:radha_app/core/router/app_router.dart';
import 'package:radha_app/design/app_assets.dart';
import 'package:radha_app/design/tokens.dart';
import 'package:radha_app/design/widgets/mor_companion.dart';
import 'package:radha_app/features/product/widgets/health_label_chip.dart';
import 'package:radha_app/features/shopping_list/shopping_list_screen.dart';
import 'package:radha_app/l10n/generated/app_localizations.dart';

/// Provider for the source product's display data. Used so the header can
/// say "Better choices than [productName]"; falls back to a generic
/// header when the lookup fails or hasn't completed yet.
///
/// Calls `GET /products/lookup/{ean}` — `/products/ean/{ean}` (used here
/// previously) does not exist on the backend and 404'd unconditionally.
final _sourceProductNameProvider =
    FutureProvider.autoDispose.family<String?, String>((ref, ean) async {
      try {
        final client = ref.watch(apiClientProvider);
        final result = await client.getProductLookup(ean);
        return result.product?.name;
      } catch (_) {
        return null;
      }
    });

/// Per-EAN healthy alternatives provider. The `family` is keyed by source
/// EAN so multiple alternatives screens (one per scanned product) keep
/// their data independent.
final healthyAlternativesListProvider = FutureProvider.autoDispose
    .family<HealthyAlternativesResult, String>((ref, ean) async {
      final client = ref.watch(apiClientProvider);
      final list = await client.getHealthierAlternatives(ean);
      return HealthyAlternativesResult(sourceEan: ean, alternatives: list);
    });

/// Full-screen healthy alternatives surface mounted at
/// `/alternatives/:ean`.
class HealthyAlternativesScreen extends ConsumerWidget {
  const HealthyAlternativesScreen({super.key, required this.ean});

  /// Source EAN — the product the user is comparing against.
  final String ean;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final altAsync = ref.watch(healthyAlternativesListProvider(ean));
    final sourceNameAsync = ref.watch(_sourceProductNameProvider(ean));

    final headerTitle = sourceNameAsync.maybeWhen(
      data: (name) => name == null || name.isEmpty
          ? l10n.healthyAlternativesGenericTitle
          : l10n.healthyAlternativesTitle(name),
      orElse: () => l10n.healthyAlternativesGenericTitle,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          headerTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Drop both caches so the header and list re-fetch on pull.
            ref.invalidate(_sourceProductNameProvider(ean));
            ref.invalidate(healthyAlternativesListProvider(ean));
            await ref.read(healthyAlternativesListProvider(ean).future);
          },
          child: altAsync.when(
            loading: () => const _AlternativesLoading(),
            error: (error, stack) {
              final code = error is ApiException ? error.code : null;
              final message = userMessageForCode(
                code,
                l10n: l10n,
                fallback: l10n.errorGeneric,
              );
              return _AlternativesError(
                title: l10n.healthyAlternativesErrorTitle,
                body: message,
                retryLabel: l10n.tryAgain,
                onRetry: () =>
                    ref.invalidate(healthyAlternativesListProvider(ean)),
              );
            },
            data: (result) => _AlternativesBody(result: result),
          ),
        ),
      ),
    );
  }
}

// ─── Body ────────────────────────────────────────────────────────────────

class _AlternativesBody extends ConsumerWidget {
  const _AlternativesBody({required this.result});

  final HealthyAlternativesResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (result.alternatives.isEmpty) {
      // Empty state. AlwaysScrollable so RefreshIndicator can attach to
      // a scrollable surface even when there's nothing to render.
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.6,
            child: Padding(
              padding: const EdgeInsets.all(RadhaSpacing.space24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.healthyAlternativesEmptyTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: RadhaSpacing.space8),
                  Text(
                    l10n.healthyAlternativesEmptyBody,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(RadhaSpacing.space24),
      itemCount: result.alternatives.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: RadhaSpacing.space16),
      itemBuilder: (context, index) {
        final alt = result.alternatives[index];
        return _AlternativeCard(alternative: alt);
      },
    );
  }
}

// ─── Card ────────────────────────────────────────────────────────────────

class _AlternativeCard extends ConsumerStatefulWidget {
  const _AlternativeCard({required this.alternative});

  final HealthyAlternative alternative;

  @override
  ConsumerState<_AlternativeCard> createState() => _AlternativeCardState();
}

class _AlternativeCardState extends ConsumerState<_AlternativeCard> {
  bool _addingToList = false;

  Future<void> _addToShoppingList() async {
    if (_addingToList) return;
    setState(() => _addingToList = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      final client = ref.read(apiClientProvider);
      final listId = await ref.read(defaultShoppingListIdProvider.future);
      await client.addShoppingListItem(
        listId,
        ShoppingListItemDto(item: widget.alternative.name),
      );
      // Keep the shopping list in sync if it's currently mounted
      // somewhere in the route stack.
      ref.invalidate(shoppingListProvider);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.healthyAlternativesAddedToList),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.healthyAlternativesAddFailed),
        ),
      );
    } finally {
      if (mounted) setState(() => _addingToList = false);
    }
  }

  void _viewProduct() {
    final ean = widget.alternative.ean;
    if (ean.isEmpty) return;
    // Push the alternative as a normal scan-result so the consumer
    // sees full health detail and can save it from there.
    context.push('/scan/result/$ean');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final alt = widget.alternative;
    final price = alt.priceInr;

    return Container(
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductImage(url: alt.imageUrl),
              const SizedBox(width: RadhaSpacing.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alt.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (alt.brand.isNotEmpty) ...[
                      const SizedBox(height: RadhaSpacing.space4),
                      Text(
                        alt.brand,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: RadhaSpacing.space8),
                    Row(
                      children: [
                        HealthLabelChip(
                          label: '${alt.healthScore}/100',
                          level: _scoreLevel(alt.healthScore),
                        ),
                        if (price > 0) ...[
                          const SizedBox(width: RadhaSpacing.space12),
                          Text(
                            '₹${_formatPrice(price)}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: scheme.onSurface,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: RadhaSpacing.space16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: kMinTouchTarget,
                  child: OutlinedButton.icon(
                    onPressed: _addingToList ? null : _addToShoppingList,
                    icon: _addingToList
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_shopping_cart_outlined,
                            size: 18),
                    label: Text(l10n.healthyAlternativesAddToList),
                  ),
                ),
              ),
              const SizedBox(width: RadhaSpacing.space12),
              SizedBox(
                height: kMinTouchTarget,
                child: FilledButton(
                  onPressed: alt.ean.isEmpty ? null : _viewProduct,
                  child: Text(l10n.healthyAlternativesView),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = Container(
      width: 80,
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
      ),
      child: Icon(
        Icons.inventory_2_outlined,
        color: scheme.onSurfaceVariant,
        size: 32,
      ),
    );
    if (url.isEmpty) return placeholder;
    return ClipRRect(
      borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
      child: CachedNetworkImage(
        imageUrl: url,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        // Decode into the 80px box (≈2× for retina) instead of full-res —
        // keeps the alternatives list scroll buttery and memory low.
        memCacheWidth: 160,
        placeholder: (_, _) => placeholder,
        errorWidget: (_, _, _) => placeholder,
      ),
    );
  }
}

// ─── Loading state ───────────────────────────────────────────────────────

class _AlternativesLoading extends StatelessWidget {
  const _AlternativesLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(RadhaSpacing.space24),
      children: const [
        _CardSkeleton(),
        SizedBox(height: RadhaSpacing.space16),
        _CardSkeleton(),
      ],
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
            ),
          ),
          const SizedBox(width: RadhaSpacing.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 200,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(RadhaRadii.radiusSm),
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space8),
                Container(
                  height: 14,
                  width: 120,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(RadhaRadii.radiusSm),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error state ─────────────────────────────────────────────────────────

class _AlternativesError extends StatelessWidget {
  const _AlternativesError({
    required this.title,
    required this.body,
    required this.retryLabel,
    required this.onRetry,
  });

  final String title;
  final String body;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListView(
      // Need a scrollable so RefreshIndicator can engage.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(RadhaSpacing.space24),
      children: [
        MorCompanion(
          mood: MorMood.concern,
          size: 96,
          semanticLabel: AppLocalizations.of(context).commonCouldNotLoad,
        ),
        const SizedBox(height: RadhaSpacing.space16),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: RadhaSpacing.space8),
        Text(
          body,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: RadhaSpacing.space24),
        SizedBox(
          height: kMinTouchTarget,
          child: OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(retryLabel),
          ),
        ),
      ],
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────

/// Bands match the rest of the app (`HealthLabelChip`):
///   ≥ 70 healthy (green), 40–69 moderate (amber), < 40 unhealthy (rose).
HealthLevel _scoreLevel(int score) {
  if (score >= 70) return HealthLevel.healthy;
  if (score >= 40) return HealthLevel.moderate;
  return HealthLevel.unhealthy;
}

String _formatPrice(num value) {
  // No `intl` NumberFormat here because alternatives are already
  // server-priced; just guarantee at most two decimals.
  if (value == value.truncateToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(2);
}

// `AppRoute.alternatives` is referenced from product_detail_screen.dart;
// keep the unused import warning quiet by referencing it here so the
// router cross-link compiles even before the screens are wired up.
// ignore: unused_element
const _alternativesRoute = AppRoute.healthyAlternatives;

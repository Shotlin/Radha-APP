import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:radha_app/core/router/app_router.dart';
import 'package:radha_app/design/app_assets.dart';
import 'package:radha_app/design/tokens.dart';
import 'package:radha_app/design/widgets/brand_illustration.dart';
import 'package:radha_app/design/widgets/empty_state.dart';
import 'package:radha_app/design/widgets/error_state.dart';
import 'package:radha_app/design/widgets/skeleton_loader.dart';
import 'package:radha_app/features/catalog/catalog_health.dart';
import 'package:radha_app/features/home/data/home_catalog.dart';
import 'package:radha_app/l10n/generated/app_localizations.dart';

import 'providers/product_browse_providers.dart';

/// Browse the products in a single category — the "Shop by category" surface.
///
/// Offline-first + premium: the bundled launch catalog paints instantly, and
/// server `/catalog` rows (real health rating, health-sorted, cursor-paginated)
/// merge in when reachable. A health badge + veg dot ride each card; a sort
/// control + "Veg only" toggle sit under the title. Shimmer / branded-error /
/// honest-empty states throughout; a card tap opens the rich product detail.
class ProductBrowseScreen extends ConsumerStatefulWidget {
  const ProductBrowseScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  ConsumerState<ProductBrowseScreen> createState() =>
      _ProductBrowseScreenState();
}

class _ProductBrowseScreenState extends ConsumerState<ProductBrowseScreen> {
  final _scrollController = ScrollController();
  CatalogSort _sort = CatalogSort.health;
  bool _vegOnly = false;

  RadhaCategory get _category => kRadhaCategories.firstWhere(
    (c) => c.id == widget.categoryId,
    orElse: () => RadhaCategory(
      id: widget.categoryId,
      label: 'Products', // l10n-ignore: internal fallback; category titles localize via home_catalog (Phase 4)
      asset: '',
    ),
  );

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
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 240) {
      ref
          .read(categoryBrowseProvider((widget.categoryId, _sort)).notifier)
          .loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = _category;
    final categoryName = categoryLabel(
      AppLocalizations.of(context),
      category.id,
    );
    final args = (widget.categoryId, _sort);
    final browse = ref.watch(categoryBrowseProvider(args));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          categoryName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          _ControlBar(
            sort: _sort,
            vegOnly: _vegOnly,
            onSort: (s) {
              HapticFeedback.selectionClick();
              setState(() => _sort = s);
            },
            onVeg: (v) {
              HapticFeedback.selectionClick();
              setState(() => _vegOnly = v);
            },
          ),
          Expanded(
            child: browse.when(
              loading: () => const _ProductGridSkeleton(),
              error: (_, _) => Center(
                child: ErrorState(
                  title: AppLocalizations.of(context).browseLoadError,
                  body: AppLocalizations.of(
                    context,
                  ).browseLoadErrorBody(categoryName.toLowerCase()),
                  onRetry: () => ref.invalidate(categoryBrowseProvider(args)),
                ),
              ),
              data: (state) {
                final all = state.products;
                final items = _vegOnly
                    ? all.where((p) => p.isVeg != false).toList(growable: false)
                    : all;
                if (items.isEmpty) {
                  return _EmptyBody(
                    category: category,
                    vegOnly: _vegOnly,
                    onScan: () => context.go(AppRoute.scan),
                    onClearVeg: () => setState(() => _vegOnly = false),
                  );
                }
                return Column(
                  children: [
                    // Honest provenance: when the rows aren't live, say so and
                    // offer a retry — the bundled catalog still renders below.
                    if (state.source != CatalogSource.live)
                      _CatalogSourceBanner(
                        source: state.source,
                        onRetry: () =>
                            ref.invalidate(categoryBrowseProvider(args)),
                      ),
                    Expanded(
                      child: RefreshIndicator(
                        color: RadhaColors.primary,
                        onRefresh: () async =>
                            ref.invalidate(categoryBrowseProvider(args)),
                        child: GridView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.all(RadhaSpacing.space20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.66,
                                crossAxisSpacing: RadhaSpacing.space12,
                                mainAxisSpacing: RadhaSpacing.space12,
                              ),
                          // +1 trailing cell for the load-more footer.
                          itemCount: items.length + (state.loadingMore ? 2 : 0),
                          itemBuilder: (context, i) {
                            if (i >= items.length) {
                              return const _LoadingMoreCell();
                            }
                            return RepaintBoundary(
                              child: _ProductCard(product: items[i]),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Catalog source banner (honest offline / unavailable cue) ──────────────

/// A slim, non-blocking strip shown above the grid when the visible rows are
/// the bundled catalog rather than live server data. Communicates *why* (icon +
/// text, never colour-alone) and offers a retry. The grid stays usable below.
class _CatalogSourceBanner extends StatelessWidget {
  const _CatalogSourceBanner({required this.source, required this.onRetry});

  final CatalogSource source;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final offline = source == CatalogSource.offline;
    final tone = offline ? RadhaColors.complement : RadhaColors.warning;
    final icon = offline
        ? Icons.cloud_off_rounded
        : Icons.error_outline_rounded;
    final message = offline
        ? 'Offline — showing your saved catalog'
        : 'Live catalog unavailable — showing saved catalog';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        RadhaSpacing.space20,
        0,
        RadhaSpacing.space20,
        RadhaSpacing.space8,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space12,
        vertical: RadhaSpacing.space8,
      ),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        border: Border.all(color: tone.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: tone),
          const SizedBox(width: RadhaSpacing.space8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: tone,
              minimumSize: const Size(0, kMinTouchTarget),
              padding: const EdgeInsets.symmetric(
                horizontal: RadhaSpacing.space8,
              ),
            ),
            child: Text(AppLocalizations.of(context).tryAgain),
          ),
        ],
      ),
    );
  }
}

// ─── Control bar (sort + veg) ──────────────────────────────────────────────

class _ControlBar extends StatelessWidget {
  const _ControlBar({
    required this.sort,
    required this.vegOnly,
    required this.onSort,
    required this.onVeg,
  });

  final CatalogSort sort;
  final bool vegOnly;
  final ValueChanged<CatalogSort> onSort;
  final ValueChanged<bool> onVeg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        RadhaSpacing.space20,
        RadhaSpacing.space4,
        RadhaSpacing.space20,
        RadhaSpacing.space12,
      ),
      child: Row(
        children: [
          // Sort segmented control.
          Expanded(
            child: SegmentedButton<CatalogSort>(
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStatePropertyAll(theme.textTheme.labelLarge),
              ),
              segments: [
                ButtonSegment(
                  value: CatalogSort.health,
                  label: Text(AppLocalizations.of(context).browseSortHealthiest),
                  icon: const Icon(Icons.favorite_rounded, size: 16),
                ),
                ButtonSegment(
                  value: CatalogSort.name,
                  label: Text(AppLocalizations.of(context).browseSortAZ),
                  icon: const Icon(Icons.sort_by_alpha_rounded, size: 16),
                ),
              ],
              selected: {sort},
              showSelectedIcon: false,
              onSelectionChanged: (s) => onSort(s.first),
            ),
          ),
          const SizedBox(width: RadhaSpacing.space12),
          // Veg-only toggle (recognisable green dot).
          _VegToggle(value: vegOnly, onChanged: onVeg),
        ],
      ),
    );
  }
}

class _VegToggle extends StatelessWidget {
  const _VegToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.browseFilterVegOnly,
      toggled: value,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
        onTap: () => onChanged(!value),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: RadhaSpacing.space12),
          decoration: BoxDecoration(
            color: value
                ? RadhaColors.success.withValues(alpha: 0.12)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
            border: Border.all(
              color: value ? RadhaColors.success : theme.colorScheme.outline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const VegDot(isVeg: true, size: 14),
              const SizedBox(width: RadhaSpacing.space8),
              Text(
                l10n.browseVeg,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: value
                      ? RadhaColors.success
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Product card ──────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final BrowseProduct product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);

    return Material(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          context.push(
            '${AppRoute.catalogProductBase}/${product.routeKey}',
            extra: product,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + overlays.
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: _ProductImage(
                    assetImage: product.assetImage,
                    networkImage: product.networkImage,
                    name: product.name,
                    cacheWidth: (200 * dpr).round(),
                  ),
                ),
                if (product.healthGrade != null || product.healthScore != null)
                  Positioned(
                    top: RadhaSpacing.space8,
                    left: RadhaSpacing.space8,
                    child: HealthRatingPill(
                      grade: product.healthGrade,
                      score: product.healthScore,
                    ),
                  ),
                if (product.isVeg != null)
                  Positioned(
                    top: RadhaSpacing.space8,
                    right: RadhaSpacing.space8,
                    child: VegDot(isVeg: product.isVeg!),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(RadhaSpacing.space12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        if (product.brand != null &&
                            product.brand!.isNotEmpty) ...[
                          Flexible(
                            child: Text(
                              product.brand!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                        if (product.netWeight != null) ...[
                          if (product.brand != null &&
                              product.brand!.isNotEmpty)
                            Text(
                              '  ·  ',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          Text(
                            product.netWeight!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Product image: bundled asset preferred (offline/premium), else network, else
/// a calm name-first placeholder — never a broken-image glyph. Product shots sit
/// `contain` on a light tile so nothing is cropped.
class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.assetImage,
    required this.networkImage,
    required this.name,
    required this.cacheWidth,
  });

  final String? assetImage;
  final String? networkImage;
  final String name;
  final int cacheWidth;

  @override
  Widget build(BuildContext context) {
    final asset = assetImage;
    final url = networkImage;
    Widget child;
    if (asset != null && asset.isNotEmpty) {
      child = Image.asset(
        asset,
        fit: BoxFit.contain,
        cacheWidth: cacheWidth,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, _, _) => _Placeholder(name: name),
      );
    } else if (url != null && url.isNotEmpty) {
      child = CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.contain,
        memCacheWidth: cacheWidth,
        placeholder: (_, _) => const SkeletonLoader(
          width: double.infinity,
          height: double.infinity,
          radius: 0,
        ),
        errorWidget: (_, _, _) => _Placeholder(name: name),
      );
    } else {
      return _Placeholder(name: name);
    }
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(RadhaSpacing.space8),
        child: child,
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(RadhaSpacing.space12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 24,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: RadhaSpacing.space8),
              Text(
                name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty / loading-more ──────────────────────────────────────────────────

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({
    required this.category,
    required this.vegOnly,
    required this.onScan,
    required this.onClearVeg,
  });

  final RadhaCategory category;
  final bool vegOnly;
  final VoidCallback onScan;
  final VoidCallback onClearVeg;

  @override
  Widget build(BuildContext context) {
    if (vegOnly) {
      return Center(
        child: EmptyState(
          illustration: const BrandIllustration(
            RadhaAssets.stateNoResults,
            size: 150,
          ),
          icon: Icons.eco_outlined,
          title: AppLocalizations.of(context).browseEmptyVeg,
          body: AppLocalizations.of(context).browseEmptyVegBody(
            categoryLabel(
              AppLocalizations.of(context),
              category.id,
            ).toLowerCase(),
          ),
          actionLabel: AppLocalizations.of(context).browseShowAll,
          actionIcon: Icons.clear_rounded,
          onAction: onClearVeg,
        ),
      );
    }
    return Center(
      child: EmptyState(
        illustration: const BrandIllustration(
          RadhaAssets.stateEmptyList,
          size: 150,
        ),
        icon: Icons.inventory_2_outlined,
        title: AppLocalizations.of(context).browseEmpty,
        body: AppLocalizations.of(context).browseEmptyBody(
          categoryLabel(
            AppLocalizations.of(context),
            category.id,
          ).toLowerCase(),
        ),
        actionLabel: AppLocalizations.of(context).scanProduct,
        actionIcon: Icons.qr_code_scanner_rounded,
        onAction: onScan,
      ),
    );
  }
}

class _LoadingMoreCell extends StatelessWidget {
  const _LoadingMoreCell();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: RadhaColors.primary,
        ),
      ),
    );
  }
}

class _ProductGridSkeleton extends StatelessWidget {
  const _ProductGridSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GridView.builder(
      padding: const EdgeInsets.all(RadhaSpacing.space20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.66,
        crossAxisSpacing: RadhaSpacing.space12,
        mainAxisSpacing: RadhaSpacing.space12,
      ),
      itemCount: 6,
      itemBuilder: (_, _) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: SkeletonLoader(
                width: double.infinity,
                height: double.infinity,
                radius: 0,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(RadhaSpacing.space12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(width: double.infinity, height: 12),
                  SizedBox(height: RadhaSpacing.space8),
                  SkeletonLoader(width: 60, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

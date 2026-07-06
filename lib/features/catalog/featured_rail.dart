import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:radha_app/core/router/app_router.dart';
import 'package:radha_app/design/tokens.dart';
import 'package:radha_app/design/widgets/skeleton_loader.dart';
import 'package:radha_app/features/catalog/catalog_health.dart';
import 'package:radha_app/features/catalog/providers/product_browse_providers.dart';

/// Consumer-home "Featured products" rail — the browse-flow doorway.
///
/// Horizontally scrolls real top-rated products (health-sorted from `/catalog`)
/// once the catalog is seeded, padded with curated launch products so it's
/// populated offline / day one. A tap opens the rich product detail. Honest:
/// the health pill shows only where a real rating exists.
class FeaturedProductsRail extends ConsumerWidget {
  const FeaturedProductsRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(featuredProductsProvider);

    // "Healthy picks" is an honest claim only once the rail actually carries
    // real health ratings (i.e. the catalog is seeded); offline / day-one it's
    // simply "Featured products" — never a health claim on unrated items.
    final hasRatings =
        async.valueOrNull?.any(
          (p) => p.healthGrade != null || p.healthScore != null,
        ) ??
        false;
    final title = hasRatings ? 'Healthy picks' : 'Featured products';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: RadhaSpacing.space12),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(
          height: 196,
          child: async.when(
            loading: () => const _RailSkeleton(),
            error: (_, _) => const SizedBox.shrink(),
            data: (items) {
              if (items.isEmpty) return const SizedBox.shrink();
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: RadhaSpacing.space12),
                itemBuilder: (context, i) =>
                    RepaintBoundary(child: _FeaturedCard(product: items[i])),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.product});

  final BrowseProduct product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);

    return SizedBox(
      width: 144,
      child: Material(
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
              Stack(
                children: [
                  SizedBox(
                    height: 112,
                    width: double.infinity,
                    child: _Image(
                      assetImage: product.assetImage,
                      networkImage: product.networkImage,
                      cacheWidth: (144 * dpr).round(),
                    ),
                  ),
                  if (product.healthGrade != null ||
                      product.healthScore != null)
                    Positioned(
                      top: RadhaSpacing.space8,
                      left: RadhaSpacing.space8,
                      child: HealthRatingPill(
                        grade: product.healthGrade,
                        score: product.healthScore,
                      ),
                    ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(RadhaSpacing.space8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                      const Spacer(),
                      if (product.brand != null && product.brand!.isNotEmpty)
                        Text(
                          product.brand!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
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

class _Image extends StatelessWidget {
  const _Image({
    required this.assetImage,
    required this.networkImage,
    required this.cacheWidth,
  });

  final String? assetImage;
  final String? networkImage;
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
        errorBuilder: (_, _, _) => const _ImgFallback(),
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
        errorWidget: (_, _, _) => const _ImgFallback(),
      );
    } else {
      return const _ImgFallback();
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

class _ImgFallback extends StatelessWidget {
  const _ImgFallback();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 22,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _RailSkeleton extends StatelessWidget {
  const _RailSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(width: RadhaSpacing.space12),
      itemBuilder: (_, _) => Container(
        width: 144,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 112,
              width: double.infinity,
              child: SkeletonLoader(
                width: double.infinity,
                height: double.infinity,
                radius: 0,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(RadhaSpacing.space8),
              child: SkeletonLoader(width: 100, height: 12),
            ),
          ],
        ),
      ),
    );
  }
}

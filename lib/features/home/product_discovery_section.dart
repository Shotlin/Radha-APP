import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:radha_app/core/router/app_router.dart';
import 'package:radha_app/design/tokens.dart';
import 'package:radha_app/design/widgets/branded_image.dart';
import 'package:radha_app/features/catalog/catalog_search_screen.dart';
import 'package:radha_app/features/catalog/featured_rail.dart';
import 'package:radha_app/l10n/generated/app_localizations.dart';

import 'data/home_catalog.dart';

/// "Find products" block on the single (business) Home.
///
/// This is what used to live in the separate personal/consumer home: product
/// search, browse-by-category, featured products and the scan / recall
/// shortcuts. Scanning and product information are available on every plan
/// (including Free); the recall shortcut opens a screen that is itself
/// plan-gated by `LockedFeature`.
class ProductDiscoverySection extends StatelessWidget {
  const ProductDiscoverySection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeShopByCategory,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: RadhaSpacing.space12),
        const CatalogSearchBar(),
        const SizedBox(height: RadhaSpacing.space16),
        SizedBox(
          height: 112,
          child: RepaintBoundary(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              padding: EdgeInsets.zero,
              itemCount: kRadhaCategories.length,
              separatorBuilder: (_, _) => const SizedBox(width: RadhaSpacing.space12),
              itemBuilder: (context, i) => _CategoryTile(category: kRadhaCategories[i]),
            ),
          ),
        ),
        const SizedBox(height: RadhaSpacing.space16),
        const FeaturedProductsRail(),
        const SizedBox(height: RadhaSpacing.space16),
        _ShortcutCard(
          icon: Icons.qr_code_scanner_rounded,
          title: l10n.homeScanBarcodeTitle,
          body: l10n.homeScanBarcodeBody,
          onTap: () => context.go(AppRoute.scan),
        ),
        const SizedBox(height: RadhaSpacing.space8),
        _ShortcutCard(
          icon: Icons.shield_outlined,
          title: l10n.homeRecallTitle,
          body: l10n.homeRecallBody,
          onTap: () => context.push(AppRoute.recallAlerts),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final RadhaCategory category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final label = categoryLabel(l10n, category.id);
    final cacheW = (64 * MediaQuery.devicePixelRatioOf(context)).round();
    return InkWell(
      borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
      onTap: () {
        HapticFeedback.selectionClick();
        context.push('/catalog/${category.id}');
      },
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: BrandedImage(
                asset: category.asset,
                cacheWidth: cacheW,
                label: label,
                fallbackIcon: Icons.category_outlined,
              ),
            ),
            const SizedBox(height: RadhaSpacing.space8),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(RadhaSpacing.space16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: RadhaColors.primaryTint,
                  borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 28, color: RadhaColors.primaryDeep),
              ),
              const SizedBox(width: RadhaSpacing.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: RadhaSpacing.space2),
                    Text(
                      body,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: RadhaSpacing.space8),
              Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

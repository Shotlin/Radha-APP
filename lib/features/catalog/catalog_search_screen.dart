import 'dart:async';

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
import 'package:radha_app/design/widgets/skeleton_loader.dart';
import 'package:radha_app/features/catalog/catalog_health.dart';
import 'package:radha_app/l10n/generated/app_localizations.dart';
import 'package:radha_app/features/catalog/providers/product_browse_providers.dart';

/// Tappable "Search products…" pill for the consumer home — the search entry
/// point. Opens [CatalogSearchScreen]. Kept here so the home only adds one line.
class CatalogSearchBar extends StatelessWidget {
  const CatalogSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          context.push(AppRoute.catalogSearch);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: RadhaSpacing.space16,
            vertical: RadhaSpacing.space12,
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                size: 22,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: RadhaSpacing.space12),
              Text(
                AppLocalizations.of(context).catalogSearchBarLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
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

/// Full-screen product search across the catalog (offline launch matches +
/// server `/catalog?q=`). Debounced input; designed type-to-search / empty /
/// loading states; a tap opens the rich product detail.
class CatalogSearchScreen extends ConsumerStatefulWidget {
  const CatalogSearchScreen({super.key});

  @override
  ConsumerState<CatalogSearchScreen> createState() =>
      _CatalogSearchScreenState();
}

class _CatalogSearchScreenState extends ConsumerState<CatalogSearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _query = value.trim());
    });
  }

  void _clear() {
    _controller.clear();
    _debounce?.cancel();
    setState(() => _query = '');
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final results = ref.watch(catalogSearchProvider(_query));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          focusNode: _focus,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: _onChanged,
          style: theme.textTheme.titleMedium,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).catalogSearchHint,
            border: InputBorder.none,
            hintStyle: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              tooltip: AppLocalizations.of(context).commonClear,
              icon: const Icon(Icons.close_rounded),
              onPressed: _clear,
            ),
        ],
      ),
      body: _query.length < 2
          ? const _SearchPrompt()
          : results.when(
              loading: () => const _ResultsSkeleton(),
              error: (_, _) => const _SearchPrompt(),
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: EmptyState(
                      illustration: const BrandIllustration(
                        RadhaAssets.stateNoResults,
                        size: 160,
                      ),
                      title: AppLocalizations.of(context).catalogNoMatches,
                      body: AppLocalizations.of(
                        context,
                      ).catalogNoMatchesBody(_query),
                      actionLabel: AppLocalizations.of(context).scanProduct,
                      actionIcon: Icons.qr_code_scanner_rounded,
                      onAction: () => context.go(AppRoute.scan),
                    ),
                  );
                }
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: RadhaSpacing.space8,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    indent: 84,
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  itemBuilder: (context, i) => _ResultTile(product: items[i]),
                );
              },
            ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.product});

  final BrowseProduct product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        context.push(
          '${AppRoute.catalogProductBase}/${product.routeKey}',
          extra: product,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: RadhaSpacing.space20,
          vertical: RadhaSpacing.space12,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
              child: SizedBox(
                width: 52,
                height: 52,
                child: _Thumb(
                  assetImage: product.assetImage,
                  networkImage: product.networkImage,
                  cacheWidth: (52 * dpr).round(),
                ),
              ),
            ),
            const SizedBox(width: RadhaSpacing.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (product.brand != null && product.brand!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      product.brand!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (product.isVeg != null) ...[
              VegDot(isVeg: product.isVeg!),
              const SizedBox(width: RadhaSpacing.space8),
            ],
            if (product.healthGrade != null || product.healthScore != null) ...[
              HealthRatingPill(
                grade: product.healthGrade,
                score: product.healthScore,
              ),
              const SizedBox(width: RadhaSpacing.space8),
            ],
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.assetImage,
    required this.networkImage,
    required this.cacheWidth,
  });

  final String? assetImage;
  final String? networkImage;
  final int cacheWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asset = assetImage;
    final url = networkImage;
    Widget child;
    if (asset != null && asset.isNotEmpty) {
      child = Image.asset(
        asset,
        fit: BoxFit.contain,
        cacheWidth: cacheWidth,
        errorBuilder: (_, _, _) => _fallback(theme),
      );
    } else if (url != null && url.isNotEmpty) {
      child = CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.contain,
        memCacheWidth: cacheWidth,
        errorWidget: (_, _, _) => _fallback(theme),
      );
    } else {
      return _fallback(theme);
    }
    return ColoredBox(
      color: Colors.white,
      child: Padding(padding: const EdgeInsets.all(4), child: child),
    );
  }

  Widget _fallback(ThemeData theme) => ColoredBox(
    color: theme.colorScheme.surfaceContainerHighest,
    child: Icon(
      Icons.inventory_2_outlined,
      size: 20,
      color: theme.colorScheme.onSurfaceVariant,
    ),
  );
}

class _SearchPrompt extends StatelessWidget {
  const _SearchPrompt();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RadhaSpacing.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandIllustration(RadhaAssets.morSceneSearch, size: 132),
            const SizedBox(height: RadhaSpacing.space16),
            Text(
              AppLocalizations.of(context).catalogSearchPromptTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: RadhaSpacing.space8),
            Text(
              AppLocalizations.of(context).catalogSearchPromptBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsSkeleton extends StatelessWidget {
  const _ResultsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: RadhaSpacing.space8),
      itemCount: 8,
      itemBuilder: (_, _) => const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: RadhaSpacing.space20,
          vertical: RadhaSpacing.space12,
        ),
        child: Row(
          children: [
            SkeletonLoader(width: 52, height: 52),
            SizedBox(width: RadhaSpacing.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(width: 160, height: 12),
                  SizedBox(height: RadhaSpacing.space8),
                  SkeletonLoader(width: 90, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

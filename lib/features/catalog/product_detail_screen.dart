import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:radha_app/core/auth/auth_controller.dart';
import 'package:radha_app/core/entitlements/entitlement_provider.dart';
import 'package:radha_app/core/network/api_client.dart';
import 'package:radha_app/core/network/dto/misc_dto.dart';
import 'package:radha_app/core/network/dto/product_lookup_dto.dart';
import 'package:radha_app/core/network/dto/saved_product_dto.dart';
import 'package:radha_app/core/router/app_router.dart';
import 'package:radha_app/design/app_assets.dart';
import 'package:radha_app/design/tokens.dart';
import 'package:radha_app/design/widgets/brand_illustration.dart';
import 'package:radha_app/design/widgets/mor_companion.dart';
import 'package:radha_app/features/allergen/allergen_profile_screen.dart';
import 'package:radha_app/features/catalog/catalog_health.dart';
import 'package:radha_app/features/catalog/data/launch_catalog.dart';
import 'package:radha_app/features/catalog/providers/product_browse_providers.dart';
import 'package:radha_app/l10n/generated/app_localizations.dart';

// ─── Providers ──────────────────────────────────────────────────────────────

/// Real nutrition lookup by EAN (drives the free nutrient panels).
final _lookupProvider = FutureProvider.autoDispose
    .family<ProductLookupResult, String>((ref, ean) async {
      final client = ref.read(apiClientProvider);
      return client.getProductLookup(ean, includeNutrition: true);
    });

/// Plus — AI ingredient deep-dive (gated). Keyed by the catalog product id.
final _ingredientExplainProvider = FutureProvider.autoDispose
    .family<IngredientExplainerResponse, String>((ref, productId) async {
      final client = ref.read(apiClientProvider);
      return client.explainIngredients({'productId': productId});
    });

/// Plus — allergens on this product (gated, "For You" match).
final _productAllergensProvider = FutureProvider.autoDispose
    .family<List<AllergenResponse>, String>((ref, productId) async {
      final client = ref.read(apiClientProvider);
      return client.getProductAllergens(productId);
    });

// ─── Screen ───────────────────────────────────────────────────────────────

/// Rich product detail for the browse flow — the retention centrepiece.
///
/// Free users get genuine value (real RADHA health rating, key nutrients, the
/// full per-100g/50g nutrient table). RADHA Plus unlocks the deep layer
/// (ingredient deep-dive, additives, personalised "For You" flags), shown to
/// free users as a tasteful locked preview. Health/nutrition are always real —
/// when a product has no data yet, an honest "Scan to unlock" card drives the
/// scanner rather than inventing numbers.
class CatalogProductDetailScreen extends ConsumerStatefulWidget {
  const CatalogProductDetailScreen({
    super.key,
    required this.routeKey,
    this.initial,
  });

  /// Real EAN when known, else the launch-catalog slug.
  final String routeKey;

  /// Optional product passed from the browse grid (avoids a refetch and
  /// carries the real health rating from the catalog list).
  final BrowseProduct? initial;

  @override
  ConsumerState<CatalogProductDetailScreen> createState() =>
      _CatalogProductDetailScreenState();
}

class _CatalogProductDetailScreenState
    extends ConsumerState<CatalogProductDetailScreen> {
  String? _wouldBuy; // 'yes' | 'no' | 'bought'
  bool _saving = false;
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ── Resolve identity (extra → launch manifest → route key) ──────────────
    final initial = widget.initial;
    final launch =
        launchProductBySlug(widget.routeKey) ??
        launchProductByEan(widget.routeKey);
    final name = initial?.name ?? launch?.name ?? 'Product';
    final brand = initial?.brand ?? launch?.brand;
    final weight = initial?.netWeight ?? launch?.netWeight;
    final assetImg = initial?.assetImage ?? launch?.asset;
    final netImg = initial?.networkImage;
    final isVeg =
        initial?.isVeg ?? (launch != null ? vegStatusForLaunch(launch) : null);
    final grade = initial?.healthGrade;
    final score = initial?.healthScore;
    final ean =
        initial?.ean ??
        launch?.ean ??
        (_looksLikeEan(widget.routeKey) ? widget.routeKey : null);

    final lookupAsync = ean != null ? ref.watch(_lookupProvider(ean)) : null;
    final lookupItem = lookupAsync?.valueOrNull?.product;
    final nutrition = lookupItem?.nutrition;
    final productId = lookupItem?.id;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          AppLocalizations.of(context).productDetailTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context).commonShare,
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: () => _share(name, grade: grade, score: score),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          RadhaSpacing.space16,
          RadhaSpacing.space8,
          RadhaSpacing.space16,
          RadhaSpacing.space48,
        ),
        children: [
          _Header(
            name: name,
            brand: brand,
            netWeight: weight,
            assetImage: assetImg,
            networkImage: netImg,
            isVeg: isVeg,
            saving: _saving,
            saved: _saved,
            onSave: () => _toggleSave(name, ean, productId),
          ),
          const SizedBox(height: RadhaSpacing.space20),

          // ── Health rating (real) or honest pending ───────────────────────
          _HealthRatingCard(grade: grade, score: score, hasEan: ean != null),
          const SizedBox(height: RadhaSpacing.space16),

          // ── Real nutrition: like / concern + key nutrients ───────────────
          if (lookupAsync != null)
            lookupAsync.when(
              loading: () => const _NutritionSkeleton(),
              error: (_, _) => const SizedBox.shrink(),
              data: (_) {
                if (nutrition == null || !nutrition.hasAnyValue) {
                  return _ScanToUnlock(
                    onScan: () => context.push(AppRoute.scan),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LikeConcern(nutrition: nutrition),
                    const SizedBox(height: RadhaSpacing.space16),
                    _KeyNutrients(
                      nutrition: nutrition,
                      onAllNutrients: () =>
                          _showAllNutrients(context, name, nutrition),
                    ),
                  ],
                );
              },
            )
          else
            _ScanToUnlock(onScan: () => context.push(AppRoute.scan)),
          const SizedBox(height: RadhaSpacing.space24),

          // ── RADHA Plus — deep dive (gated) ───────────────────────────────
          const _PlusHeader(),
          const SizedBox(height: RadhaSpacing.space12),
          _IngredientDeepDive(productId: productId),
          const SizedBox(height: RadhaSpacing.space12),
          _ForYouSection(productId: productId),
          const SizedBox(height: RadhaSpacing.space24),

          // ── Better choice (reuse the dedicated alternatives screen) ──────
          if (ean != null)
            _NavRow(
              icon: Icons.compare_arrows_rounded,
              label: AppLocalizations.of(context).productSeeHealthierOptions,
              onTap: () => context.push('/alternatives/$ean'),
            ),
          const SizedBox(height: RadhaSpacing.space24),

          // ── Would you buy this? (engagement) ─────────────────────────────
          _WouldYouBuy(
            choice: _wouldBuy,
            onChoice: (c) {
              HapticFeedback.selectionClick();
              setState(() => _wouldBuy = c);
            },
          ),
        ],
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  bool _looksLikeEan(String s) =>
      s.length >= 8 && s.length <= 14 && int.tryParse(s) != null;

  Future<void> _toggleSave(String name, String? ean, String? productId) async {
    if (_saving) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    HapticFeedback.selectionClick();
    setState(() => _saving = true);
    try {
      await ref
          .read(apiClientProvider)
          .createSavedProduct(
            CreateSavedProductDto(
              productName: name,
              barcode: ean,
              productId: productId,
            ),
          );
      if (!mounted) return;
      setState(() {
        _saved = true;
        _saving = false;
      });
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.productDetailSavedAlert)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.productDetailSaveError)),
      );
    }
  }

  void _share(String name, {String? grade, num? score}) {
    final l10n = AppLocalizations.of(context);
    final five = healthOutOfFive(grade: grade, score: score);
    final text = five != null
        ? l10n.productDetailShareTextRated(
            name,
            five.toStringAsFixed(1),
            healthLabel(grade: grade, score: score),
          )
        : l10n.productDetailShareText(name);
    Share.share(text);
  }

  void _showAllNutrients(
    BuildContext context,
    String name,
    ProductNutrition nutrition,
  ) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(RadhaRadii.radiusLg),
        ),
      ),
      builder: (_) => _AllNutrientsSheet(name: name, nutrition: nutrition),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.brand,
    required this.netWeight,
    required this.assetImage,
    required this.networkImage,
    required this.isVeg,
    required this.saving,
    required this.saved,
    required this.onSave,
  });

  final String name;
  final String? brand;
  final String? netWeight;
  final String? assetImage;
  final String? networkImage;
  final bool? isVeg;
  final bool saving;
  final bool saved;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pack-shot.
        ClipRRect(
          borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
          child: Container(
            width: 116,
            height: 116,
            color: Colors.white,
            padding: const EdgeInsets.all(RadhaSpacing.space8),
            child: _Image(assetImage: assetImage, networkImage: networkImage),
          ),
        ),
        const SizedBox(width: RadhaSpacing.space16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ),
                  _SaveHeart(saving: saving, saved: saved, onTap: onSave),
                ],
              ),
              if (brand != null && brand!.isNotEmpty) ...[
                const SizedBox(height: RadhaSpacing.space4),
                Text(
                  brand!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: RadhaSpacing.space8),
              Row(
                children: [
                  if (isVeg != null) ...[
                    VegDot(isVeg: isVeg!),
                    const SizedBox(width: RadhaSpacing.space8),
                  ],
                  if (netWeight != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: RadhaSpacing.space8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(
                          RadhaRadii.radiusFull,
                        ),
                      ),
                      child: Text(
                        netWeight!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SaveHeart extends StatelessWidget {
  const _SaveHeart({
    required this.saving,
    required this.saved,
    required this.onTap,
  });

  final bool saving;
  final bool saved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: saved
          ? AppLocalizations.of(context).productDetailSaved
          : AppLocalizations.of(context).productDetailSave,
      onPressed: (saving || saved) ? null : onTap,
      icon: saving
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: RadhaColors.primary,
              ),
            )
          : Icon(
              saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: saved ? RadhaColors.primary : null,
            ),
    );
  }
}

class _Image extends StatelessWidget {
  const _Image({required this.assetImage, required this.networkImage});

  final String? assetImage;
  final String? networkImage;

  @override
  Widget build(BuildContext context) {
    if (assetImage != null && assetImage!.isNotEmpty) {
      return Image.asset(
        assetImage!,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const _ImgFallback(),
      );
    }
    if (networkImage != null && networkImage!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: networkImage!,
        fit: BoxFit.contain,
        errorWidget: (_, _, _) => const _ImgFallback(),
      );
    }
    return const _ImgFallback();
  }
}

class _ImgFallback extends StatelessWidget {
  const _ImgFallback();
  @override
  Widget build(BuildContext context) => const Center(
    child: Icon(
      Icons.inventory_2_outlined,
      size: 32,
      color: RadhaColors.inkMuted,
    ),
  );
}

// ─── Health rating card ─────────────────────────────────────────────────────

class _HealthRatingCard extends StatelessWidget {
  const _HealthRatingCard({
    required this.grade,
    required this.score,
    required this.hasEan,
  });

  final String? grade;
  final num? score;
  final bool hasEan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final five = healthOutOfFive(grade: grade, score: score);
    final color = healthColor(grade: grade, score: score);

    if (five == null) {
      // Honest "not rated yet" — never a fabricated score.
      return Container(
        padding: const EdgeInsets.all(RadhaSpacing.space16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        ),
        child: Row(
          children: [
            const MorCompanion(mood: MorMood.greet, size: 56),
            const SizedBox(width: RadhaSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).productDetailHealthNotRated,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: RadhaSpacing.space4),
                  Text(
                    AppLocalizations.of(context)
                        .productDetailHealthNotRatedBody,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          MorCompanion(mood: _morFor(five), size: 56),
          const SizedBox(width: RadhaSpacing.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).productDetailHealthLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      five.toStringAsFixed(1),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                    Text(
                      ' / 5',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: RadhaSpacing.space8),
                    Text(
                      healthLabel(grade: grade, score: score),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: RadhaSpacing.space8),
                _RatingBar(five: five, color: color),
              ],
            ),
          ),
        ],
      ),
    );
  }

  MorMood _morFor(double five) {
    if (five >= 3.5) return MorMood.celebrate;
    if (five >= 2.0) return MorMood.think;
    return MorMood.concern;
  }
}

class _RatingBar extends StatelessWidget {
  const _RatingBar({required this.five, required this.color});
  final double five;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
      child: LinearProgressIndicator(
        value: (five / 5).clamp(0, 1),
        minHeight: 8,
        backgroundColor: color.withValues(alpha: 0.15),
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}

// ─── Like / Concern (derived from REAL nutrient values) ─────────────────────

class _LikeConcern extends StatelessWidget {
  const _LikeConcern({required this.nutrition});
  final ProductNutrition nutrition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    // (label, illustrated-badge asset) — derived from REAL nutrient values.
    final likes = <(String, String?)>[];
    final concerns = <(String, String?)>[];
    final n = nutrition;
    if ((n.protein ?? 0) >= 8) {
      likes.add((l10n.productDetailHighProtein, RadhaAssets.hiProteinGood));
    }
    if ((n.fiber ?? 0) >= 3) {
      likes.add((l10n.productDetailGoodFibre, RadhaAssets.hiFiberGood));
    }
    if (n.isMinimallyProcessed) {
      likes.add((l10n.productDetailMinimallyProcessed, null));
    }
    if ((n.sugars ?? 0) >= 15) {
      concerns.add((l10n.productDetailHighSugar, RadhaAssets.hiSugarHigh));
    }
    if ((n.saturatedFat ?? 0) >= 5) {
      concerns.add((l10n.productDetailHighSatFat, RadhaAssets.hiFatHigh));
    }
    if ((n.sodium ?? 0) >= 0.6) {
      concerns.add((l10n.productDetailHighSodium, RadhaAssets.hiSodiumHigh));
    }
    if (n.isUltraProcessed) {
      concerns.add(
        (l10n.productDetailUltraProcessed, RadhaAssets.hiUltraProcessed),
      );
    }

    if (likes.isEmpty && concerns.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (likes.isNotEmpty) ...[
          _MiniHeading(
            icon: Icons.thumb_up_alt_rounded,
            color: RadhaColors.success,
            label: AppLocalizations.of(context).productDetailWhatYoullLike,
          ),
          const SizedBox(height: RadhaSpacing.space8),
          Wrap(
            spacing: RadhaSpacing.space8,
            runSpacing: RadhaSpacing.space8,
            children: likes
                .map(
                  (l) => _InsightBadge(
                    label: l.$1,
                    color: RadhaColors.success,
                    asset: l.$2,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: RadhaSpacing.space16),
        ],
        if (concerns.isNotEmpty) ...[
          _MiniHeading(
            icon: Icons.warning_amber_rounded,
            color: RadhaColors.warning,
            label: AppLocalizations.of(context).productDetailWhatConcern,
          ),
          const SizedBox(height: RadhaSpacing.space8),
          Wrap(
            spacing: RadhaSpacing.space8,
            runSpacing: RadhaSpacing.space8,
            children: concerns
                .map(
                  (c) => _InsightBadge(
                    label: c.$1,
                    color: RadhaColors.danger,
                    asset: c.$2,
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: RadhaSpacing.space4),
        Padding(
          padding: const EdgeInsets.only(top: RadhaSpacing.space8),
          child: Text(
            AppLocalizations.of(context).productDetailNutritionNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniHeading extends StatelessWidget {
  const _MiniHeading({
    required this.icon,
    required this.color,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: RadhaSpacing.space8),
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space12,
        vertical: RadhaSpacing.space8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// A nutrition insight as an illustrated mascot badge (art + label). Falls back
/// to a plain coloured pill when no illustration maps to the insight.
class _InsightBadge extends StatelessWidget {
  const _InsightBadge({required this.label, required this.color, this.asset});
  final String label;
  final Color color;
  final String? asset;

  @override
  Widget build(BuildContext context) {
    final art = asset;
    if (art == null) return _Tag(label: label, color: color);
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space8,
        vertical: RadhaSpacing.space12,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BrandIllustration(art, size: 48),
          const SizedBox(height: RadhaSpacing.space8),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Key nutrients + All Nutrients sheet ───────────────────────────────────

class _KeyNutrients extends StatelessWidget {
  const _KeyNutrients({required this.nutrition, required this.onAllNutrients});
  final ProductNutrition nutrition;
  final VoidCallback onAllNutrients;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).productDetailKeyNutrients,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: RadhaSpacing.space12),
          if (nutrition.protein != null)
            _NutrientRow(
              label: AppLocalizations.of(context).nutritionProtein,
              value: nutrition.protein!,
              unit: 'g',
              rdaPct: _rdaPct('protein', nutrition.protein!),
            ),
          if (nutrition.sugars != null)
            _NutrientRow(
              label: AppLocalizations.of(context).nutritionTotalSugars,
              value: nutrition.sugars!,
              unit: 'g',
              rdaPct: _rdaPct('sugars', nutrition.sugars!),
            ),
          if (nutrition.calories != null)
            _NutrientRow(
              label: AppLocalizations.of(context).nutritionEnergy,
              value: nutrition.calories!,
              unit: 'kcal',
              rdaPct: _rdaPct('calories', nutrition.calories!),
            ),
          const SizedBox(height: RadhaSpacing.space8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onAllNutrients,
              icon: const Icon(Icons.expand_more_rounded, size: 18),
              label: Text(AppLocalizations.of(context).nutritionAll),
            ),
          ),
        ],
      ),
    );
  }
}

class _NutrientRow extends StatelessWidget {
  const _NutrientRow({
    required this.label,
    required this.value,
    required this.unit,
    this.rdaPct,
  });
  final String label;
  final double value;
  final String unit;
  final double? rdaPct;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: RadhaSpacing.space8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(
            '${_fmt(value)} $unit',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (rdaPct != null) ...[
            const SizedBox(width: RadhaSpacing.space12),
            SizedBox(
              width: 52,
              child: Text(
                '${rdaPct!.round()}%',
                textAlign: TextAlign.right,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AllNutrientsSheet extends StatefulWidget {
  const _AllNutrientsSheet({required this.name, required this.nutrition});
  final String name;
  final ProductNutrition nutrition;

  @override
  State<_AllNutrientsSheet> createState() => _AllNutrientsSheetState();
}

class _AllNutrientsSheetState extends State<_AllNutrientsSheet> {
  bool _per100 = true; // false = per 50 g

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final n = widget.nutrition;
    final factor = _per100 ? 1.0 : 0.5;
    final l10n = AppLocalizations.of(context);
    final rows = <(String, double?, String)>[
      (l10n.nutritionEnergy, n.calories, 'kcal'),
      (l10n.nutritionTotalFat, n.fat, 'g'),
      ('  ${l10n.nutritionSaturatedFat}', n.saturatedFat, 'g'),
      (l10n.nutritionCarbohydrates, n.carbohydrates, 'g'),
      ('  ${l10n.nutritionTotalSugars}', n.sugars, 'g'),
      (l10n.nutritionProtein, n.protein, 'g'),
      (l10n.nutritionFibre, n.fiber, 'g'),
      (l10n.nutritionSodium, n.sodium, 'g'),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          RadhaSpacing.space20,
          RadhaSpacing.space12,
          RadhaSpacing.space20,
          RadhaSpacing.space24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: RadhaColors.inkMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
                ),
              ),
            ),
            const SizedBox(height: RadhaSpacing.space16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.nutritionAll,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SegmentedButton<bool>(
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                  segments: [
                    ButtonSegment(
                      value: true,
                      label: Text(l10n.nutritionPer100g),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text(l10n.nutritionPer50g),
                    ),
                  ],
                  selected: {_per100},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) => setState(() => _per100 = s.first),
                ),
              ],
            ),
            const SizedBox(height: RadhaSpacing.space12),
            ...rows
                .where((r) => r.$2 != null)
                .map(
                  (r) => Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: RadhaSpacing.space8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            r.$1.trim(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: r.$1.startsWith('  ')
                                  ? FontWeight.w400
                                  : FontWeight.w600,
                              color: r.$1.startsWith('  ')
                                  ? theme.colorScheme.onSurfaceVariant
                                  : null,
                            ),
                          ),
                        ),
                        Text(
                          '${_fmt(r.$2! * factor)} ${r.$3}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(
                          width: 56,
                          child: Text(
                            _rdaLabel(
                              r.$1.trim().toLowerCase(),
                              r.$2! * factor,
                            ),
                            textAlign: TextAlign.right,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: RadhaSpacing.space8),
            Text(
              AppLocalizations.of(context).productDetailRdaNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _rdaLabel(String key, double value) {
    final pct = _rdaPct(_rdaKeyFor(key), value);
    return pct == null ? '—' : '${pct.round()}%';
  }

  String _rdaKeyFor(String label) {
    if (label.contains('energy')) return 'calories';
    if (label.contains('saturated')) return 'saturatedFat';
    if (label.contains('fat')) return 'fat';
    if (label.contains('carbo')) return 'carbohydrates';
    if (label.contains('sugar')) return 'sugars';
    if (label.contains('protein')) return 'protein';
    if (label.contains('fibre') || label.contains('fiber')) return 'fiber';
    if (label.contains('sodium')) return 'sodium';
    return '';
  }
}

// ─── RADHA Plus (gated) ─────────────────────────────────────────────────────

class _PlusHeader extends StatelessWidget {
  const _PlusHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [RadhaColors.primary, RadhaColors.primaryDeep],
            ),
            borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
          ),
          child: const Text(
            'RADHA Plus',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: RadhaSpacing.space8),
        Text(
          AppLocalizations.of(context).productDetailForYou,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _IngredientDeepDive extends ConsumerWidget {
  const _IngredientDeepDive({required this.productId});
  final String? productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entitled =
        ref
            .watch(entitlementProvider)
            .valueOrNull
            ?.features
            .contains(Feature.ingredientExplainer) ??
        false;

    if (!entitled || productId == null) {
      return _PlusLock(
        title: AppLocalizations.of(context).productDetailIngredientDeepDive,
        subtitle: AppLocalizations.of(context).productDetailIngredientLockBody,
        feature: Feature.ingredientExplainer,
      );
    }

    final async = ref.watch(_ingredientExplainProvider(productId!));
    return _PlusCard(
      title: AppLocalizations.of(context).productDetailIngredientDeepDive,
      child: async.when(
        loading: () => const _LineSkeleton(),
        error: (_, _) => Text(
          AppLocalizations.of(context).productDetailIngredientError,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        data: (r) => Text(
          r.explanation,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
      ),
    );
  }
}

class _ForYouSection extends ConsumerWidget {
  const _ForYouSection({required this.productId});
  final String? productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final entitled =
        ref
            .watch(entitlementProvider)
            .valueOrNull
            ?.features
            .contains(Feature.allergenProfile) ??
        false;

    if (!entitled || productId == null) {
      return _PlusLock(
        title: AppLocalizations.of(context).productDetailPersonalisedFlags,
        subtitle: AppLocalizations.of(context).productDetailAllergenLockBody,
        feature: Feature.allergenProfile,
      );
    }

    final user = ref.watch(currentUserProvider);
    final allergensAsync = ref.watch(_productAllergensProvider(productId!));
    final profileTags = user == null
        ? const <String>{}
        : ref
              .watch(allergenProfileProvider(user.userId))
              .maybeWhen(
                data: (p) => p.allergens.toSet(),
                orElse: () => const <String>{},
              );

    return _PlusCard(
      title: AppLocalizations.of(context).productDetailPersonalisedFlags,
      child: allergensAsync.when(
        loading: () => const _LineSkeleton(),
        error: (_, _) => Text(
          AppLocalizations.of(context).productDetailAllergenError,
          style: theme.textTheme.bodySmall,
        ),
        data: (allergens) {
          if (allergens.isEmpty) {
            return Text(
              AppLocalizations.of(context).productDetailNoAllergens,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: RadhaColors.success,
              ),
            );
          }
          return Wrap(
            spacing: RadhaSpacing.space8,
            runSpacing: RadhaSpacing.space8,
            children: allergens.map((a) {
              final hit = _matches(a.name, profileTags);
              final color = hit ? RadhaColors.danger : RadhaColors.inkMuted;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: RadhaSpacing.space12,
                  vertical: RadhaSpacing.space8,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: hit ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hit) ...[
                      Icon(Icons.warning_amber_rounded, size: 14, color: color),
                      const SizedBox(width: RadhaSpacing.space4),
                    ],
                    Text(
                      hit
                          ? AppLocalizations.of(context)
                              .productDetailAllergenAvoid(a.name)
                          : a.name,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  bool _matches(String name, Set<String> tags) {
    if (tags.isEmpty) return false;
    final raw = name.toLowerCase().trim();
    final norm = raw.replaceAll(' ', '_').replaceAll('-', '_');
    if (tags.contains(norm)) return true;
    for (final t in tags) {
      if (raw.contains(t.replaceAll('_', ' ')) || norm.contains(t)) return true;
    }
    return false;
  }
}

/// Locked premium block — a blurred faux-preview with a lock + upsell CTA.
class _PlusLock extends StatelessWidget {
  const _PlusLock({
    required this.title,
    required this.subtitle,
    required this.feature,
  });
  final String title;
  final String subtitle;
  final Feature feature;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
      child: Stack(
        children: [
          // Faux content behind the blur (purely decorative lines).
          // `Positioned.fill` so it always matches whatever height the real
          // overlay content below needs — it used to be a plain Container
          // sized by a fixed count of generated lines, driving the Stack's
          // height itself. That was a height *guess* matched against the
          // overlay Row (icon + title + subtitle + button), and fell short
          // by a few px under font scaling / longer locale strings,
          // producing a real `BOTTOM OVERFLOWED BY 4.0 PIXELS` error.
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.all(RadhaSpacing.space16),
              color: theme.colorScheme.surfaceContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  5,
                  (i) => FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: i.isEven ? 1.0 : 0.7,
                    child: Container(
                      height: 12,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.06,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Real overlay — intentionally NOT Positioned, so it drives the
          // Stack's intrinsic height instead of being forced to fit one.
          BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              width: double.infinity,
              color: theme.colorScheme.surface.withValues(alpha: 0.55),
              padding: const EdgeInsets.all(RadhaSpacing.space16),
              child: Row(
                children: [
                    const Icon(Icons.lock_rounded, color: RadhaColors.primary),
                    const SizedBox(width: RadhaSpacing.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: RadhaSpacing.space8),
                          FilledButton.tonalIcon(
                            onPressed: () =>
                                context.push(AppRoute.subscription),
                            style: FilledButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                            icon: const Icon(Icons.bolt_rounded, size: 16),
                            label: Text(
                              AppLocalizations.of(context).productDetailUnlockWith(
                                requiredPlanFor(feature),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlusCard extends StatelessWidget {

  const _PlusCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: RadhaSpacing.space8),
          child,
        ],
      ),
    );
  }
}

// ─── Would you buy ──────────────────────────────────────────────────────────

class _WouldYouBuy extends StatelessWidget {
  const _WouldYouBuy({required this.choice, required this.onChoice});
  final String? choice;
  final ValueChanged<String> onChoice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      decoration: BoxDecoration(
        color: RadhaColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        border: Border.all(color: RadhaColors.primaryTint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            choice == null
                ? AppLocalizations.of(context).productDetailWouldYouBuy
                : AppLocalizations.of(context).productDetailThanksForSharing,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: RadhaColors.primaryDeep,
            ),
          ),
          const SizedBox(height: RadhaSpacing.space12),
          Row(
            children: [
              _BuyChip(
                label: AppLocalizations.of(context).commonYes,
                icon: Icons.check_rounded,
                selected: choice == 'yes',
                color: RadhaColors.success,
                onTap: () => onChoice('yes'),
              ),
              const SizedBox(width: RadhaSpacing.space8),
              _BuyChip(
                label: AppLocalizations.of(context).commonNo,
                icon: Icons.close_rounded,
                selected: choice == 'no',
                color: RadhaColors.danger,
                onTap: () => onChoice('no'),
              ),
              const SizedBox(width: RadhaSpacing.space8),
              _BuyChip(
                label: AppLocalizations.of(context).productDetailAlreadyBought,
                icon: Icons.shopping_bag_outlined,
                selected: choice == 'bought',
                color: RadhaColors.inkMuted,
                onTap: () => onChoice('bought'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BuyChip extends StatelessWidget {
  const _BuyChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: RadhaSpacing.space12,
          vertical: RadhaSpacing.space8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.14)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
          border: Border.all(
            color: selected ? color : theme.colorScheme.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? color : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: RadhaSpacing.space4),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? color : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Honest "scan to unlock" ────────────────────────────────────────────────

class _ScanToUnlock extends StatelessWidget {
  const _ScanToUnlock({required this.onScan});
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BrandIllustration(RadhaAssets.morSceneScanning, size: 76),
              const SizedBox(width: RadhaSpacing.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).productDetailNutritionNotIn,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: RadhaSpacing.space4),
                    Text(
                      AppLocalizations.of(
                        context,
                      ).productDetailNutritionNotInBody,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: RadhaSpacing.space12),
          FilledButton.icon(
            onPressed: onScan,
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
            label: Text(AppLocalizations.of(context).productDetailScanToUnlock),
          ),
        ],
      ),
    );
  }
}

// ─── Shared bits ────────────────────────────────────────────────────────────

class _NavRow extends StatelessWidget {
  const _NavRow({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        side: BorderSide(color: scheme.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        child: Container(
          constraints: const BoxConstraints(minHeight: kMinTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: RadhaSpacing.space16,
            vertical: RadhaSpacing.space12,
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: scheme.onSurface),
              const SizedBox(width: RadhaSpacing.space16),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LineSkeleton extends StatelessWidget {
  const _LineSkeleton();
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 12, width: double.infinity, color: c),
        const SizedBox(height: 8),
        Container(height: 12, width: 220, color: c),
      ],
    );
  }
}

class _NutritionSkeleton extends StatelessWidget {
  const _NutritionSkeleton();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
      ),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: RadhaColors.primary,
          ),
        ),
      ),
    );
  }
}

// ─── Formatting + RDA helpers ───────────────────────────────────────────────

String _fmt(double v) {
  if (v >= 100) return v.round().toString();
  if (v == v.roundToDouble()) return v.round().toString();
  return v.toStringAsFixed(1);
}

/// Reference daily intake (adult) for RDA% — published reference values, not
/// fabricated. Sodium in grams. Energy in kcal.
const Map<String, double> _rda = {
  'calories': 2000,
  'fat': 67,
  'saturatedFat': 22,
  'carbohydrates': 300,
  'sugars': 50,
  'protein': 50,
  'fiber': 30,
  'sodium': 2.0,
};

double? _rdaPct(String key, double value) {
  final ref = _rda[key];
  if (ref == null || ref <= 0) return null;
  return (value / ref) * 100;
}

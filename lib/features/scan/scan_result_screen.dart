import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/network/api_client.dart';
import '../../core/network/dto/ean_dto.dart';
import '../../core/network/dto/health_assessment_dto.dart';
import '../../core/network/dto/product_lookup_dto.dart';
import '../../core/router/app_router.dart';
import '../../design/app_assets.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/widgets/mor_celebration.dart';
import '../../design/widgets/mor_companion.dart';
import '../../design/widgets/primary_button.dart';
import 'contribute_product_screen.dart';
import '../../l10n/generated/app_localizations.dart';

/// FutureProvider that fetches a product by EAN.
///
/// Calls `GET /products/lookup/{ean}` — the only real backend route for
/// this; `/products/ean/{ean}` (used here previously) does not exist and
/// 404'd on every scan. The lookup endpoint also live-falls-back to Open
/// Food Facts and persists the result on a local-catalog miss, so a
/// never-before-scanned barcode now resolves instead of failing outright.
/// `found: false` is surfaced as a 404 [DioException] so the existing
/// not-found error state below is unchanged. Auto-disposed so cache
/// doesn't grow unbounded across many scan results.
///
/// Returns the full [ProductLookupResult] — the health section needs the
/// embedded [ProductLookupResult.health] (added server-side so the lookup
/// carries health in the same round trip instead of a second request), and
/// the product body needs `nutrition`/`description` (ingredients) fields,
/// which a prior narrower `ProductResponse` mapping silently dropped.
final _productByEanProvider = FutureProvider.autoDispose
    .family<ProductLookupResult, String>((ref, ean) async {
      final client = ref.read(apiClientProvider);
      final result = await client.getProductLookup(ean);
      if (!result.found || result.product == null) {
        throw DioException(
          requestOptions: RequestOptions(path: '/api/v1/products/lookup/$ean'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/v1/products/lookup/$ean'),
            statusCode: 404,
          ),
          type: DioExceptionType.badResponse,
        );
      }
      return result;
    });

/// Composite key for the approved-EAN check — an EAN scoped to a store.
@immutable
class _EanCheckArgs {
  const _EanCheckArgs({required this.ean, required this.storeId});

  final String ean;
  final String storeId;

  @override
  bool operator ==(Object other) =>
      other is _EanCheckArgs && other.ean == ean && other.storeId == storeId;

  @override
  int get hashCode => Object.hash(ean, storeId);
}

/// Validates an EAN against the store's approved list. Auto-disposed and
/// keyed by (ean, storeId) so each scan result resolves independently.
final _approvedEanProvider = FutureProvider.autoDispose
    .family<EanValidationResult, _EanCheckArgs>((ref, args) async {
      final client = ref.read(apiClientProvider);
      return client.validateEan(
        ValidateEanDto(ean: args.ean, storeId: args.storeId),
      );
    });

/// Full-screen product result after scanning a barcode — the health card.
///
/// Layout mirrors the mockup: product header, approved-EAN pill, an animated
/// circular health-score gauge with nutrition badges, an allergen note, and a
/// pinned bottom action bar (Add to expiry primary + Stock / Save outline).
///
/// Health data note: the V1 `GET /products/lookup/{ean}` returns catalog
/// fields only (no per-product health score). The gauge + badges render in a
/// clearly-labelled "assessment pending" state rather than fabricating values;
/// the widgets accept real data unchanged once the health endpoint is wired.
class ScanResultScreen extends ConsumerWidget {
  const ScanResultScreen({super.key, required this.ean});

  final String ean;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(_productByEanProvider(ean));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          AppLocalizations.of(context).scanResultTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded),
            tooltip: AppLocalizations.of(context).commonShare,
            onPressed: () => Share.share(
              AppLocalizations.of(context).scanResultShareMessage(ean),
            ),
          ),
        ],
      ),
      body: productAsync.when(
        loading: () => const _SkeletonBody(),
        error: (error, _) => _ErrorBody(ean: ean, error: error),
        data: (result) => _ProductBody(
          product: result.product!,
          health: result.health,
          ean: ean,
        ),
      ),
    );
  }
}

// ─── Body ────────────────────────────────────────────────────────────────────

/// Renders the product result and fires a one-shot "scan-success" celebration
/// (Mor celebrate + marigold petal burst) the first time the store's approved
/// EAN check resolves to a match. The beat is brand-affirming feedback — the
/// daily dopamine of a clean audit scan (Character Bible §6/§8). It never
/// blocks interaction and auto-dismisses; in reduced-motion it is suppressed
/// (the approval pill + text already convey the state).
class _ProductBody extends ConsumerStatefulWidget {
  const _ProductBody({required this.product, required this.health, required this.ean});

  final ProductLookupItem product;
  final HealthAssessmentDto? health;
  final String ean;

  @override
  ConsumerState<_ProductBody> createState() => _ProductBodyState();
}

class _ProductBodyState extends ConsumerState<_ProductBody> {
  bool _celebrated = false;
  bool _showBurst = false;

  @override
  Widget build(BuildContext context) {
    final storeId = ref.watch(currentUserProvider)?.selectedStoreId;

    // Only an in-audit scan (store selected) has an approved list to match
    // against, so only then can a "matched" success beat fire.
    if (storeId != null) {
      ref.listen<AsyncValue<EanValidationResult>>(
        _approvedEanProvider(_EanCheckArgs(ean: widget.ean, storeId: storeId)),
        (prev, next) {
          final matched = next.asData?.value.matched ?? false;
          if (matched && !_celebrated && mounted) {
            _celebrated = true;
            HapticFeedback.mediumImpact();
            setState(() => _showBurst = true);
          }
        },
      );
    }

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  RadhaSpacing.space20,
                  RadhaSpacing.space8,
                  RadhaSpacing.space20,
                  RadhaSpacing.space24,
                ),
                children: [
                  _ProductHeader(product: widget.product, ean: widget.ean),
                  const SizedBox(height: RadhaSpacing.space16),
                  _ApprovedEanPill(ean: widget.ean),
                  const SizedBox(height: RadhaSpacing.space24),
                  _HealthSection(product: widget.product, health: widget.health),
                  const SizedBox(height: RadhaSpacing.space16),
                  _ExplainIngredientsButton(productId: widget.product.id),
                  const SizedBox(height: RadhaSpacing.space16),
                  _AllergenNote(
                    allergens: widget.product.nutrition?.containsAllergens ?? const [],
                  ),
                ],
              ),
            ),
            _ActionBar(
              ean: widget.ean,
              productId: widget.product.id,
              productName: widget.product.name,
            ),
          ],
        ),
        if (_showBurst)
          // Non-interactive overlay so taps still reach the content beneath.
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: const Alignment(0, -0.45),
                child: MorCelebration(
                  size: 132,
                  onComplete: () {
                    if (mounted) setState(() => _showBurst = false);
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Product header ──────────────────────────────────────────────────────────

class _ProductHeader extends StatelessWidget {
  const _ProductHeader({required this.product, required this.ean});

  final ProductLookupItem product;
  final String ean;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProductThumb(imageUrl: product.imageUrl),
        const SizedBox(width: RadhaSpacing.space16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              if (product.brand != null || product.subCategory != null) ...[
                const SizedBox(height: RadhaSpacing.space4),
                Row(
                  children: [
                    if (product.brand != null)
                      Flexible(
                        child: Text(
                          product.brand!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    if (product.brand != null && product.subCategory != null)
                      Text(
                        ' · ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    if (product.subCategory != null)
                      Flexible(
                        child: Text(
                          product.subCategory!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: RadhaSpacing.space8),
              Text(
                'EAN: $ean',
                style: radhaMonoStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeholder = Icon(
      Icons.inventory_2_outlined,
      size: 32,
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: imageUrl == null
          ? placeholder
          : CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              width: 72,
              height: 72,
              errorWidget: (_, _, _) => placeholder,
              placeholder: (_, _) => placeholder,
            ),
    );
  }
}

// ─── Approved EAN pill ───────────────────────────────────────────────────────

/// Resolves and renders the approved-list verification state for [ean].
///
/// Outside an audit (no selected store) consumers have no approved list, so we
/// keep the neutral "not in an audit" copy. With a store selected we call
/// `POST /ean-lists/validate` and render a green (approved), red (not in list /
/// invalid), or warning (no active list) pill — falling back to a neutral
/// "couldn't check" pill on error.
class _ApprovedEanPill extends ConsumerWidget {
  const _ApprovedEanPill({required this.ean});

  final String ean;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeId = ref.watch(currentUserProvider)?.selectedStoreId;

    final l10n = AppLocalizations.of(context);

    // No store ⇒ consumer context, nothing to verify against.
    if (storeId == null) {
      return _PillFrame(
        icon: Icons.verified_outlined,
        label: l10n.scanApprovalNotInAudit,
        tone: _PillTone.neutral,
      );
    }

    final result = ref.watch(
      _approvedEanProvider(_EanCheckArgs(ean: ean, storeId: storeId)),
    );

    return result.when(
      loading: () => _PillFrame(
        icon: null,
        label: l10n.scanApprovalChecking,
        tone: _PillTone.neutral,
        showSpinner: true,
      ),
      error: (_, _) => _PillFrame(
        icon: Icons.help_outline_rounded,
        label: l10n.scanApprovalCheckFailed,
        tone: _PillTone.neutral,
      ),
      data: (validation) {
        if (validation.matched) {
          return _PillFrame(
            icon: Icons.check_circle_rounded,
            label: l10n.scanApprovalApproved,
            tone: _PillTone.success,
          );
        }
        switch (validation.reason) {
          case 'no_active_list':
            return _PillFrame(
              icon: Icons.info_outline_rounded,
              label: l10n.scanApprovalNoList,
              tone: _PillTone.warning,
            );
          case 'invalid_format':
            return _PillFrame(
              icon: Icons.cancel_rounded,
              label: l10n.scanApprovalInvalidBarcode,
              tone: _PillTone.danger,
            );
          default:
            return _PillFrame(
              icon: Icons.cancel_rounded,
              label: l10n.scanApprovalNotInList,
              tone: _PillTone.danger,
            );
        }
      },
    );
  }
}

enum _PillTone { neutral, success, warning, danger }

/// Shared pill chrome for the approval status. Honors the design radii and
/// keeps a `Semantics` label so the status is announced to screen readers.
class _PillFrame extends StatelessWidget {
  const _PillFrame({
    required this.icon,
    required this.label,
    required this.tone,
    this.showSpinner = false,
  });

  final IconData? icon;
  final String label;
  final _PillTone tone;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color accent = switch (tone) {
      _PillTone.success => RadhaColors.success,
      _PillTone.warning => RadhaColors.warning,
      _PillTone.danger => RadhaColors.danger,
      _PillTone.neutral => theme.colorScheme.onSurfaceVariant,
    };
    final bool tinted = tone != _PillTone.neutral;
    final Color background = tinted
        ? accent.withValues(alpha: 0.08)
        : theme.colorScheme.surfaceContainer;
    final Color border = tinted
        ? accent.withValues(alpha: 0.35)
        : theme.colorScheme.outline;
    final Color foreground = tinted ? accent : theme.colorScheme.onSurfaceVariant;

    return Semantics(
      label: AppLocalizations.of(context).scanApprovalStatus(label),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: RadhaSpacing.space12,
            vertical: RadhaSpacing.space8,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showSpinner)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(foreground),
                  ),
                )
              else if (icon != null)
                Icon(icon, size: 16, color: foreground),
              const SizedBox(width: RadhaSpacing.space8),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Health section ──────────────────────────────────────────────────────────

class _HealthSection extends StatelessWidget {
  const _HealthSection({required this.product, required this.health});

  final ProductLookupItem product;
  final HealthAssessmentDto? health;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final nutrition = product.nutrition;
    // Rebind the field to a local so Dart can promote `HealthAssessmentDto?`
    // to non-null within the `health != null` branches below — instance
    // fields aren't promotable, only locals/params.
    final health = this.health;

    return Container(
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
              Text(
                l10n.scanResultHealthHeading,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              // Only show a status chip once we actually have one — the
              // gauge + nutrient chips below already speak for themselves
              // once real data lands, so there's nothing honest left to
              // hedge with an "assessment pending" label at that point.
              if (health == null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: RadhaSpacing.space12,
                    vertical: RadhaSpacing.space4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
                  ),
                  child: Text(
                    l10n.scanResultAssessmentPending,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                _GradeChip(grade: health.overallGrade, status: health.healthStatus),
            ],
          ),
          const SizedBox(height: RadhaSpacing.space16),
          Row(
            children: [
              _ScoreGauge(
                score: health?.overallScore,
                status: health?.healthStatus,
              ),
              const SizedBox(width: RadhaSpacing.space20),
              Expanded(
                child: Text(
                  health != null
                      ? _summaryFor(health, l10n)
                      : l10n.scanResultNutritionPending,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: RadhaSpacing.space16),
          Wrap(
            spacing: RadhaSpacing.space8,
            runSpacing: RadhaSpacing.space8,
            children: [
              _HealthChip(
                label: AppLocalizations.of(context).healthSugar,
                icon: Icons.water_drop_outlined,
                level: _sugarLevel(health, nutrition),
              ),
              _HealthChip(
                label: AppLocalizations.of(context).healthSalt,
                icon: Icons.grain,
                level: _saltLevel(health, nutrition),
              ),
              _HealthChip(
                label: AppLocalizations.of(context).healthFat,
                icon: Icons.opacity,
                level: _fatLevel(health, nutrition),
              ),
              _HealthChip(
                label: AppLocalizations.of(context).healthProcessed,
                icon: Icons.factory_outlined,
                level: _processedLevel(health),
              ),
              _HealthChip(
                label: AppLocalizations.of(context).healthChildSuitable,
                icon: Icons.child_friendly,
                level: _childSafetyLevel(health),
              ),
            ],
          ),
          if (nutrition != null && nutrition.hasAnyValue) ...[
            const SizedBox(height: RadhaSpacing.space16),
            const Divider(height: 1),
            const SizedBox(height: RadhaSpacing.space16),
            Text('Nutrition (per 100g)', style: theme.textTheme.labelLarge),
            const SizedBox(height: RadhaSpacing.space8),
            _NutritionFactsGrid(nutrition: nutrition),
          ],
          if (product.description != null && product.description!.trim().isNotEmpty) ...[
            const SizedBox(height: RadhaSpacing.space16),
            const Divider(height: 1),
            const SizedBox(height: RadhaSpacing.space16),
            Text('Ingredients', style: theme.textTheme.labelLarge),
            const SizedBox(height: RadhaSpacing.space8),
            Text(
              product.description!.trim(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _summaryFor(HealthAssessmentDto health, AppLocalizations l10n) {
    if (health.warnings.isEmpty && health.positives.isEmpty) {
      return switch (health.healthStatus) {
        'green' => 'Looks like a solid everyday choice.',
        'yellow' => 'Fine in moderation.',
        'red' => 'Best as an occasional treat.',
        _ => l10n.scanResultNutritionPending,
      };
    }
    // Lead with the most severe warning (if any), else the first positive.
    final worst = health.warnings.isNotEmpty
        ? health.warnings.reduce(
            (a, b) => _severityRank(b.severity) > _severityRank(a.severity) ? b : a,
          )
        : null;
    return worst?.message ?? health.positives.first.message;
  }

  static int _severityRank(String severity) => switch (severity) {
    'high' => 2,
    'medium' => 1,
    _ => 0,
  };

  static _HealthLevel _sugarLevel(HealthAssessmentDto? health, ProductNutrition? nutrition) {
    if (health == null) return _HealthLevel.unknown;
    if (health.warningOfType('high_sugar')) return _HealthLevel.bad;
    if (health.positiveOfType('low_sugar')) return _HealthLevel.good;
    return nutrition?.sugars != null ? _HealthLevel.moderate : _HealthLevel.unknown;
  }

  static _HealthLevel _saltLevel(HealthAssessmentDto? health, ProductNutrition? nutrition) {
    if (health == null) return _HealthLevel.unknown;
    if (health.warningOfType('high_sodium')) return _HealthLevel.bad;
    if (health.positiveOfType('low_sodium')) return _HealthLevel.good;
    return nutrition?.sodium != null ? _HealthLevel.moderate : _HealthLevel.unknown;
  }

  static _HealthLevel _fatLevel(HealthAssessmentDto? health, ProductNutrition? nutrition) {
    if (health == null) return _HealthLevel.unknown;
    if (health.warningOfType('high_oil') ||
        health.warningOfType('high_saturated_fat') ||
        health.warningOfType('trans_fat')) {
      return _HealthLevel.bad;
    }
    if (health.positiveOfType('no_trans_fat')) return _HealthLevel.good;
    return nutrition?.fat != null ? _HealthLevel.moderate : _HealthLevel.unknown;
  }

  static _HealthLevel _processedLevel(HealthAssessmentDto? health) => switch (health?.isProcessed) {
    'not' => _HealthLevel.good,
    'lightly' => _HealthLevel.moderate,
    'ultra' => _HealthLevel.bad,
    _ => _HealthLevel.unknown,
  };

  static _HealthLevel _childSafetyLevel(HealthAssessmentDto? health) =>
      switch (health?.childSafety.status) {
        'suitable' => _HealthLevel.good,
        'caution' => _HealthLevel.moderate,
        'unsuitable' => _HealthLevel.bad,
        _ => _HealthLevel.unknown,
      };
}

/// Small pill next to the "Health" heading once a real grade is available —
/// e.g. "B · 3.5/5". Converts the 0..100 score to a familiar out-of-5 rating
/// alongside the letter grade, matching how shoppers already read food
/// ratings elsewhere.
class _GradeChip extends StatelessWidget {
  const _GradeChip({required this.grade, required this.status});

  final String grade;
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (status) {
      'green' => RadhaColors.success,
      'yellow' => RadhaColors.warning,
      'red' => RadhaColors.danger,
      _ => theme.colorScheme.onSurfaceVariant,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space12,
        vertical: RadhaSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        'Grade $grade',
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Per-100g nutrient values in a compact 2-column grid. Never shows a
/// fabricated zero — a missing value is simply omitted from the grid.
class _NutritionFactsGrid extends StatelessWidget {
  const _NutritionFactsGrid({required this.nutrition});

  final ProductNutrition nutrition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = <(String, String)>[
      if (nutrition.calories != null) ('Energy', '${nutrition.calories!.toStringAsFixed(0)} kcal'),
      if (nutrition.protein != null) ('Protein', '${nutrition.protein!.toStringAsFixed(1)} g'),
      if (nutrition.carbohydrates != null)
        ('Carbohydrate', '${nutrition.carbohydrates!.toStringAsFixed(1)} g'),
      if (nutrition.sugars != null) ('Sugars', '${nutrition.sugars!.toStringAsFixed(1)} g'),
      if (nutrition.fat != null) ('Fat', '${nutrition.fat!.toStringAsFixed(1)} g'),
      if (nutrition.saturatedFat != null)
        ('Saturated fat', '${nutrition.saturatedFat!.toStringAsFixed(1)} g'),
      if (nutrition.fiber != null) ('Fiber', '${nutrition.fiber!.toStringAsFixed(1)} g'),
      if (nutrition.sodium != null) ('Sodium', '${nutrition.sodium!.toStringAsFixed(0)} mg'),
    ];
    return Wrap(
      spacing: RadhaSpacing.space16,
      runSpacing: RadhaSpacing.space8,
      children: [
        for (final (label, value) in rows)
          SizedBox(
            width: 140,
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                children: [
                  TextSpan(text: '$label  '),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Animated circular health-score gauge. Sweeps the arc from 0 to [score]
/// (0..100) on entry; renders a neutral dashed ring + "–" when [score] is
/// null (assessment pending). Honors reduce-motion.
class _ScoreGauge extends StatefulWidget {
  const _ScoreGauge({required this.score, this.status});

  /// 0..100, or null when no assessment is available.
  final int? score;

  /// 'green' | 'yellow' | 'red' | 'data_unavailable' — colors the fill arc
  /// to match the traffic-light status; null falls back to brand primary.
  final String? status;

  @override
  State<_ScoreGauge> createState() => _ScoreGaugeState();
}

class _ScoreGaugeState extends State<_ScoreGauge>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;
  late Animation<double> _anim;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.score == null || _ctrl != null) return;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _ctrl = ctrl;
    _anim = Tween<double>(begin: 0, end: widget.score! / 100).animate(
      CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic),
    );
    if (reduceMotion) {
      ctrl.value = 1.0;
    } else {
      ctrl.forward();
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const size = 72.0;
    if (widget.score == null) {
      return SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _GaugePainter(
            progress: 0,
            track: theme.colorScheme.outline,
            fill: RadhaColors.primary,
          ),
          child: Center(
            child: Text(
              '–',
              style: radhaMonoStyle(
                fontSize: 22,
                weight: FontWeight.w700,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }
    final fillColor = switch (widget.status) {
      'green' => RadhaColors.success,
      'yellow' => RadhaColors.warning,
      'red' => RadhaColors.danger,
      _ => RadhaColors.primary,
    };
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          final shown = (_anim.value * 100).round();
          return CustomPaint(
            painter: _GaugePainter(
              progress: _anim.value,
              track: theme.colorScheme.outline,
              fill: fillColor,
            ),
            child: Center(
              child: Text(
                '$shown',
                style: radhaMonoStyle(
                  fontSize: 22,
                  weight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.progress,
    required this.track,
    required this.fill,
  });

  final double progress;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 4;
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final fillPaint = Paint()
      ..color = fill
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    // Full track ring.
    canvas.drawCircle(center, radius, trackPaint);
    // Progress arc from top, clockwise.
    const start = -math.pi / 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      2 * math.pi * progress,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.progress != progress || old.fill != fill || old.track != track;
}

enum _HealthLevel { good, moderate, bad, unknown }

class _HealthChip extends StatelessWidget {
  const _HealthChip({
    required this.label,
    required this.icon,
    required this.level,
  });

  final String label;
  final IconData icon;
  final _HealthLevel level;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color color = switch (level) {
      _HealthLevel.good => RadhaColors.success,
      _HealthLevel.moderate => RadhaColors.warning,
      _HealthLevel.bad => RadhaColors.danger,
      _HealthLevel.unknown => theme.colorScheme.onSurfaceVariant,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space12,
        vertical: RadhaSpacing.space8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: RadhaSpacing.space8),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ─── Explain ingredients (AI) ────────────────────────────────────────────────

class _ExplainIngredientsButton extends StatelessWidget {
  const _ExplainIngredientsButton({required this.productId});

  final String productId;

  /// Kebab-case slug derived from the product id for the `/ingredients/:slug`
  /// route. The backend normalises again server-side.
  String get _slug {
    final s = productId
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return s.isEmpty ? 'ingredient' : s;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          context.push('/ingredients/$_slug');
        },
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(RadhaSpacing.space16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 20,
                color: RadhaColors.primary,
              ),
              const SizedBox(width: RadhaSpacing.space12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).scanResultExplainIngredients,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Allergen note ───────────────────────────────────────────────────────────

class _AllergenNote extends StatelessWidget {
  const _AllergenNote({required this.allergens});

  /// Real declared allergens from `ProductNutrition.containsAllergens` —
  /// empty (not null) when the product has nutrition data but declares
  /// none, so callers never have to distinguish "no data" from "no
  /// allergens" here; that distinction is handled upstream by whichever
  /// screen decides whether to show this widget at all.
  final List<String> allergens;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final hasAllergens = allergens.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      decoration: BoxDecoration(
        color: hasAllergens
            ? RadhaColors.warning.withValues(alpha: 0.12)
            : RadhaColors.primaryTint.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            hasAllergens
                ? Icons.warning_amber_rounded
                : Icons.info_outline_rounded,
            size: 20,
            color: RadhaColors.warning,
          ),
          const SizedBox(width: RadhaSpacing.space12),
          Expanded(
            child: Text(
              hasAllergens
                  ? l10n.scanResultAllergensDeclared(allergens.join(', '))
                  : l10n.scanResultNoAllergensDeclared,
              style: theme.textTheme.bodySmall?.copyWith(
                color: RadhaColors.ink,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom action bar ───────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.ean,
    required this.productId,
    required this.productName,
  });

  final String ean;
  final String productId;
  final String productName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        RadhaSpacing.space20,
        RadhaSpacing.space12,
        RadhaSpacing.space20,
        RadhaSpacing.space12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: PrimaryButton(
              label: AppLocalizations.of(context).scanResultAddToExpiry,
              icon: Icons.event_available_outlined,
              expand: true,
              onPressed: () {
                HapticFeedback.lightImpact();
                context.push(
                  AppRoute.expiryNew,
                  extra: {
                    'ean': ean,
                    'productId': productId,
                    'productName': productName,
                  },
                );
              },
            ),
          ),
          const SizedBox(width: RadhaSpacing.space12),
          _OutlineIconButton(
            icon: Icons.add_box_outlined,
            tooltip: AppLocalizations.of(context).scanResultAddToStock,
            onTap: () => context.push(AppRoute.inventoryStockMovement),
          ),
          const SizedBox(width: RadhaSpacing.space12),
          _OutlineIconButton(
            icon: Icons.bookmark_add_outlined,
            tooltip: AppLocalizations.of(context).scanResultSaveToList,
            onTap: () => context.push(AppRoute.shoppingList),
          ),
        ],
      ),
    );
  }
}

class _OutlineIconButton extends StatelessWidget {
  const _OutlineIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
          child: Container(
            width: kMinTouchTarget + 4,
            height: kMinTouchTarget + 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Icon(icon, color: theme.colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}

// ─── Skeleton ────────────────────────────────────────────────────────────────

class _SkeletonBody extends StatelessWidget {
  const _SkeletonBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget box(double h, double w) => Container(
      height: h,
      width: w,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusSm),
      ),
    );
    return Padding(
      padding: const EdgeInsets.all(RadhaSpacing.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              box(72, 72),
              const SizedBox(width: RadhaSpacing.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    box(20, double.infinity),
                    const SizedBox(height: RadhaSpacing.space8),
                    box(14, 140),
                    const SizedBox(height: RadhaSpacing.space8),
                    box(12, 100),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: RadhaSpacing.space24),
          box(120, double.infinity),
          const SizedBox(height: RadhaSpacing.space16),
          box(56, double.infinity),
        ],
      ),
    );
  }
}

// ─── Error ───────────────────────────────────────────────────────────────────

enum _ScanErrorKind { notFound, unauthorized, offline, timeout, serverError }

_ScanErrorKind _classifyError(Object error) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    if (status == 401 || status == 403) return _ScanErrorKind.unauthorized;
    if (status == 404) return _ScanErrorKind.notFound;
    if (error.type == DioExceptionType.connectionError ||
        error.error is SocketException) {
      return _ScanErrorKind.offline;
    }
    if (error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionTimeout) {
      return _ScanErrorKind.timeout;
    }
    return _ScanErrorKind.serverError;
  }
  return _ScanErrorKind.serverError;
}

class _ErrorBody extends ConsumerWidget {
  const _ErrorBody({required this.ean, required this.error});

  final String ean;
  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final kind = _classifyError(error);
    // Transient failures (network hiccup, slow response, one-off 5xx) are
    // worth a one-tap retry — the earlier fix to the lookup's provider
    // chain (parallelized + OFF retry-once) makes a second attempt
    // meaningfully more likely to succeed than before, which is exactly
    // the "sometimes found, sometimes not" pattern this addresses.
    final showRetryCta = kind == _ScanErrorKind.offline ||
        kind == _ScanErrorKind.timeout ||
        kind == _ScanErrorKind.serverError;

    final (title, body, showLabelScanCta) = switch (kind) {
      _ScanErrorKind.notFound => (
        l10n.productNotFound,
        l10n.scanResultNotFoundBody(ean),
        true,
      ),
      _ScanErrorKind.unauthorized => (
        'Not authorised',
        'Your session may have expired. Please sign out and sign back in.',
        false,
      ),
      _ScanErrorKind.offline => (
        'You\'re offline',
        'Check your internet connection and try scanning again.',
        false,
      ),
      _ScanErrorKind.timeout => (
        'Request timed out',
        'The server took too long to respond. Try again in a moment.',
        false,
      ),
      _ScanErrorKind.serverError => (
        'Something went wrong',
        'We couldn\'t fetch this product right now. Try again.',
        false,
      ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RadhaSpacing.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MorCompanion(
              mood: kind == _ScanErrorKind.offline
                  ? MorMood.concern
                  : MorMood.concern,
              size: 108,
              semanticLabel: l10n.scanResultNoProduct,
            ),
            const SizedBox(height: RadhaSpacing.space16),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: RadhaSpacing.space8),
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: RadhaSpacing.space24),
            if (showRetryCta)
              PrimaryButton(
                label: 'Retry',
                icon: Icons.refresh_rounded,
                expand: true,
                onPressed: () => ref.invalidate(_productByEanProvider(ean)),
              ),
            if (showRetryCta) const SizedBox(height: RadhaSpacing.space12),
            if (showLabelScanCta)
              PrimaryButton(
                label: l10n.scanResultScanLabel,
                icon: Icons.document_scanner_outlined,
                expand: true,
                onPressed: () => context.pushReplacement(AppRoute.labelScan),
              ),
            if (showLabelScanCta) const SizedBox(height: RadhaSpacing.space12),
            if (showLabelScanCta)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add_business_outlined),
                  label: const Text('Add this product yourself'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ContributeProductScreen(ean: ean),
                    ),
                  ),
                ),
              ),
            if (showLabelScanCta) const SizedBox(height: RadhaSpacing.space12),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(l10n.scanAgain),
            ),
          ],
        ),
      ),
    );
  }
}

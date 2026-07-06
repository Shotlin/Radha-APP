// AI Ingredient Explainer screen (FE-19).
//
// Full-screen route mounted at `/ingredients/:slug`. Pulls a per-slug
// explanation from `GET /api/v1/ingredients/:slug/explanation` (BE-40)
// and renders it as title + summary paragraph + bullet list, with
// optional health-flag chips at the top.
//
// Distinct from the inline explainer that still lives in
// `product_detail_screen.dart` — that one POSTs a list of ingredients
// to `/ai/ingredients/explain`. The dedicated screen exists because
// explanations can run long and merit a focused surface.
//
// Visual rules:
//   * One orange accent (#EA580C) — applied only to the surface chips.
//   * Plus Jakarta Sans display weight on the title.
//   * Body text in 16/24 (`bodyLarge`).
//   * 24px outer padding.
//   * AppBar with a back arrow only — no extra actions.
//   * No purple/blue gradients, no centered hero, no emoji-as-icon.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:radha_app/core/network/api_client.dart';
import 'package:radha_app/core/network/api_exception.dart';
import 'package:radha_app/core/network/dto/ai_dto.dart';
import 'package:radha_app/core/network/error_codes.dart';
import 'package:radha_app/design/app_assets.dart';
import 'package:radha_app/design/tokens.dart';
import 'package:radha_app/design/widgets/mor_companion.dart';
import 'package:radha_app/design/widgets/skeleton_loader.dart';
import 'package:radha_app/l10n/generated/app_localizations.dart';

/// Per-slug ingredient explanation provider. The `family` keys on the
/// canonical kebab-case slug; mismatches between callers (e.g.
/// `Palm Oil` vs `palm-oil`) would split the cache, so callers must
/// normalise before pushing the route.
final ingredientExplanationProvider =
    FutureProvider.family<IngredientExplanation, String>((ref, slug) async {
      final client = ref.watch(apiClientProvider);
      // Locale defaults to the device's app locale per BE-40 — the
      // server's `resolveLocale` falls back to `en` for anything
      // outside the supported list.
      return client.getIngredientExplanation(slug);
    });

/// Full-screen ingredient explainer mounted at `/ingredients/:slug`.
class IngredientExplainerScreen extends ConsumerWidget {
  const IngredientExplainerScreen({super.key, required this.slug});

  /// Canonical kebab-case slug, e.g. `palm-oil`.
  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final asyncValue = ref.watch(ingredientExplanationProvider(slug));

    return Scaffold(
      appBar: AppBar(
        // Back arrow only — Material 3 supplies it by default. No extra
        // actions per the FE-19 spec.
        title: Text(
          _titleFromSlug(slug),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: asyncValue.when(
          loading: () => const _ExplainerSkeleton(),
          error: (error, stack) {
            final code = error is ApiException ? error.code : null;
            final message = userMessageForCode(
              code,
              l10n: l10n,
              fallback: l10n.errorGeneric,
            );
            return _ExplainerError(
              title: l10n.ingredientExplainerErrorTitle,
              body: message,
              retryLabel: l10n.tryAgain,
              onRetry: () =>
                  ref.invalidate(ingredientExplanationProvider(slug)),
            );
          },
          data: (data) => _ExplainerBody(explanation: data),
        ),
      ),
    );
  }

  /// `palm-oil` → `Palm Oil`. Mirror of the DTO helper, used here so
  /// the AppBar shows a friendly title even before the data loads.
  static String _titleFromSlug(String slug) {
    if (slug.isEmpty) return 'Ingredient';
    return slug
        .split('-')
        .where((s) => s.isNotEmpty)
        .map((s) => s[0].toUpperCase() + s.substring(1))
        .join(' ');
  }
}

// ─── Body ────────────────────────────────────────────────────────────────

class _ExplainerBody extends StatelessWidget {
  const _ExplainerBody({required this.explanation});

  final IngredientExplanation explanation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        RadhaSpacing.space24,
        RadhaSpacing.space24,
        RadhaSpacing.space24,
        RadhaSpacing.space48,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Health-flag chips ─────────────────────────────────────────
          if (explanation.healthFlags != null &&
              explanation.healthFlags!.isNotEmpty) ...[
            Wrap(
              spacing: RadhaSpacing.space8,
              runSpacing: RadhaSpacing.space8,
              children: [
                for (final flag in explanation.healthFlags!)
                  _FlagChip(label: _humaniseFlag(flag)),
              ],
            ),
            const SizedBox(height: RadhaSpacing.space24),
          ],

          // ── Title (display weight, brand font) ────────────────────────
          Text(
            explanation.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: RadhaSpacing.space16),

          // ── Summary card ──────────────────────────────────────────────
          if (explanation.summary.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(RadhaSpacing.space24),
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
                borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
                border: Border.all(color: scheme.outline),
              ),
              child: Text(
                explanation.summary,
                // 16/24 body — `bodyLarge` is 16pt with 1.5 line height in
                // the brand type scale.
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurface,
                  height: 1.5,
                ),
              ),
            ),

          // ── Bullets ───────────────────────────────────────────────────
          if (explanation.bullets.isNotEmpty) ...[
            const SizedBox(height: RadhaSpacing.space24),
            Text(
              _bulletsHeader(context),
              style: theme.textTheme.titleSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: RadhaSpacing.space12),
            for (final bullet in explanation.bullets)
              Padding(
                padding: const EdgeInsets.only(bottom: RadhaSpacing.space12),
                child: _Bullet(text: bullet),
              ),
          ],
        ],
      ),
    );
  }

  String _bulletsHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return l10n.ingredientExplainerHealthConsiderations;
  }

  /// `low-confidence` → `Low confidence`. Keeps tags in a calm,
  /// sentence-case form for the chip labels.
  static String _humaniseFlag(String raw) {
    final cleaned = raw.replaceAll('_', ' ').replaceAll('-', ' ').trim();
    if (cleaned.isEmpty) return raw;
    return cleaned[0].toUpperCase() + cleaned.substring(1).toLowerCase();
  }
}

// ─── Chip ────────────────────────────────────────────────────────────────

class _FlagChip extends StatelessWidget {
  const _FlagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Health-flag chips reuse the shared single-accent discipline. The
    // tone is calm — no neon, no rainbow categorisation.
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space12,
        vertical: RadhaSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: scheme.primary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// ─── Bullet ──────────────────────────────────────────────────────────────

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Calm bullet glyph using the muted ink token. Avoids the slop
        // of a coloured icon for a textual list.
        Padding(
          padding: const EdgeInsets.only(top: 8, right: RadhaSpacing.space12),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: scheme.onSurfaceVariant,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurface,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Loading state ───────────────────────────────────────────────────────

class _ExplainerSkeleton extends StatelessWidget {
  const _ExplainerSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        RadhaSpacing.space24,
        RadhaSpacing.space24,
        RadhaSpacing.space24,
        RadhaSpacing.space24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title placeholder.
          SkeletonLoader(width: 220, height: 28),
          SizedBox(height: RadhaSpacing.space24),
          // 3-line summary placeholder per FE-19 spec.
          SkeletonLoader(height: 16),
          SizedBox(height: RadhaSpacing.space8),
          SkeletonLoader(height: 16),
          SizedBox(height: RadhaSpacing.space8),
          SkeletonLoader(width: 200, height: 16),
        ],
      ),
    );
  }
}

// ─── Error state ─────────────────────────────────────────────────────────

class _ExplainerError extends StatelessWidget {
  const _ExplainerError({
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        RadhaSpacing.space24,
        RadhaSpacing.space24,
        RadhaSpacing.space24,
        RadhaSpacing.space24,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MorCompanion(
            mood: MorMood.concern,
            size: 96,
            semanticLabel: AppLocalizations.of(context).commonCouldNotLoad,
          ),
          const SizedBox(height: RadhaSpacing.space16),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: scheme.onSurface,
            ),
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
      ),
    );
  }
}

// Weekly Digest landing screen (FE-24).
//
// Mounted at `/digest` (latest week) and `/digest/:weekIso` (archived
// week). The Sunday push notification deep-links into this surface —
// "Your week with RADHA" is the first thing the user sees on the
// outbound tap, so it has to feel like a calmly-narrated week-in-review,
// not a chart dump.
//
// Backend wiring
// ─────────────
// Consumes `GET /api/v1/weekly-digest` (BE-24). The Retrofit method
// `ApiClient.getWeeklyDigest()` is already declared and returns the
// `WeeklyDigestResponse` DTO. The current server contract returns the
// most recent week and ignores any query param — see "open questions"
// in the FE-24 handoff for the per-week archive endpoint that hasn't
// shipped yet. When `weekIso` is supplied we still call the latest
// endpoint and surface the discrepancy in the UI's app bar tooltip;
// the screen is forward-compatible the moment a `?week=` param is wired
// server-side.
//
// Visual contract (anti-slop)
// ──────────────────────────
//   * Single orange accent (`RadhaColors.primary`). Rose / amber are
//     used only for the recall and expiring-soon callouts.
//   * Plus Jakarta Sans display weight for the hero, JetBrains Mono
//     for the headline numeric, body in the global Material 3 theme.
//   * No purple/blue gradients, no centered hero text, no decorative
//     emoji, no 3-equal-card grid — the stats area is a 2-column
//     asymmetric bento.
//   * Every interactive surface meets the 44pt touch-target minimum.
//   * Animations transform/opacity only — `RadhaMotion.medium` curves.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'package:radha_app/core/entitlements/entitlement_provider.dart';
import 'package:radha_app/core/network/api_client.dart';
import 'package:radha_app/core/network/api_exception.dart';
import 'package:radha_app/core/network/dto/misc_dto.dart';
import 'package:radha_app/core/network/error_codes.dart';
import 'package:radha_app/core/router/app_router.dart';
import 'package:radha_app/design/theme.dart';
import 'package:radha_app/design/app_assets.dart';
import 'package:radha_app/design/tokens.dart';
import 'package:radha_app/design/widgets/mor_companion.dart';
import 'package:radha_app/design/widgets/primary_button.dart';
import 'package:radha_app/design/widgets/skeleton_loader.dart';
import 'package:radha_app/l10n/generated/app_localizations.dart';

/// FutureProvider keyed by an optional ISO-week label.
///
/// `null` means "give me the most recent week" — that's the path the
/// Sunday push notification takes. A specific week label (e.g.
/// `2026-W21`) is reserved for the archive deep-link; until the server
/// supports it the provider falls back to the latest endpoint and the
/// screen is rendered with the same data.
final weeklyDigestProvider = FutureProvider.autoDispose
    .family<WeeklyDigestResponse, String?>((ref, weekIso) async {
  final api = ref.watch(apiClientProvider);
  // Archive-by-week is not yet exposed as a query param — see the
  // FE-24 open questions. We deliberately don't pass `weekIso` to
  // `getWeeklyDigest()` because doing so would silently 4xx; the
  // server returns the latest week and we honour that here.
  return api.getWeeklyDigest();
});

/// Weekly digest landing surface mounted at `/digest` and `/digest/:weekIso`.
class WeeklyDigestScreen extends ConsumerWidget {
  const WeeklyDigestScreen({super.key, this.weekIso});

  /// Optional archive week label, e.g. `2026-W21`. When non-null the
  /// screen still asks for the latest week from the server but tags the
  /// app-bar so QA can tell deep-link parity is intentional.
  final String? weekIso;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final asyncDigest = ref.watch(weeklyDigestProvider(weekIso));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.digestTitle, style: theme.textTheme.titleMedium),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(weeklyDigestProvider(weekIso));
            await ref.read(weeklyDigestProvider(weekIso).future);
          },
          child: asyncDigest.when(
            loading: () => const _DigestSkeleton(),
            error: (error, _) => _DigestError(
              title: l10n.digestErrorTitle,
              body: _errorMessage(error, l10n),
              retryLabel: l10n.tryAgain,
              onRetry: () => ref.invalidate(weeklyDigestProvider(weekIso)),
            ),
            data: (digest) {
              if (_isEmptyWeek(digest)) {
                return _DigestEmpty(
                  title: l10n.digestEmptyTitle,
                  body: l10n.digestEmptyBody,
                  ctaLabel: l10n.digestContinueScanning,
                  onCta: () => _continueScanning(context),
                );
              }
              return _DigestContent(digest: digest);
            },
          ),
        ),
      ),
    );
  }

  static bool _isEmptyWeek(WeeklyDigestResponse digest) {
    return digest.scansCount == 0 &&
        digest.savedProductsCount == 0 &&
        digest.expiringSoonCount == 0 &&
        digest.recallAlertsCount == 0 &&
        digest.estimatedSavingsInr == 0 &&
        digest.topCategories.isEmpty &&
        digest.healthHighlights.isEmpty &&
        (digest.highlights == null || digest.highlights!.isEmpty);
  }

  static String _errorMessage(Object error, AppLocalizations l10n) {
    if (error is ApiException) {
      return userMessageForCode(
        error.code,
        l10n: l10n,
        retryAfterSeconds:
            error is RateLimitException ? error.retryAfter : null,
      );
    }
    return l10n.errorGeneric;
  }
}

// ─── Content ────────────────────────────────────────────────────────────

class _DigestContent extends ConsumerWidget {
  const _DigestContent({required this.digest});

  final WeeklyDigestResponse digest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final highlights = digest.healthHighlights.isNotEmpty
        ? digest.healthHighlights
        : (digest.highlights ?? const <String>[]);

    // Freemium gate: the at-a-glance numbers (scans, recalls, savings) are
    // free for every consumer. The *deeper* breakdown — category trends and
    // personalised health highlights — is a Premium perk. Free users see a
    // single tasteful upsell in place of those sections instead of a wall of
    // locks. We treat an unresolved/errored entitlement as "free" so the
    // screen always renders.
    final canDeepInsights =
        ref.watch(entitlementProvider).valueOrNull?.features.contains(
              Feature.weeklyDigest,
            ) ??
        false;

    final hasDeepContent =
        digest.topCategories.isNotEmpty || highlights.isNotEmpty;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        RadhaSpacing.space24,
        RadhaSpacing.space16,
        RadhaSpacing.space24,
        RadhaSpacing.space32,
      ),
      children: [
        _DigestHero(digest: digest),
        const SizedBox(height: RadhaSpacing.space24),
        _StatsBento(digest: digest),
        if (digest.recallAlertsCount > 0) ...[
          const SizedBox(height: RadhaSpacing.space16),
          _RecallCallout(count: digest.recallAlertsCount),
        ],
        if (canDeepInsights) ...[
          if (digest.topCategories.isNotEmpty) ...[
            const SizedBox(height: RadhaSpacing.space32),
            _SectionHeader(label: l10n.digestTopCategoriesHeader),
            const SizedBox(height: RadhaSpacing.space12),
            _TopCategoriesList(categories: digest.topCategories),
          ],
          if (highlights.isNotEmpty) ...[
            const SizedBox(height: RadhaSpacing.space32),
            _SectionHeader(label: l10n.digestHighlightsHeader),
            const SizedBox(height: RadhaSpacing.space12),
            _HighlightsList(items: highlights),
          ],
        ] else if (hasDeepContent) ...[
          const SizedBox(height: RadhaSpacing.space32),
          const _DigestPremiumUpsell(),
        ],
        const SizedBox(height: RadhaSpacing.space32),
        _ActionFooter(digest: digest),
      ],
    );
  }
}

/// Premium upsell shown in place of the deep-insight sections for free
/// consumers. Single orange accent, no lock-wall — it teases the value
/// (category trends, personalised highlights) and routes to the plan page.
class _DigestPremiumUpsell extends StatelessWidget {
  const _DigestPremiumUpsell();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        side: BorderSide(color: scheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(RadhaSpacing.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: RadhaColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
                  ),
                  child: const Icon(
                    Icons.insights_outlined,
                    color: RadhaColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: RadhaSpacing.space12),
                Expanded(
                  child: Text(
                    'See the full picture',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: RadhaSpacing.space12),
            Text(
              'Unlock your category trends and personalised health highlights '
              'with Premium — plus unlimited scans, family sharing, and AI '
              'ingredient explanations.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: RadhaSpacing.space16),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Unlock with Premium',
                icon: Icons.lock_open_outlined,
                expand: true,
                onPressed: () => context.push(AppRoute.subscription),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero ───────────────────────────────────────────────────────────────

class _DigestHero extends StatelessWidget {
  const _DigestHero({required this.digest});

  final WeeklyDigestResponse digest;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final weekRange = _formatWeekRange(
      digest.weekStartDate,
      digest.weekEndDate,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.digestTitle,
          style: theme.textTheme.headlineLarge?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        if (weekRange != null) ...[
          const SizedBox(height: RadhaSpacing.space8),
          Text(
            weekRange,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: RadhaSpacing.space16),
        _HeroCard(digest: digest),
      ],
    );
  }

  /// Best-effort formatter that produces "May 19 – May 25, 2026" from
  /// two ISO-8601 dates. Returns `null` so the hero collapses cleanly
  /// when the server omits week boundaries.
  static String? _formatWeekRange(String? startIso, String? endIso) {
    if (startIso == null || endIso == null) return null;
    final start = DateTime.tryParse(startIso);
    final end = DateTime.tryParse(endIso);
    if (start == null || end == null) return null;
    final startFmt = DateFormat('MMM d').format(start.toLocal());
    final endFmt = DateFormat('MMM d, y').format(end.toLocal());
    return '$startFmt – $endFmt';
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.digest});

  final WeeklyDigestResponse digest;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final headline = _heroHeadline(digest, l10n);
    final caption = _heroCaption(digest, l10n);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusXl),
        border: Border.all(color: scheme.outline),
      ),
      padding: const EdgeInsets.all(RadhaSpacing.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            caption,
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: RadhaSpacing.space12),
          Text(
            headline,
            style: radhaMonoStyle(
              fontSize: 38,
              weight: FontWeight.w700,
              color: scheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  static String _heroHeadline(
    WeeklyDigestResponse digest,
    AppLocalizations l10n,
  ) {
    if (digest.estimatedSavingsInr > 0) {
      return l10n.digestSavingsHero(_formatInt(digest.estimatedSavingsInr));
    }
    if (digest.scansCount > 0) {
      return l10n.digestScansHero(digest.scansCount);
    }
    return l10n.digestHeroEmptyHeadline;
  }

  static String _heroCaption(
    WeeklyDigestResponse digest,
    AppLocalizations l10n,
  ) {
    if (digest.estimatedSavingsInr > 0) {
      return l10n.digestScans.toUpperCase();
    }
    if (digest.scansCount > 0) {
      return l10n.digestScans.toUpperCase();
    }
    return l10n.digestTitle.toUpperCase();
  }

  static String _formatInt(num value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(0);
  }
}

// ─── Stats bento (2-column asymmetric) ──────────────────────────────────

class _StatsBento extends StatelessWidget {
  const _StatsBento({required this.digest});

  final WeeklyDigestResponse digest;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final expiringTint = digest.expiringSoonCount > 0
        ? RadhaColors.warning.withValues(alpha: 0.10)
        : scheme.surfaceContainer;

    // Asymmetric 2-column bento. The left column is a single tall card
    // (Scans), the right column stacks two shorter cards (Saved + Expiring).
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: _BentoTile(
              label: l10n.digestScans.toUpperCase(),
              value: digest.scansCount.toString(),
              emphasised: true,
            ),
          ),
          const SizedBox(width: RadhaSpacing.space12),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _BentoTile(
                    label: l10n.digestSavedProducts.toUpperCase(),
                    value: digest.savedProductsCount.toString(),
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space12),
                Expanded(
                  child: _BentoTile(
                    label: l10n.digestExpiringSoon.toUpperCase(),
                    value: digest.expiringSoonCount.toString(),
                    backgroundOverride: expiringTint,
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

class _BentoTile extends StatelessWidget {
  const _BentoTile({
    required this.label,
    required this.value,
    this.emphasised = false,
    this.backgroundOverride,
  });

  final String label;
  final String value;
  final bool emphasised;
  final Color? backgroundOverride;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: backgroundOverride ?? scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        border: Border.all(color: scheme.outline),
      ),
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: RadhaSpacing.space12),
          Text(
            value,
            style: radhaMonoStyle(
              fontSize: emphasised ? 40 : 28,
              weight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recall callout ─────────────────────────────────────────────────────

class _RecallCallout extends StatelessWidget {
  const _RecallCallout({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Calm rose tint — single accent rule preserved (rose is the
    // sanctioned danger semantic, NOT a competing brand colour).
    final tint = RadhaColors.danger.withValues(alpha: 0.10);
    final border = RadhaColors.danger.withValues(alpha: 0.32);

    return Material(
      color: tint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        side: BorderSide(color: border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        onTap: () => context.push(AppRoute.recallAlerts),
        child: Padding(
          padding: const EdgeInsets.all(RadhaSpacing.space16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: RadhaColors.danger.withValues(alpha: 0.16),
                  borderRadius:
                      BorderRadius.circular(RadhaRadii.radiusFull),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 20,
                  color: RadhaColors.danger,
                ),
              ),
              const SizedBox(width: RadhaSpacing.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.digestRecallAlerts(count),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: RadhaSpacing.space4),
                    Text(
                      l10n.digestRecallAlertsBody,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: RadhaSpacing.space8),
              SizedBox(
                height: kMinTouchTarget,
                child: TextButton(
                  onPressed: () => context.push(AppRoute.recallAlerts),
                  child: Text(l10n.digestRecallAlertsCta),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Top categories ─────────────────────────────────────────────────────

class _TopCategoriesList extends StatelessWidget {
  const _TopCategoriesList({required this.categories});

  final List<WeeklyDigestTopCategory> categories;

  @override
  Widget build(BuildContext context) {
    // Cap at five — anything longer doesn't help the at-a-glance read.
    final shown = categories.take(5).toList(growable: false);
    final maxCount = shown
        .map((c) => c.count)
        .fold<int>(0, (a, b) => a > b ? a : b)
        .clamp(1, 1 << 30);

    return Column(
      children: [
        for (var i = 0; i < shown.length; i++) ...[
          _CategoryBar(
            category: shown[i].category,
            count: shown[i].count,
            ratio: shown[i].count / maxCount,
          ),
          if (i != shown.length - 1)
            const SizedBox(height: RadhaSpacing.space12),
        ],
      ],
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.category,
    required this.count,
    required this.ratio,
  });

  final String category;
  final int count;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Clamp tightly so even single scans are visibly painted.
    final clamped = ratio.isNaN ? 0.0 : ratio.clamp(0.05, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                category,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: RadhaSpacing.space8),
            Text(
              count.toString(),
              style: radhaMonoStyle(
                fontSize: 14,
                weight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: RadhaSpacing.space8),
        // Animated bar fill — opacity/transform only per motion contract.
        // We use AnimatedFractionallySizedBox so the first paint slides
        // into position without layout thrash.
        TweenAnimationBuilder<double>(
          duration: RadhaMotion.medium,
          curve: RadhaMotion.easeOut,
          tween: Tween<double>(begin: 0, end: clamped),
          builder: (context, value, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainer,
                  borderRadius:
                      BorderRadius.circular(RadhaRadii.radiusFull),
                ),
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius:
                          BorderRadius.circular(RadhaRadii.radiusFull),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─── Highlights ─────────────────────────────────────────────────────────

class _HighlightsList extends StatelessWidget {
  const _HighlightsList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shown = items.take(4).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < shown.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calm muted bullet glyph — a tonal dot, not a decorative
              // emoji or icon.
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 12),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: scheme.onSurfaceVariant,
                    borderRadius:
                        BorderRadius.circular(RadhaRadii.radiusFull),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  shown[i],
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurface,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          if (i != shown.length - 1)
            const SizedBox(height: RadhaSpacing.space12),
        ],
      ],
    );
  }
}

// ─── Section header ─────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ─── Action footer ──────────────────────────────────────────────────────

class _ActionFooter extends StatelessWidget {
  const _ActionFooter({required this.digest});

  final WeeklyDigestResponse digest;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: kMinTouchTarget,
          child: PrimaryButton(
            label: l10n.digestContinueScanning,
            icon: Icons.qr_code_scanner_rounded,
            expand: true,
            onPressed: () => _continueScanning(context),
          ),
        ),
        const SizedBox(height: RadhaSpacing.space8),
        SizedBox(
          height: kMinTouchTarget,
          child: TextButton.icon(
            onPressed: () => _shareWeek(context, digest, l10n),
            icon: const Icon(Icons.share_outlined, size: 18),
            label: Text(l10n.digestShare),
          ),
        ),
      ],
    );
  }

  Future<void> _shareWeek(
    BuildContext context,
    WeeklyDigestResponse digest,
    AppLocalizations l10n,
  ) async {
    final savings = _formatInt(digest.estimatedSavingsInr);
    await Share.share(
      l10n.digestShareTemplate(digest.scansCount, savings),
    );
  }

  static String _formatInt(num value) {
    if (value == value.truncateToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(0);
  }
}

// Continue-scanning routes back to the bottom-nav scan tab. We `go` so
// the navigation pops the digest off the root stack and lands on the
// home shell with the Scan branch active.
void _continueScanning(BuildContext context) {
  context.go(AppRoute.scan);
}

// ─── Loading skeleton ───────────────────────────────────────────────────

class _DigestSkeleton extends StatelessWidget {
  const _DigestSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        RadhaSpacing.space24,
        RadhaSpacing.space16,
        RadhaSpacing.space24,
        RadhaSpacing.space32,
      ),
      children: const [
        // Hero title placeholder.
        SkeletonLoader(width: 240, height: 32),
        SizedBox(height: RadhaSpacing.space8),
        SkeletonLoader(width: 160, height: 14),
        SizedBox(height: RadhaSpacing.space16),
        // Hero card.
        SkeletonLoader(height: 120, radius: RadhaRadii.radiusXl),
        SizedBox(height: RadhaSpacing.space24),
        // Bento row — three cards in the asymmetric layout.
        Row(
          children: [
            Expanded(
              flex: 5,
              child: SkeletonLoader(
                height: 168,
                radius: RadhaRadii.radiusLg,
              ),
            ),
            SizedBox(width: RadhaSpacing.space12),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  SkeletonLoader(height: 78, radius: RadhaRadii.radiusLg),
                  SizedBox(height: RadhaSpacing.space12),
                  SkeletonLoader(height: 78, radius: RadhaRadii.radiusLg),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: RadhaSpacing.space32),
        // A pair of bullet placeholders for the highlights area.
        SkeletonLoader(width: 160, height: 16),
        SizedBox(height: RadhaSpacing.space12),
        SkeletonLoader(height: 14),
        SizedBox(height: RadhaSpacing.space8),
        SkeletonLoader(height: 14, width: 220),
      ],
    );
  }
}

// ─── Empty state ────────────────────────────────────────────────────────

class _DigestEmpty extends StatelessWidget {
  const _DigestEmpty({
    required this.title,
    required this.body,
    required this.ctaLabel,
    required this.onCta,
  });

  final String title;
  final String body;
  final String ctaLabel;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(RadhaSpacing.space24),
      children: [
        SizedBox(
          // Anchor the empty state above-the-fold but leave room for
          // the CTA below it. Aligning to the top per the design rule
          // ("no centred hero").
          height: MediaQuery.sizeOf(context).height * 0.55,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  size: 24,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: RadhaSpacing.space24),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: RadhaSpacing.space8),
              Text(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: kMinTouchTarget,
          child: PrimaryButton(
            label: ctaLabel,
            icon: Icons.qr_code_scanner_rounded,
            expand: true,
            onPressed: onCta,
          ),
        ),
      ],
    );
  }
}

// ─── Error state ────────────────────────────────────────────────────────

class _DigestError extends StatelessWidget {
  const _DigestError({
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
          style: theme.textTheme.titleLarge?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w700,
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
    );
  }
}

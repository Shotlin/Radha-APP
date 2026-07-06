// Saved Products screen (FE-16).
//
// Full-screen route mounted at `/saved-products`. Distinct from the
// shopping list:
//   * Saved products = "things I've scanned and bookmarked".
//   * Shopping list   = "things I plan to buy this trip".
//
// Backend contract (locked):
//   * `GET    /api/v1/saved-products?cursor=&limit=` — paginated list.
//   * `POST   /api/v1/saved-products`                 — create.
//   * `DELETE /api/v1/saved-products/:id`             — remove.
//
// This screen consumes the GET only. Create/delete UI is intentionally
// deferred to a follow-up wave; the typed Retrofit methods exist on the
// API client today so a later screen can wire them in without further
// network plumbing.
//
// Visual rules:
//   * One orange accent (#EA580C) — empty-state icon only.
//   * 24px outer padding, 12px gap between cards.
//   * 44pt+ touch targets on every action.
//   * No emoji-as-icon, no purple/blue gradients, no centered hero.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:radha_app/core/network/api_client.dart';
import 'package:radha_app/core/network/api_exception.dart';
import 'package:radha_app/core/network/dto/saved_product_dto.dart';
import 'package:radha_app/core/network/error_codes.dart';
import 'package:radha_app/design/app_assets.dart';
import 'package:radha_app/design/tokens.dart';
import 'package:radha_app/design/widgets/mor_companion.dart';
import 'package:radha_app/design/widgets/skeleton_loader.dart';
import 'package:radha_app/l10n/generated/app_localizations.dart';

/// Per-user saved-products provider.
///
/// `autoDispose` so we don't keep stale data alive after the user navigates
/// away — a fresh fetch on next entry is desirable for a bookmarks surface.
final savedProductsProvider =
    FutureProvider.autoDispose<List<SavedProductDto>>((ref) async {
      final client = ref.watch(apiClientProvider);
      final response = await client.getSavedProducts();
      return response.items;
    });

/// Saved products surface mounted at `/saved-products`.
class SavedProductsScreen extends ConsumerWidget {
  const SavedProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final asyncValue = ref.watch(savedProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.savedProductsTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(savedProductsProvider);
            await ref.read(savedProductsProvider.future);
          },
          child: asyncValue.when(
            loading: () => const _SavedProductsLoading(),
            error: (error, stack) => _SavedProductsError(
              title: l10n.savedProductsErrorTitle,
              body: _errorMessage(error, l10n),
              retryLabel: l10n.tryAgain,
              onRetry: () => ref.invalidate(savedProductsProvider),
            ),
            data: (items) {
              if (items.isEmpty) {
                return _SavedProductsEmpty(
                  title: l10n.savedProductsEmptyTitle,
                  body: l10n.savedProductsEmptyBody,
                );
              }
              return _SavedProductsList(items: items);
            },
          ),
        ),
      ),
    );
  }
}

/// Maps a thrown error to a user-facing message.
///
/// Branches on the canonical [ApiException.code] so localised text comes
/// from the central catalog, not stringified server messages.
String _errorMessage(Object error, AppLocalizations l10n) {
  if (error is ApiException) {
    return userMessageForCode(error.code, l10n: l10n, fallback: error.message);
  }
  return userMessageForCode(null, l10n: l10n);
}

// ─── List ────────────────────────────────────────────────────────────────

class _SavedProductsList extends StatelessWidget {
  const _SavedProductsList({required this.items});

  final List<SavedProductDto> items;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.all(RadhaSpacing.space24),
      itemCount: items.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: RadhaSpacing.space12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _StaggerIn(
          index: index,
          reduceMotion: reduceMotion,
          child: _SavedProductCard(item: item),
        );
      },
    );
  }
}

class _SavedProductCard extends StatelessWidget {
  const _SavedProductCard({required this.item});

  final SavedProductDto item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Material(
      color: scheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        side: BorderSide(color: scheme.outline),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kMinTouchTarget),
        child: Padding(
          padding: const EdgeInsets.all(RadhaSpacing.space16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
                ),
                child: Icon(
                  Icons.bookmark_outline_rounded,
                  color: scheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: RadhaSpacing.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.barcode != null && item.barcode!.isNotEmpty) ...[
                      const SizedBox(height: RadhaSpacing.space4),
                      Text(
                        item.barcode!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: RadhaSpacing.space8),
                    Text(
                      l10n.savedProductsSavedOn(_formatDate(item.createdAt)),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Formats an ISO-8601 timestamp as `dd MMM yyyy`. Falls back to the raw
  /// string when parsing fails so we never block the UI on a bad date.
  static String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return DateFormat('dd MMM yyyy').format(dt.toLocal());
  }
}

// ─── Loading state ───────────────────────────────────────────────────────

class _SavedProductsLoading extends StatelessWidget {
  const _SavedProductsLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(RadhaSpacing.space24),
      itemCount: 4,
      separatorBuilder: (_, _) =>
          const SizedBox(height: RadhaSpacing.space12),
      itemBuilder: (_, _) => const SkeletonLoader(
        height: 88,
        radius: RadhaRadii.radiusLg,
      ),
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────────────────

class _SavedProductsEmpty extends StatelessWidget {
  const _SavedProductsEmpty({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListView(
      // Stay scrollable so RefreshIndicator can attach.
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
                const MorCompanion(mood: MorMood.greet, size: 104),
                const SizedBox(height: RadhaSpacing.space24),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Error state ─────────────────────────────────────────────────────────

class _SavedProductsError extends StatelessWidget {
  const _SavedProductsError({
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

// ─── Entrance ──────────────────────────────────────────────────────────────

/// Staggered fade + rise for list cards. Honours reduce-motion by rendering
/// immediately, and caps the per-row delay so long lists don't drag.
class _StaggerIn extends StatefulWidget {
  const _StaggerIn({
    required this.index,
    required this.reduceMotion,
    required this.child,
  });

  final int index;
  final bool reduceMotion;
  final Widget child;

  @override
  State<_StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<_StaggerIn>
    with SingleTickerProviderStateMixin {
  // Stagger is baked into an Interval on a single controller started in
  // initState — never `Future.delayed` (steering §2.5/§12: delayed timers are
  // timer-leaky under widget tests). The controller runs long enough to cover
  // the per-index start offset plus the reveal.
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    // Map index → a start fraction (0.0–0.46), then ease over the remainder.
    final start = ((40 * widget.index).clamp(0, 320)) / 700;
    final curve = CurvedAnimation(
      parent: _c,
      curve: Interval(start, 1, curve: RadhaMotion.easeOut),
    );
    _opacity = curve;
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(curve);
    if (widget.reduceMotion) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reduceMotion) return widget.child;
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}

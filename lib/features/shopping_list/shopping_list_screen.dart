// Shopping list surface (Task 18 / BE-55).
//
// A consumer-facing list of items the user wants to buy. Items can be:
//   * added via a "+" CTA that opens a bottom sheet (free-typed name + qty),
//   * checked off (PATCH `/shopping-list/items/{id}` with `checked: true`),
//   * uncheked (PATCH with `checked: false`),
//   * deleted (DELETE `/shopping-list/items/{id}`, also via swipe-to-dismiss).
//
// The full list is read on entry via `GET /shopping-list` and stored in a
// `FutureProvider`. Every mutation invalidates the provider so the UI stays
// authoritative against the server response.
//
// Visual rules:
//   * One orange accent (#EA580C) — only the "checked" state and the add CTA
//     are coloured. Everything else stays neutral. (Anti-slop discipline.)
//   * Strikethrough + muted text for checked items, with an animated cross-fade.
//   * 44pt+ touch targets on the checkbox, delete button, and add CTA.
//   * Skeleton loaders, staggered entrance, tactile press feedback, and
//     reduce-motion awareness, matching the rest of the app.
//
// External anchors:
//   * Backend endpoints: BE-55 (`server/src/modules/shopping-list/...`).
//   * Add-from-product-detail flow: `_HealthyAlternativesSection` in
//     `lib/features/product/product_detail_screen.dart`.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:radha_app/core/network/api_client.dart';
import 'package:radha_app/core/network/dto/misc_dto.dart';
import 'package:radha_app/design/app_assets.dart';
import 'package:radha_app/design/theme.dart';
import 'package:radha_app/design/tokens.dart';
import 'package:radha_app/design/widgets/empty_state.dart';
import 'package:radha_app/design/widgets/mor_companion.dart';
import 'package:radha_app/design/widgets/primary_button.dart';
import 'package:radha_app/l10n/generated/app_localizations.dart';

/// The user's default shopping list ID. Creates one if none exists.
/// Exposed so other screens (product detail, alternatives) can add items
/// without duplicating the get-or-create logic.
final defaultShoppingListIdProvider = FutureProvider.autoDispose<String>((
  ref,
) async {
  final client = ref.watch(apiClientProvider);
  final lists = await client.getShoppingLists();
  if (lists.isNotEmpty) return lists.first.id;
  final created = await client.createShoppingList(
    const CreateShoppingListDto(name: 'Shopping List'),
  );
  return created.id;
});

/// FutureProvider for the shopping list screen.
/// Resolves the default list, then fetches its items.
final shoppingListProvider = FutureProvider.autoDispose<ShoppingListResponse>((
  ref,
) async {
  final listId = await ref.watch(defaultShoppingListIdProvider.future);
  final client = ref.watch(apiClientProvider);
  final detail = await client.getShoppingListDetail(listId);
  return ShoppingListResponse(listId: listId, items: detail.items);
});

/// Top-level shopping list surface mounted at `/shopping-list`. Renders the
/// items returned by [shoppingListProvider] with checkbox / delete / add
/// affordances, and surfaces a friendly empty state.
class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  /// Tracks per-item in-flight mutations so we can disable the row while a
  /// PATCH/DELETE is racing. Keyed by item id.
  final Set<String> _busyItemIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final listAsync = ref.watch(shoppingListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.shoppingListTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          _openAddSheet(context);
        },
        tooltip: l10n.shoppingAddItem,
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.shoppingAddItem),
      ),
      body: listAsync.when(
        loading: () => const _ShoppingSkeleton(),
        error: (_, _) => _buildError(context),
        data: (response) => _buildList(context, response),
      ),
    );
  }

  // ── Body builders ─────────────────────────────────────────────────────

  Widget _buildError(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(RadhaSpacing.space24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MorCompanion(
            mood: MorMood.concern,
            size: 96,
            semanticLabel: l10n.commonCouldNotLoad,
          ),
          const SizedBox(height: RadhaSpacing.space16),
          Text(l10n.shoppingLoadError, style: theme.textTheme.titleMedium),
          const SizedBox(height: RadhaSpacing.space8),
          Text(
            l10n.shoppingLoadErrorBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: RadhaSpacing.space24),
          PrimaryButton(
            label: l10n.tryAgain,
            icon: Icons.refresh,
            onPressed: () => ref.invalidate(shoppingListProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, ShoppingListResponse response) {
    final items = _sortItems(response.items);
    final l10n = AppLocalizations.of(context);
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => ref.refresh(shoppingListProvider.future),
        child: ListView(
          // ListView (rather than Center) so RefreshIndicator can attach to
          // a scrollable surface even on the empty state.
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.6,
              child: EmptyState(
                illustration: const MorCompanion(
                  mood: MorMood.greet,
                  size: 104,
                ),
                title: l10n.shoppingEmptyTitle,
                body: l10n.shoppingEmptyBody,
                actionLabel: l10n.shoppingAddItem,
                actionIcon: Icons.add,
                onAction: () => _openAddSheet(context),
              ),
            ),
          ],
        ),
      );
    }

    final remaining = items.where((i) => !i.checked).length;

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(shoppingListProvider.future),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(
          RadhaSpacing.space16,
          RadhaSpacing.space16,
          RadhaSpacing.space16,
          // Leave room for the FAB so the last card never tucks under it.
          RadhaSpacing.space64 + RadhaSpacing.space24,
        ),
        itemCount: items.length + 1,
        separatorBuilder: (_, _) =>
            const SizedBox(height: RadhaSpacing.space12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _ProgressHeader(total: items.length, remaining: remaining);
          }
          final item = items[index - 1];
          return _StaggerIn(
            index: index - 1,
            reduceMotion: reduceMotion,
            child: _ShoppingListRow(
              key: ValueKey(item.id),
              item: item,
              busy: _busyItemIds.contains(item.id),
              reduceMotion: reduceMotion,
              onToggle: (checked) => _toggleChecked(item, checked),
              onDelete: () => _deleteItem(item),
            ),
          );
        },
      ),
    );
  }

  /// Sorts unchecked items first (preserving server order within each
  /// bucket), checked items at the bottom. The backend currently returns
  /// rows in creation order; sorting on the client lets us promote in-progress
  /// shopping items to the top without round-tripping.
  List<ShoppingListItemResponse> _sortItems(
    List<ShoppingListItemResponse> items,
  ) {
    final unchecked = items.where((i) => !i.checked).toList();
    final checked = items.where((i) => i.checked).toList();
    return [...unchecked, ...checked];
  }

  // ── Mutations ─────────────────────────────────────────────────────────

  Future<void> _toggleChecked(
    ShoppingListItemResponse item,
    bool checked,
  ) async {
    if (_busyItemIds.contains(item.id)) return;
    final listId = ref.read(shoppingListProvider).value?.listId;
    if (listId == null) return;
    HapticFeedback.selectionClick();
    setState(() => _busyItemIds.add(item.id));
    try {
      final client = ref.read(apiClientProvider);
      await client.updateShoppingListItem(
        listId,
        item.id,
        UpdateShoppingListItemDto(isPurchased: checked),
      );
      if (!mounted) return;
      ref.invalidate(shoppingListProvider);
    } catch (_) {
      if (!mounted) return;
      _showSnack(AppLocalizations.of(context).shoppingUpdateError);
    } finally {
      if (mounted) {
        setState(() => _busyItemIds.remove(item.id));
      }
    }
  }

  Future<void> _deleteItem(ShoppingListItemResponse item) async {
    if (_busyItemIds.contains(item.id)) return;
    final listId = ref.read(shoppingListProvider).value?.listId;
    if (listId == null) return;
    setState(() => _busyItemIds.add(item.id));
    try {
      final client = ref.read(apiClientProvider);
      await client.deleteShoppingListItem(listId, item.id);
      if (!mounted) return;
      ref.invalidate(shoppingListProvider);
    } catch (_) {
      if (!mounted) return;
      _showSnack(AppLocalizations.of(context).shoppingDeleteError);
    } finally {
      if (mounted) {
        setState(() => _busyItemIds.remove(item.id));
      }
    }
  }

  Future<void> _openAddSheet(BuildContext context) async {
    final addErrorMessage = AppLocalizations.of(context).shoppingAddError;
    final listId = ref.read(shoppingListProvider).value?.listId;
    final result = await showModalBottomSheet<_AddItemResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddItemSheet(),
    );
    if (result == null || !mounted) return;
    if (listId == null) {
      _showSnack(addErrorMessage);
      return;
    }

    try {
      final client = ref.read(apiClientProvider);
      await client.addShoppingListItem(
        listId,
        ShoppingListItemDto(
          item: result.name,
          quantity: result.quantity?.toString(),
        ),
      );
      if (!mounted) return;
      HapticFeedback.lightImpact();
      ref.invalidate(shoppingListProvider);
    } catch (_) {
      if (!mounted) return;
      _showSnack(addErrorMessage);
    }
  }

  /// Surfaces a snackbar through the State's own context so the linter can
  /// verify the `mounted` guard against the same widget instance that owns
  /// the messenger.
  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

// ─── Progress header ─────────────────────────────────────────────────────

/// Compact summary that turns the list into a live task: how many items are
/// still to buy, with an animated progress bar in the orange accent.
class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.total, required this.remaining});

  final int total;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final done = total - remaining;
    final fraction = total == 0 ? 0.0 : done / total;

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
            children: [
              Expanded(
                child: Text(
                  remaining == 0
                      ? l10n.shoppingAllDone
                      : l10n.shoppingRemaining(remaining, total),
                  style: theme.textTheme.titleSmall,
                ),
              ),
              Text(
                '$done/$total',
                style: radhaMonoStyle(
                  fontSize: 13,
                  weight: FontWeight.w600,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: RadhaSpacing.space12),
          ClipRRect(
            borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: fraction),
              duration: RadhaMotion.slow,
              curve: RadhaMotion.easeOut,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: scheme.surfaceContainerLow,
                valueColor: AlwaysStoppedAnimation<Color>(
                  remaining == 0 ? RadhaColors.success : scheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Row widget ────────────────────────────────────────────────────────────

/// Single shopping-list row. Layout:
///
///   [ check ]  Name (strikethrough if checked)            [ delete ]
///              Qty: 2
///
/// Swipe left-to-right or right-to-left dismisses the row (delete). The row
/// animates its checked state with an opacity + strikethrough cross-fade.
class _ShoppingListRow extends StatelessWidget {
  const _ShoppingListRow({
    super.key,
    required this.item,
    required this.busy,
    required this.reduceMotion,
    required this.onToggle,
    required this.onDelete,
  });

  final ShoppingListItemResponse item;
  final bool busy;
  final bool reduceMotion;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final mutedColor = scheme.onSurfaceVariant;

    final nameStyle = theme.textTheme.bodyLarge?.copyWith(
      decoration: item.checked ? TextDecoration.lineThrough : null,
      color: item.checked ? mutedColor : scheme.onSurface,
    );

    final qtyStyle = theme.textTheme.bodySmall?.copyWith(color: mutedColor);

    final card = AnimatedContainer(
      duration: RadhaMotion.medium,
      curve: RadhaMotion.easeOut,
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space12,
        vertical: RadhaSpacing.space8,
      ),
      decoration: BoxDecoration(
        color: item.checked
            ? scheme.surfaceContainerLow
            : scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        border: Border.all(color: scheme.outline, width: 1),
      ),
      child: Row(
        children: [
          // Checkbox (44pt+ touch target enforced via SizedBox).
          SizedBox(
            width: kMinTouchTarget,
            height: kMinTouchTarget,
            child: Checkbox(
              value: item.checked,
              onChanged: busy ? null : (v) => onToggle(v ?? !item.checked),
              activeColor: scheme.primary,
            ),
          ),
          const SizedBox(width: RadhaSpacing.space8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedDefaultTextStyle(
                  duration: RadhaMotion.fast,
                  style: nameStyle ?? const TextStyle(),
                  child: Text(item.name),
                ),
                if (item.quantity != null && item.quantity! > 0) ...[
                  const SizedBox(height: RadhaSpacing.space2),
                  Text(l10n.shoppingQty(item.quantity!), style: qtyStyle),
                ],
              ],
            ),
          ),
          if (busy)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: RadhaSpacing.space12),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            // Delete button (44pt+ via IconButton default constraints).
            IconButton(
              tooltip: l10n.shoppingDeleteItem,
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline, color: mutedColor),
            ),
        ],
      ),
    );

    // Swipe-to-delete with a danger-tinted background reveal.
    return Dismissible(
      key: ValueKey('dismiss-${item.id}'),
      direction: busy ? DismissDirection.none : DismissDirection.horizontal,
      onDismissed: (_) => onDelete(),
      background: _dismissBackground(context, alignLeft: true),
      secondaryBackground: _dismissBackground(context, alignLeft: false),
      child: card,
    );
  }

  Widget _dismissBackground(BuildContext context, {required bool alignLeft}) {
    return Container(
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: RadhaSpacing.space24),
      decoration: BoxDecoration(
        color: RadhaColors.danger.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
      ),
      child: const Icon(Icons.delete_outline, color: RadhaColors.danger),
    );
  }
}

// ─── Add item sheet ────────────────────────────────────────────────────────

/// Bottom-sheet payload returned by [_AddItemSheet] on confirm. `quantity`
/// is null when the user leaves it blank.
class _AddItemResult {
  const _AddItemResult({required this.name, this.quantity});

  final String name;
  final int? quantity;
}

class _AddItemSheet extends StatefulWidget {
  const _AddItemSheet();

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final qtyText = _quantityController.text.trim();
    Navigator.of(context).pop(
      _AddItemResult(
        name: _nameController.text.trim(),
        quantity: qtyText.isEmpty ? null : int.tryParse(qtyText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          RadhaSpacing.space24,
          RadhaSpacing.space16,
          RadhaSpacing.space24,
          RadhaSpacing.space24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.shoppingAddItem,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: RadhaSpacing.space16),
              TextFormField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.shoppingItemNameLabel,
                  hintText: l10n.shoppingItemNameHint,
                ),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return l10n.shoppingItemNameRequired;
                  if (v.length > 120) return l10n.shoppingItemNameTooLong;
                  return null;
                },
              ),
              const SizedBox(height: RadhaSpacing.space16),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l10n.shoppingQuantityLabel,
                  hintText: '1',
                ),
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return null;
                  final n = int.tryParse(v);
                  if (n == null || n < 1) return l10n.shoppingQuantityInvalid;
                  if (n > 9999) return l10n.shoppingQuantityTooHigh;
                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: RadhaSpacing.space24),
              PrimaryButton(
                label: l10n.shoppingAddToList,
                icon: Icons.check,
                onPressed: _submit,
                expand: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Skeleton + entrance ───────────────────────────────────────────────────

/// Skeleton list shown while the shopping list loads. Mirrors the row layout.
class _ShoppingSkeleton extends StatelessWidget {
  const _ShoppingSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(height: RadhaSpacing.space12),
      itemBuilder: (_, _) => Container(
        height: 64,
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
          border: Border.all(color: scheme.outline),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: RadhaSpacing.space16,
          vertical: RadhaSpacing.space12,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(RadhaRadii.radiusXs),
              ),
            ),
            const SizedBox(width: RadhaSpacing.space16),
            Expanded(
              child: Container(
                height: 14,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(RadhaRadii.radiusSm),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Staggered fade + rise for list rows. Honours reduce-motion and caps the
/// per-row delay so long lists don't drag.
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
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: RadhaMotion.medium,
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _c,
    curve: RadhaMotion.easeOut,
  );
  late final Animation<Offset> _offset = Tween<Offset>(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _c, curve: RadhaMotion.easeOut));

  @override
  void initState() {
    super.initState();
    if (widget.reduceMotion) {
      _c.value = 1;
    } else {
      final delay = (40 * widget.index).clamp(0, 320);
      Future<void>.delayed(Duration(milliseconds: delay), () {
        if (mounted) _c.forward();
      });
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

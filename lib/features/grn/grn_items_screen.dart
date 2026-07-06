import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dto/grn_dto.dart';
import '../../core/offline/sync_service.dart';
import '../../design/app_assets.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/widgets/mor_companion.dart';
import '../../design/widgets/primary_button.dart';
import '../../design/widgets/secondary_button.dart';
import '../../l10n/generated/app_localizations.dart';

/// Provider that fetches a single GRN by ID.
final _grnDetailProvider = FutureProvider.family<GrnResponse, String>((
  ref,
  id,
) async {
  final client = ref.watch(apiClientProvider);
  return client.getGrn(id);
});

/// GRN items screen — shows GRN header info, item list with running totals,
/// and actions to add items, move to pending review, or post.
class GrnItemsScreen extends ConsumerStatefulWidget {
  const GrnItemsScreen({super.key, required this.grnId});

  final String grnId;

  @override
  ConsumerState<GrnItemsScreen> createState() => _GrnItemsScreenState();
}

class _GrnItemsScreenState extends ConsumerState<GrnItemsScreen> {
  /// Local list of items added during this session (before backend persistence).
  final List<_GrnItemLocal> _items = [];

  /// Whether an action is in progress.
  bool _isLoading = false;

  double get _totalQuantity =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  double get _totalValue =>
      _items.fold(0, (sum, item) => sum + (item.quantity * item.unitPrice));

  /// Checks if the user has permission to post a GRN.
  ///
  /// Mirrors the backend's `UserRole` union (`owner | manager | staff |
  /// auditor | consumer | admin`) — `post_grn`/`tenant_admin`/`super_admin`
  /// are not real role strings the server ever issues, so checking for them
  /// only ever evaluated to `false`.
  bool _canPost(CurrentUser? user) {
    if (user == null) return false;
    return user.roles.contains('owner') ||
        user.roles.contains('manager') ||
        user.roles.contains('admin');
  }

  /// Serialise a local item into the backend `GrnItemSchema` shape.
  Map<String, dynamic> _itemToJson(_GrnItemLocal item) => {
    'ean': item.ean,
    'productName': item.productName,
    // GRN quantities are whole received units; the backend requires an int.
    'quantity': item.quantity.round(),
    'unit': 'pcs',
    if (item.batchNumber != null && item.batchNumber!.isNotEmpty)
      'batchNumber': item.batchNumber,
    if (item.mfgDate != null) 'manufactureDate': item.mfgDate!.toIso8601String(),
    if (item.expDate != null) 'expiryDate': item.expDate!.toIso8601String(),
    'unitPrice': item.unitPrice,
  };

  Future<void> _showAddItemSheet() async {
    final l10n = AppLocalizations.of(context);
    final item = await showModalBottomSheet<_GrnItemLocal>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const _AddItemSheet(),
    );
    if (item == null || !mounted) return;

    // Persist the item to the GRN immediately (offline-first via the sync
    // queue) — no more local-only items that silently vanish.
    setState(() => _isLoading = true);
    try {
      final result = await ref.read(syncServiceProvider).enqueue<void>(
        endpoint: '/api/v1/grn/${widget.grnId}/items',
        method: 'POST',
        body: {
          'items': [_itemToJson(item)],
        },
      );
      if (!mounted) return;
      setState(() => _items.add(item));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.synced ? l10n.grnItemAdded : l10n.grnItemSavedOffline,
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.grnItemAddError)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _postGrn() async {
    final l10n = AppLocalizations.of(context);
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.grnAddItemFirst)),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      // Real post: finalises the GRN, updates stock, resolves low-stock
      // alerts (server-side). Offline-first via the sync queue.
      final result = await ref.read(syncServiceProvider).enqueue<void>(
        endpoint: '/api/v1/grn/${widget.grnId}/post',
        method: 'POST',
        body: const <String, dynamic>{},
      );
      if (!mounted) return;
      ref.invalidate(_grnDetailProvider(widget.grnId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.synced ? l10n.grnPosted : l10n.grnPostQueued,
          ),
        ),
      );
      context.go('/grn');
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.grnPostError)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final grnAsync = ref.watch(_grnDetailProvider(widget.grnId));
    final currentUser = ref.watch(currentUserProvider);
    final canPost = _canPost(currentUser);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          l10n.grnItemsTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          // GRN header summary.
          grnAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const SizedBox.shrink(),
            data: (grn) => _GrnHeaderCard(grn: grn),
          ),

          // Items list.
          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MorCompanion(
                          mood: MorMood.work,
                          size: 96,
                          semanticLabel: l10n.grnNoItems,
                        ),
                        const SizedBox(height: RadhaSpacing.space12),
                        Text(
                          l10n.grnNoItems,
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: RadhaSpacing.space8),
                        Text(
                          l10n.grnNoItemsHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: RadhaSpacing.space16,
                      vertical: RadhaSpacing.space12,
                    ),
                    itemCount: _items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: RadhaSpacing.space8),
                    itemBuilder: (context, index) =>
                        _ItemTile(item: _items[index]),
                  ),
          ),

          // Running totals footer.
          if (_items.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: RadhaSpacing.space16,
                vertical: RadhaSpacing.space12,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                border: Border(
                  top: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.grnTotalQty(_totalQuantity.toStringAsFixed(0)),
                    style: theme.textTheme.titleSmall,
                  ),
                  Text(
                    l10n.grnTotalValue(_totalValue.toStringAsFixed(2)),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

          // Action bar.
          Container(
            padding: const EdgeInsets.all(RadhaSpacing.space16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SecondaryButton(
                    label: l10n.grnAddItem,
                    icon: Icons.add,
                    expand: true,
                    onPressed: _isLoading ? null : _showAddItemSheet,
                  ),
                  // Post finalises the GRN (manager/admin only). Staff add
                  // received items; a manager posts. There is no user-facing
                  // "pending review" transition in the backend, so we don't
                  // surface a button that can't do anything.
                  if (canPost) ...[
                    const SizedBox(height: RadhaSpacing.space12),
                    PrimaryButton(
                      label: l10n.grnPostGrn,
                      icon: Icons.check_circle_outline,
                      expand: true,
                      loading: _isLoading,
                      onPressed: _isLoading ? null : _postGrn,
                    ),
                    const SizedBox(height: RadhaSpacing.space8),
                    Text(
                      l10n.grnPostHint,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// GRN header summary card shown at the top of the items screen.
class _GrnHeaderCard extends StatelessWidget {
  const _GrnHeaderCard({required this.grn});

  final GrnResponse grn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(RadhaSpacing.space16),
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
              Expanded(
                child: Text(
                  grn.supplierName ?? grn.supplierId,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _buildStatusPill(l10n, grn.status ?? 'draft'),
            ],
          ),
          if (grn.invoiceNumber != null) ...[
            const SizedBox(height: RadhaSpacing.space8),
            Text(
              l10n.grnInvoiceLabel(grn.invoiceNumber!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusPill(AppLocalizations l10n, String status) {
    Color color;
    String label;
    switch (status) {
      case 'draft':
        color = RadhaColors.inkMuted;
        label = l10n.grnFilterDraft;
      case 'pending_review':
        color = RadhaColors.warning;
        label = l10n.grnFilterPendingReview;
      case 'posted':
        color = RadhaColors.success;
        label = l10n.grnFilterPosted;
      default:
        color = RadhaColors.inkMuted;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Single item tile in the GRN items list.
class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item});

  final _GrnItemLocal item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final lineTotal = item.quantity * item.unitPrice;

    return Container(
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: RadhaSpacing.space4),
                Text(
                  '${item.quantity.toStringAsFixed(0)} × \u20B9${item.unitPrice.toStringAsFixed(2)}'
                  '${item.batchNumber != null && item.batchNumber!.isNotEmpty ? ' · ${l10n.grnBatchTag(item.batchNumber!)}' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: RadhaSpacing.space8),
          Text(
            '\u20B9${lineTotal.toStringAsFixed(0)}',
            style: radhaMonoStyle(
              fontSize: 15,
              weight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal bottom sheet form for adding a GRN item.
class _AddItemSheet extends StatefulWidget {
  const _AddItemSheet();

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _eanController = TextEditingController();
  final _productController = TextEditingController();
  final _quantityController = TextEditingController();
  final _batchController = TextEditingController();
  final _priceController = TextEditingController();

  DateTime? _mfgDate;
  DateTime? _expDate;
  String? _dateError;

  @override
  void dispose() {
    _eanController.dispose();
    _productController.dispose();
    _quantityController.dispose();
    _batchController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _validateDates() {
    if (_mfgDate != null && _expDate != null && _mfgDate!.isAfter(_expDate!)) {
      setState(
        () => _dateError = AppLocalizations.of(context).exMfgAfterExpiry,
      );
    } else {
      setState(() => _dateError = null);
    }
  }

  Future<void> _pickMfgDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _mfgDate ?? DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _mfgDate = picked);
      _validateDates();
    }
  }

  Future<void> _pickExpDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expDate ?? DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _expDate = picked);
      _validateDates();
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _validateDates();
    if (_dateError != null) return;

    final item = _GrnItemLocal(
      ean: _eanController.text.trim(),
      productName: _productController.text.trim(),
      quantity: double.parse(_quantityController.text.trim()),
      batchNumber: _batchController.text.trim(),
      mfgDate: _mfgDate,
      expDate: _expDate,
      unitPrice: double.parse(_priceController.text.trim()),
    );

    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(RadhaSpacing.space24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.grnAddItem,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: RadhaSpacing.space24),

              // Barcode (EAN) — required so the backend can resolve/create the
              // product. Scan it off the carton when receiving goods.
              TextFormField(
                controller: _eanController,
                decoration: InputDecoration(
                  labelText: l10n.grnBarcodeLabel,
                  hintText: l10n.grnBarcodeHint,
                  prefixIcon: const Icon(Icons.qr_code_2),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(13),
                ],
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return l10n.commonRequired;
                  if (t.length < 8 || t.length > 13) return l10n.grnBarcodeHint;
                  return null;
                },
              ),
              const SizedBox(height: RadhaSpacing.space24),

              // Product name.
              TextFormField(
                controller: _productController,
                decoration: InputDecoration(
                  labelText: l10n.grnProductNameLabel,
                  prefixIcon: const Icon(Icons.inventory_2),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.commonRequired
                    : null,
              ),
              const SizedBox(height: RadhaSpacing.space24),

              // Quantity — whole received units (backend stores an integer).
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: l10n.commonQuantity,
                  prefixIcon: const Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l10n.commonRequired;
                  final n = int.tryParse(v.trim());
                  if (n == null || n <= 0) return l10n.grnMustBePositive;
                  return null;
                },
              ),
              const SizedBox(height: RadhaSpacing.space24),

              // Batch number.
              TextFormField(
                controller: _batchController,
                decoration: InputDecoration(
                  labelText: l10n.grnBatchNumberOptional,
                  prefixIcon: const Icon(Icons.tag),
                ),
              ),
              const SizedBox(height: RadhaSpacing.space24),

              // MFG date.
              _DatePickerField(
                label: l10n.grnMfgDateLabel,
                value: _mfgDate,
                onTap: _pickMfgDate,
              ),
              const SizedBox(height: RadhaSpacing.space24),

              // Expiry date.
              _DatePickerField(
                label: l10n.grnExpiryDateLabel,
                value: _expDate,
                onTap: _pickExpDate,
              ),

              // Date validation error.
              if (_dateError != null) ...[
                const SizedBox(height: RadhaSpacing.space8),
                Text(
                  _dateError!,
                  style: TextStyle(color: RadhaColors.danger, fontSize: 12),
                ),
              ],
              const SizedBox(height: RadhaSpacing.space24),

              // Unit price.
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: l10n.grnUnitPriceLabel,
                  prefixIcon: const Icon(Icons.currency_rupee),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l10n.commonRequired;
                  final n = double.tryParse(v.trim());
                  if (n == null || n < 0) return l10n.grnMustBeNonNeg;
                  return null;
                },
              ),
              const SizedBox(height: RadhaSpacing.space32),

              // Submit.
              PrimaryButton(
                label: l10n.grnAddItem,
                expand: true,
                onPressed: _submit,
              ),
              const SizedBox(height: RadhaSpacing.space16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tappable read-only field that opens a date picker.
class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(RadhaRadii.radiusSm),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          value != null
              ? '${value!.day}/${value!.month}/${value!.year}'
              : AppLocalizations.of(context).grnSelectDate,
          style: TextStyle(
            color: value != null
                ? Theme.of(context).textTheme.bodyLarge?.color
                : Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
    );
  }
}

/// Local model for a GRN item before it's persisted.
class _GrnItemLocal {
  const _GrnItemLocal({
    required this.ean,
    required this.productName,
    required this.quantity,
    this.batchNumber,
    this.mfgDate,
    this.expDate,
    required this.unitPrice,
  });

  /// Product barcode — required by the backend to resolve/create the product.
  final String ean;
  final String productName;
  final double quantity;
  final String? batchNumber;
  final DateTime? mfgDate;
  final DateTime? expDate;
  final double unitPrice;
}

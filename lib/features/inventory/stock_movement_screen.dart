import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_client.dart';
import '../../core/network/dto/inventory_dto.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/widgets/primary_button.dart';
import '../../l10n/generated/app_localizations.dart';

/// Reasons available for stock movements. These canonical English strings are
/// the dropdown `value` (mapped to the backend reason on submit); the visible
/// label is resolved through [_reasonLabel].
const List<String> _reasons = <String>[
  'Purchase',
  'Return',
  'Adjustment',
  'Transfer',
  'Damage',
  'Expiry removal',
  'Other',
];

/// Localized label for a canonical [_reasons] value.
String _reasonLabel(AppLocalizations l10n, String reason) {
  switch (reason) {
    case 'Purchase':
      return l10n.smReasonPurchase;
    case 'Return':
      return l10n.smReasonReturn;
    case 'Adjustment':
      return l10n.smReasonAdjustment;
    case 'Transfer':
      return l10n.smReasonTransfer;
    case 'Damage':
      return l10n.smReasonDamage;
    case 'Expiry removal':
      return l10n.smReasonExpiryRemoval;
    default:
      return l10n.smReasonOther;
  }
}

/// Stock movement screen with a Stock In / Stock Out segmented toggle.
///
/// Posts to the inventory adjust endpoint with the matching `type`. Per R17.3
/// the Stock Out path performs a client-side guard against current stock and
/// rejects a movement that would drop below zero before issuing the request.
///
/// Accepts an optional [productId] to pre-fill the product field (used by the
/// low-stock "Restock" deep-link).
class StockMovementScreen extends ConsumerStatefulWidget {
  const StockMovementScreen({super.key, this.productId});

  final String? productId;

  @override
  ConsumerState<StockMovementScreen> createState() =>
      _StockMovementScreenState();
}

class _StockMovementScreenState extends ConsumerState<StockMovementScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _productController;
  final _quantityController = TextEditingController(text: '1');
  final _batchController = TextEditingController();
  final _notesController = TextEditingController();

  /// 'in' (receipt) or 'out' (dispatch).
  String _type = 'in';
  String? _selectedReason;
  DateTime? _expiryDate;
  bool _isSubmitting = false;
  String? _stockError;

  @override
  void initState() {
    super.initState();
    _productController = TextEditingController(text: widget.productId ?? '');
  }

  @override
  void dispose() {
    _productController.dispose();
    _quantityController.dispose();
    _batchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int get _quantity => int.tryParse(_quantityController.text.trim()) ?? 0;

  void _setQuantity(int q) {
    final clamped = q < 1 ? 1 : q;
    _quantityController.text = '$clamped';
    setState(() {});
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  /// R17.3 guard: for stock-out, reject if the requested quantity exceeds the
  /// product's known current stock. Returns true when safe to continue.
  Future<bool> _passesStockOutGuard(String productId, int quantity) async {
    if (_type != 'out') return true;
    final insufficientMessage = AppLocalizations.of(context).smInsufficientStock;
    try {
      final client = ref.read(apiClientProvider);
      final inventoryData = await client.getInventory();
      final match = inventoryData.items
          .where((i) => i.productId == productId)
          .toList();
      if (match.isNotEmpty && match.first.quantity < quantity) {
        setState(() => _stockError = insufficientMessage);
        return false;
      }
    } catch (_) {
      // Offline / lookup failure → let the backend enforce.
    }
    return true;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _stockError = null);
    if (!_formKey.currentState!.validate()) return;

    final quantity = _quantity;
    final productId = _productController.text.trim();
    if (!await _passesStockOutGuard(productId, quantity)) return;

    HapticFeedback.lightImpact();
    setState(() => _isSubmitting = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.adjustStock(
        StockAdjustmentDto(
          productId: productId,
          quantity: quantity,
          type: _type,
        ),
      );
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _type == 'in' ? l10n.smStockInRecorded : l10n.smStockOutRecorded,
          ),
        ),
      );
      context.pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.smRecordError)),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          l10n.smTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            RadhaSpacing.space20,
            RadhaSpacing.space12,
            RadhaSpacing.space20,
            RadhaSpacing.space24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // In / Out segmented toggle.
                _InOutToggle(
                  type: _type,
                  onChanged: _isSubmitting
                      ? null
                      : (t) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _type = t;
                            _stockError = null;
                          });
                        },
                ),
                const SizedBox(height: RadhaSpacing.space24),

                // Form card.
                Container(
                  padding: const EdgeInsets.all(RadhaSpacing.space16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Label(l10n.smProductLabel),
                      TextFormField(
                        key: const ValueKey('field-product'),
                        controller: _productController,
                        enabled: !_isSubmitting,
                        decoration: InputDecoration(
                          hintText: l10n.smProductHint,
                          prefixIcon: const Icon(Icons.inventory_2_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n.commonRequired
                            : null,
                      ),
                      const SizedBox(height: RadhaSpacing.space16),

                      _Label(l10n.smReasonLabel),
                      DropdownButtonFormField<String>(
                        key: const ValueKey('field-reason'),
                        initialValue: _selectedReason,
                        isExpanded: true,
                        items: _reasons
                            .map(
                              (r) => DropdownMenuItem(
                                value: r,
                                child: Text(_reasonLabel(l10n, r)),
                              ),
                            )
                            .toList(),
                        onChanged: _isSubmitting
                            ? null
                            : (v) => setState(() => _selectedReason = v),
                        decoration: InputDecoration(
                          hintText: l10n.smSelectReason,
                        ),
                        validator: (v) => v == null ? l10n.commonRequired : null,
                      ),
                      const SizedBox(height: RadhaSpacing.space16),

                      _Label(l10n.commonQuantity),
                      _QuantityStepper(
                        controller: _quantityController,
                        enabled: !_isSubmitting,
                        errorText: _stockError,
                        onDecrement: () => _setQuantity(_quantity - 1),
                        onIncrement: () => _setQuantity(_quantity + 1),
                        onChanged: () => setState(() {
                          if (_stockError != null) _stockError = null;
                        }),
                      ),
                      const SizedBox(height: RadhaSpacing.space16),

                      _Label(l10n.smBatchLabel),
                      TextFormField(
                        key: const ValueKey('field-batch'),
                        controller: _batchController,
                        enabled: !_isSubmitting,
                        decoration: InputDecoration(hintText: l10n.commonOptional),
                      ),
                      const SizedBox(height: RadhaSpacing.space16),

                      _Label(l10n.smExpiryLabel),
                      InkWell(
                        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
                        onTap: _isSubmitting ? null : _pickExpiryDate,
                        child: Container(
                          height: kMinTouchTarget + 8,
                          padding: const EdgeInsets.symmetric(
                            horizontal: RadhaSpacing.space16,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            border: Border.all(color: theme.colorScheme.outline),
                            borderRadius: BorderRadius.circular(
                              RadhaRadii.radiusMd,
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: RadhaSpacing.space12),
                              Text(
                                _expiryDate != null
                                    ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                                    : l10n.smExpiryOptionalHint,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: _expiryDate != null
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: RadhaSpacing.space16),

                      _Label(l10n.smNotesLabel),
                      TextFormField(
                        key: const ValueKey('field-notes'),
                        controller: _notesController,
                        enabled: !_isSubmitting,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: l10n.smNotesHint,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space24),

                PrimaryButton(
                  key: const ValueKey('submit-stock-movement'),
                  label: _type == 'in' ? l10n.smRecordIn : l10n.smRecordOut,
                  icon: _type == 'in'
                      ? Icons.south_west_rounded
                      : Icons.north_east_rounded,
                  expand: true,
                  loading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small field label.
class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: RadhaSpacing.space8),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Stock In / Stock Out pill toggle with an animated active segment.
class _InOutToggle extends StatelessWidget {
  const _InOutToggle({required this.type, required this.onChanged});

  final String type;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    Widget seg(String value, String label, IconData icon) {
      final active = type == value;
      return Expanded(
        child: GestureDetector(
          onTap: onChanged == null ? null : () => onChanged!(value),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: RadhaMotion.fast,
            curve: RadhaMotion.easeOut,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active
                  ? theme.colorScheme.surfaceContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(RadhaRadii.radiusSm),
              border: active
                  ? Border.all(color: theme.colorScheme.outline)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: active
                      ? RadhaColors.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: RadhaSpacing.space8),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: active
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
      ),
      child: Row(
        children: [
          seg('in', l10n.smStockIn, Icons.south_west_rounded),
          seg('out', l10n.smStockOut, Icons.north_east_rounded),
        ],
      ),
    );
  }
}

/// Quantity field with minus / plus stepper buttons and a mono number field.
class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.controller,
    required this.enabled,
    required this.errorText,
    required this.onDecrement,
    required this.onIncrement,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool enabled;
  final String? errorText;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _StepButton(
              icon: Icons.remove_rounded,
              onTap: enabled
                  ? () {
                      HapticFeedback.selectionClick();
                      onDecrement();
                    }
                  : null,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: RadhaSpacing.space8,
                ),
                child: TextFormField(
                  key: const ValueKey('field-quantity'),
                  controller: controller,
                  enabled: enabled,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: radhaMonoStyle(
                    fontSize: 20,
                    weight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: const InputDecoration(hintText: '0'),
                  onChanged: (_) => onChanged(),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    final n = int.tryParse(v.trim());
                    if (n == null || n <= 0) return 'Must be greater than 0';
                    return null;
                  },
                ),
              ),
            ),
            _StepButton(
              icon: Icons.add_rounded,
              onTap: enabled
                  ? () {
                      HapticFeedback.selectionClick();
                      onIncrement();
                    }
                  : null,
            ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: RadhaSpacing.space4),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: kMinTouchTarget,
          height: kMinTouchTarget,
          child: Icon(icon, color: theme.colorScheme.onSurface),
        ),
      ),
    );
  }
}

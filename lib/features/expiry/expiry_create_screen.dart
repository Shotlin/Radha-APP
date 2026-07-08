import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dto/expiry_dto.dart';
import '../../core/offline/sync_service.dart';
import '../../design/app_assets.dart';
import '../../design/tokens.dart';
import '../../design/widgets/mor_companion.dart';
import '../../design/widgets/primary_button.dart';
import '../../l10n/generated/app_localizations.dart';
import '../scan/domain/label_field_models.dart';
import 'ocr_date_helper.dart';

/// Screen for creating a new expiry record. Supports manual date entry
/// and an OCR-assisted camera path on mobile platforms.
class ExpiryCreateScreen extends ConsumerStatefulWidget {
  const ExpiryCreateScreen({
    super.key,
    this.prefillEan,
    this.prefillProductId,
    this.prefillProductName,
  });

  /// Populated when navigated here from a scan result via
  /// `AppRoute.expiryNew`'s `extra` map — prefills the form instead of
  /// leaving the user to retype the product they just scanned.
  final String? prefillEan;
  final String? prefillProductId;
  final String? prefillProductName;

  @override
  ConsumerState<ExpiryCreateScreen> createState() => _ExpiryCreateScreenState();
}

class _ExpiryCreateScreenState extends ConsumerState<ExpiryCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productIdController = TextEditingController();
  final _batchController = TextEditingController();
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime? _mfgDate;
  DateTime? _expiryDate;
  String? _dateError;
  bool _loading = false;

  /// Whether the device supports on-device camera OCR.
  bool get _canUseCamera {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  void initState() {
    super.initState();
    if (widget.prefillProductId != null) {
      _productIdController.text = widget.prefillProductId!;
    }
  }

  @override
  void dispose() {
    _productIdController.dispose();
    _batchController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _validateDates() {
    if (_mfgDate != null &&
        _expiryDate != null &&
        _mfgDate!.isAfter(_expiryDate!)) {
      setState(
        () => _dateError = AppLocalizations.of(context).exMfgAfterExpiry,
      );
    } else {
      setState(() => _dateError = null);
    }
  }

  Future<void> _pickDate({required bool isMfg}) async {
    final now = DateTime.now();
    final initial = isMfg ? (_mfgDate ?? now) : (_expiryDate ?? now);
    final first = DateTime(2000);
    final last = DateTime(2100);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      helpText: isMfg
          ? AppLocalizations.of(context).exSelectMfg
          : AppLocalizations.of(context).exSelectExpiry,
    );
    if (picked == null) return;

    setState(() {
      if (isMfg) {
        _mfgDate = picked;
      } else {
        _expiryDate = picked;
      }
    });
    _validateDates();
  }

  Future<void> _useCamera() async {
    final result = await OcrDateHelper.extractDates(context, ref);
    if (result == null || !mounted) return;

    setState(() {
      if (result.mfgDate != null) _mfgDate = result.mfgDate;
      if (result.expiryDate != null) _expiryDate = result.expiryDate;
      if (result.batchNumber != null && _batchController.text.trim().isEmpty) {
        _batchController.text = result.batchNumber!;
      }
    });
    _validateDates();

    // The scanner only ever hands back a date once several frames agreed,
    // but "agreed" isn't the same as "certain" — a mid-confidence accept is
    // still worth a nudge to double-check before the user just hits Save.
    final expiryConfidence = result.fieldConfidence[LabelField.expiryDate];
    if (expiryConfidence != null && expiryConfidence < 0.8 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scanned date accepted at moderate confidence — please double-check it.'),
        ),
      );
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (_expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.exExpiryRequired)),
      );
      return;
    }
    if (_dateError != null) return;

    setState(() => _loading = true);

    final storeId = ref.read(currentUserProvider)?.selectedStoreId;

    try {
      final dto = CreateExpiryDto(
        productId: _productIdController.text.trim(),
        storeId: storeId ?? '',
        expiryDate: _expiryDate!.toIso8601String().split('T').first,
        manufactureDate: _mfgDate?.toIso8601String().split('T').first,
        batchNumber: _batchController.text.trim().isEmpty
            ? null
            : _batchController.text.trim(),
        quantity: int.tryParse(_quantityController.text.trim()),
        shelfLocation: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
      );

      // Route through the offline-first queue (Task 16). Successful 2xx
      // responses go straight through; offline / 5xx responses are
      // persisted in `pending_writes` and surfaced via the
      // [SyncStatusBanner].
      final result = await ref
          .read(syncServiceProvider)
          .enqueue<void>(
            endpoint: '/api/v1/expiry-records',
            method: 'POST',
            body: dto.toJson(),
          );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.synced ? l10n.exCreated : l10n.exOfflineQueued,
          ),
        ),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.exSubmitError)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDate(DateTime? date, String notSetLabel) {
    if (date == null) return notSetLabel;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.exTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: RadhaSpacing.space24,
            vertical: RadhaSpacing.space24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Prominent OCR helper card (mobile only) — the fast path.
                if (_canUseCamera) ...[
                  _OcrHelperCard(
                    onTap: _loading ? null : _useCamera,
                  ),
                  const SizedBox(height: RadhaSpacing.space24),
                ],

                // Product ID
                Text(l10n.exProductIdLabel, style: theme.textTheme.labelLarge),
                const SizedBox(height: RadhaSpacing.space8),
                if (widget.prefillProductName != null) ...[
                  Text(
                    widget.prefillProductName!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: RadhaSpacing.space8),
                ],
                TextFormField(
                  controller: _productIdController,
                  enabled: !_loading,
                  decoration: InputDecoration(
                    hintText: l10n.exProductIdHint,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.commonRequired
                      : null,
                ),
                const SizedBox(height: RadhaSpacing.space24),

                // MFG Date
                Text(l10n.exMfgLabel, style: theme.textTheme.labelLarge),
                const SizedBox(height: RadhaSpacing.space8),
                _DatePickerTile(
                  label: _formatDate(_mfgDate, l10n.exNotSet),
                  onTap: _loading ? null : () => _pickDate(isMfg: true),
                ),
                const SizedBox(height: RadhaSpacing.space24),

                // Expiry Date
                Text(l10n.exExpiryLabel, style: theme.textTheme.labelLarge),
                const SizedBox(height: RadhaSpacing.space8),
                _DatePickerTile(
                  label: _formatDate(_expiryDate, l10n.exNotSet),
                  onTap: _loading ? null : () => _pickDate(isMfg: false),
                ),

                // Date validation error
                if (_dateError != null) ...[
                  const SizedBox(height: RadhaSpacing.space8),
                  Text(
                    _dateError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: RadhaColors.danger,
                    ),
                  ),
                ],
                const SizedBox(height: RadhaSpacing.space24),

                // Batch number
                Text(l10n.exBatchLabel, style: theme.textTheme.labelLarge),
                const SizedBox(height: RadhaSpacing.space8),
                TextFormField(
                  controller: _batchController,
                  enabled: !_loading,
                  decoration: InputDecoration(hintText: l10n.commonOptional),
                ),
                const SizedBox(height: RadhaSpacing.space24),

                // Quantity
                Text(l10n.commonQuantity, style: theme.textTheme.labelLarge),
                const SizedBox(height: RadhaSpacing.space8),
                TextFormField(
                  controller: _quantityController,
                  enabled: !_loading,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: l10n.commonOptional),
                ),
                const SizedBox(height: RadhaSpacing.space24),

                // Location
                Text(l10n.exLocationLabel, style: theme.textTheme.labelLarge),
                const SizedBox(height: RadhaSpacing.space8),
                TextFormField(
                  controller: _locationController,
                  enabled: !_loading,
                  decoration: InputDecoration(
                    hintText: l10n.exLocationHint,
                  ),
                ),
                const SizedBox(height: RadhaSpacing.space32),

                // Submit
                PrimaryButton(
                  label: l10n.exSaveRecord,
                  expand: true,
                  loading: _loading,
                  onPressed: _loading || _dateError != null ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Prominent OCR helper card — the recommended fast path for entering dates.
class _OcrHelperCard extends StatelessWidget {
  const _OcrHelperCard({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(RadhaSpacing.space16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: MorCompanion(
                  mood: MorMood.think,
                  size: 44,
                  semanticLabel: l10n.exOcrSemantic,
                ),
              ),
              const SizedBox(width: RadhaSpacing.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.exOcrTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: RadhaSpacing.space2),
                    Text(
                      l10n.exOcrSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
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

/// Tappable row that displays a date value and opens the date picker on tap.
class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(RadhaRadii.radiusSm),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: RadhaSpacing.space16,
          vertical: RadhaSpacing.space12,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(RadhaRadii.radiusSm),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
            Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

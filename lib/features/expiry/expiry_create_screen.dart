import 'dart:io' show Platform;

import 'package:uuid/uuid.dart';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dto/expiry_dto.dart';
import '../../core/network/dto/product_dto.dart';
import '../../core/offline/sync_service.dart';
import '../../design/tokens.dart';
import '../../design/widgets/primary_button.dart';
import '../../l10n/generated/app_localizations.dart';
import 'date_scanner_screen.dart';
import 'ean_picker_screen.dart';

// ─────────────────────────────────────────────────────────────────
// Total wizard steps.
const int _kSteps = 4;

/// Step index constants (kept as ints so AnimatedSwitcher key is simple).
const int _kStepProduct = 0;
const int _kStepExpiry = 1;
const int _kStepMfg = 2;
const int _kStepExtras = 3;

/// New-expiry-record wizard.
///
/// Step 1 — Product (scan EAN barcode → catalog lookup; or manual EAN + name).
/// Step 2 — Expiry date (OCR scan from pack or date picker). Required.
/// Step 3 — Manufacturing date (OCR or date picker). Optional / skippable.
/// Step 4 — Extra details: batch, quantity, location. All optional. Submit.
class ExpiryCreateScreen extends ConsumerStatefulWidget {
  const ExpiryCreateScreen({
    super.key,
    this.prefillEan,
    this.prefillProductId,
    this.prefillProductName,
  });

  /// When navigated here from a scan result, these prefill step 1 so the
  /// user doesn't re-scan the product they just identified.
  final String? prefillEan;
  final String? prefillProductId;
  final String? prefillProductName;

  @override
  ConsumerState<ExpiryCreateScreen> createState() =>
      _ExpiryCreateScreenState();
}

class _ExpiryCreateScreenState extends ConsumerState<ExpiryCreateScreen> {
  int _step = _kStepProduct;

  // ── Step 1: Product ─────────────────────────────────────────────
  final _eanController = TextEditingController();
  String? _resolvedProductId; // DB id if catalog hit, else raw EAN
  String? _productName; // from catalog or manual entry
  bool _productLookupLoading = false;
  bool _productNotFound = false; // true when API returned 404
  String? _productLookupError; // non-404 errors shown inline
  final _manualNameController = TextEditingController();

  // ── Step 2: Expiry date ─────────────────────────────────────────
  DateTime? _expiryDate;

  // ── Step 3: Manufacturing date ──────────────────────────────────
  DateTime? _mfgDate;

  // ── Step 4: Extras ──────────────────────────────────────────────
  final _batchController = TextEditingController();
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController();
  bool _submitting = false;

  bool get _canUseCamera {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  void initState() {
    super.initState();
    // When prefilled from a scan-result route, jump straight to date step.
    if (widget.prefillProductId != null || widget.prefillEan != null) {
      _step = _kStepExpiry;
      _resolvedProductId =
          widget.prefillProductId ?? widget.prefillEan;
      _productName = widget.prefillProductName;
      _productNotFound = widget.prefillProductName == null;
      _eanController.text =
          widget.prefillEan ?? widget.prefillProductId ?? '';
    }
  }

  @override
  void dispose() {
    _eanController.dispose();
    _manualNameController.dispose();
    _batchController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // ── Navigation ───────────────────────────────────────────────────

  void _advance() => setState(() => _step++);

  bool _handleBack() {
    if (_step > _kStepProduct) {
      setState(() => _step--);
      return true; // consumed
    }
    return false; // let Navigator pop the screen
  }

  // ── Step 1 logic ─────────────────────────────────────────────────

  Future<void> _scanEan() async {
    final ean = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const EanPickerScreen()),
    );
    if (ean == null || !mounted) return;
    _eanController.text = ean;
    await _lookupProduct(ean);
  }

  Future<void> _lookupProduct(String ean) async {
    final trimmed = ean.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _productLookupLoading = true;
      _productLookupError = null;
      _productNotFound = false;
      _productName = null;
      _resolvedProductId = null;
    });

    try {
      final api = ref.read(apiClientProvider);
      final result =
          await api.getProductLookup(trimmed, includeNutrition: false);
      if (!mounted) return;
      if (result.found && result.product != null) {
        setState(() {
          _resolvedProductId = result.product!.id;
          _productName = result.product!.name;
          _productNotFound = false;
          _productLookupLoading = false;
        });
      } else {
        // API returned found:false — ask user to supply the name.
        setState(() {
          _productNotFound = true;
          _resolvedProductId = trimmed;
          _productLookupLoading = false;
        });
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final inner = e.error;
      final apiErr = inner is ApiException ? inner : null;
      if (apiErr?.statusCode == 400) {
        // Backend's format/checksum check rejected this string (e.g. a
        // mistyped digit, a non-GS1 in-house code, a partial OCR read).
        // Store owners punch in barcodes by hand constantly — treat this
        // the same as "not found in catalog" rather than blocking them:
        // let them proceed to manual name entry instead of a dead end.
        setState(() {
          _productNotFound = true;
          _resolvedProductId = trimmed;
          _productLookupLoading = false;
        });
        return;
      }
      final String errorMsg;
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMsg = 'No connection — check your network and try again.';
      } else {
        errorMsg =
            (apiErr?.message.isNotEmpty == true)
                ? apiErr!.message
                : 'Network error — try again';
      }
      setState(() {
        _productLookupError = errorMsg;
        _productLookupLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _productLookupError = e.message.isNotEmpty ? e.message : 'Network error — try again';
        _productLookupLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _productLookupError = 'Something went wrong — try again';
        _productLookupLoading = false;
      });
    }
  }

  bool get _step1CanAdvance {
    if (_productLookupLoading) return false;
    if (_resolvedProductId == null) return false;
    if (_productNotFound && _manualNameController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  void _step1Next() {
    if (!_step1CanAdvance) return;
    if (_productNotFound) {
      // User typed the name manually — store it.
      _productName = _manualNameController.text.trim();
    }
    _advance();
  }

  // ── Step 2 & 3: Dates ────────────────────────────────────────────

  Future<void> _scanExpiry() async {
    final date = await Navigator.of(context).push<DateTime>(
      MaterialPageRoute(
        builder: (_) => const DateScannerScreen(mode: DateScanMode.expiry),
      ),
    );
    if (date == null || !mounted) return;
    setState(() => _expiryDate = date);
  }

  Future<void> _scanMfg() async {
    final date = await Navigator.of(context).push<DateTime>(
      MaterialPageRoute(
        builder: (_) => const DateScannerScreen(mode: DateScanMode.mfg),
      ),
    );
    if (date == null || !mounted) return;
    setState(() => _mfgDate = date);
  }

  Future<void> _pickDate({required bool isMfg}) async {
    final now = DateTime.now();
    final initial =
        isMfg ? (_mfgDate ?? now) : (_expiryDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: isMfg ? 'Select manufacturing date' : 'Select expiry date',
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isMfg) {
        _mfgDate = picked;
      } else {
        _expiryDate = picked;
      }
    });
  }

  // ── Submit ────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.exExpiryRequired)),
      );
      return;
    }
    if (_mfgDate != null && _mfgDate!.isAfter(_expiryDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.exMfgAfterExpiry)),
      );
      return;
    }

    setState(() => _submitting = true);

    final storeId = ref.read(currentUserProvider)?.selectedStoreId;
    String? productId = _resolvedProductId;

    // When the product wasn't found in catalog, _resolvedProductId is the
    // raw EAN string. Create a catalog stub first so we get a real UUID.
    if (_productNotFound && _productName != null) {
      try {
        final api = ref.read(apiClientProvider);
        final created = await api.createProduct(CreateProductDto(
          name: _productName!,
          ean: _eanController.text.trim().isNotEmpty
              ? _eanController.text.trim()
              : null,
        ));
        productId = created.id;
      } on ForbiddenException {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Product not in catalog — ask your manager to add it first.',
            ),
          ),
        );
        setState(() => _submitting = false);
        return;
      } on DioException catch (e) {
        if (!mounted) return;
        final inner = e.error;
        final msg = inner is ApiException && inner.message.isNotEmpty
            ? inner.message
            : 'Failed to register product — please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
        setState(() => _submitting = false);
        return;
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to register product — please try again.')),
        );
        setState(() => _submitting = false);
        return;
      }
    }

    if (productId == null || productId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please look up the product before saving.')),
      );
      setState(() => _submitting = false);
      return;
    }

    try {
      final dto = CreateExpiryDto(
        productId: productId,
        storeId: storeId ?? '',
        expiryDate:
            _expiryDate!.toIso8601String().split('T').first,
        manufactureDate:
            _mfgDate?.toIso8601String().split('T').first,
        batchNumber: _batchController.text.trim().isEmpty
            ? null
            : _batchController.text.trim(),
        quantity:
            int.tryParse(_quantityController.text.trim()),
        shelfLocation: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
      );

      final result = await ref
          .read(syncServiceProvider)
          .enqueue<void>(
            endpoint: '/api/v1/expiry-records',
            method: 'POST',
            body: dto.toJson(),
            // Stable key for this create attempt — prevents a duplicate
            // record if the user taps Submit while offline and the outbox
            // retries when connectivity returns (server de-dupes via the
            // Phase 8 idempotency_records table).
            idempotencyKey: const Uuid().v4(),
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).exSubmitError)),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ── Formatters ───────────────────────────────────────────────────

  String _fmtDate(DateTime? d) {
    if (d == null) return 'Not set';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == _kStepProduct,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).exTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (!_handleBack()) Navigator.of(context).pop();
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _StepIndicator(current: _step, total: _kSteps),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  transitionBuilder: (child, animation) {
                    final slide = Tween<Offset>(
                      begin: const Offset(0.08, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOut,
                    ));
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: slide,
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: _buildStep(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (_step) {
      case _kStepProduct:
        return _buildProductStep(context);
      case _kStepExpiry:
        return _buildDateStep(
          context,
          isMfg: false,
          title: 'Expiry Date',
          subtitle: 'Required — when does this product expire?',
          date: _expiryDate,
          onScan: _canUseCamera ? _scanExpiry : null,
          onNext: _expiryDate != null ? _advance : null,
          onSkip: null,
        );
      case _kStepMfg:
        return _buildDateStep(
          context,
          isMfg: true,
          title: 'Manufacturing Date',
          subtitle: 'Optional — when was this product made?',
          date: _mfgDate,
          onScan: _canUseCamera ? _scanMfg : null,
          onNext: _advance,
          onSkip: _advance,
        );
      case _kStepExtras:
        return _buildExtrasStep(context);
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Step 1: Product ───────────────────────────────────────────────

  Widget _buildProductStep(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(RadhaSpacing.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Product',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: RadhaSpacing.space4),
          Text(
            'Scan or enter the barcode to identify the product.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: RadhaSpacing.space24),

          // Scan card.
          if (_canUseCamera) ...[
            _ActionCard(
              icon: Icons.qr_code_scanner_rounded,
              title: 'Scan barcode',
              subtitle: 'Point camera at the product barcode',
              onTap: _productLookupLoading ? null : _scanEan,
            ),
            const SizedBox(height: RadhaSpacing.space20),
            Row(children: [
              Expanded(child: Divider(color: theme.colorScheme.outline)),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: RadhaSpacing.space12),
                child: Text('or enter manually',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
              ),
              Expanded(child: Divider(color: theme.colorScheme.outline)),
            ]),
            const SizedBox(height: RadhaSpacing.space20),
          ],

          // EAN text field.
          Text('EAN / Barcode number',
              style: theme.textTheme.labelLarge),
          const SizedBox(height: RadhaSpacing.space8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _eanController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    hintText: '8901234567890',
                  ),
                  onSubmitted: (v) => _lookupProduct(v),
                ),
              ),
              const SizedBox(width: RadhaSpacing.space8),
              FilledButton(
                onPressed: _productLookupLoading
                    ? null
                    : () => _lookupProduct(_eanController.text),
                child: _productLookupLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: RadhaColors.onPrimary),
                      )
                    : const Text('Look up'),
              ),
            ],
          ),

          // Lookup result.
          if (_productLookupError != null) ...[
            const SizedBox(height: RadhaSpacing.space8),
            Text(
              _productLookupError!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: RadhaColors.danger),
            ),
          ],

          if (_productName != null) ...[
            const SizedBox(height: RadhaSpacing.space12),
            _ProductFoundBanner(name: _productName!),
          ],

          if (_productNotFound) ...[
            const SizedBox(height: RadhaSpacing.space16),
            Container(
              padding: const EdgeInsets.all(RadhaSpacing.space16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius:
                    BorderRadius.circular(RadhaRadii.radiusMd),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 16,
                          color:
                              theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: RadhaSpacing.space8),
                      Expanded(
                        child: Text(
                          'Product not found in catalog.',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color:
                                theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: RadhaSpacing.space12),
                  Text('Please enter the product name:',
                      style: theme.textTheme.labelLarge),
                  const SizedBox(height: RadhaSpacing.space8),
                  TextField(
                    controller: _manualNameController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Parle-G Biscuits 200g',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: RadhaSpacing.space32),
          PrimaryButton(
            label: 'Next',
            icon: Icons.arrow_forward_rounded,
            expand: true,
            onPressed: _step1CanAdvance ? _step1Next : null,
          ),
        ],
      ),
    );
  }

  // ── Step 2 & 3: Date steps ────────────────────────────────────────

  Widget _buildDateStep(
    BuildContext context, {
    required bool isMfg,
    required String title,
    required String subtitle,
    required DateTime? date,
    required VoidCallback? onScan,
    required VoidCallback? onNext,
    required VoidCallback? onSkip,
  }) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(RadhaSpacing.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: RadhaSpacing.space4),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: RadhaSpacing.space24),

          // OCR scan card (mobile only).
          if (onScan != null) ...[
            _ActionCard(
              icon: Icons.document_scanner_outlined,
              title: isMfg
                  ? 'Scan manufacturing date'
                  : 'Scan expiry date',
              subtitle: isMfg
                  ? "Point at the MFD/MFG date on the pack"
                  : "Point at the EXP/BBE date on the pack",
              onTap: onScan,
            ),
            const SizedBox(height: RadhaSpacing.space20),
            Row(children: [
              Expanded(child: Divider(color: theme.colorScheme.outline)),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: RadhaSpacing.space12),
                child: Text('or pick manually',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
              ),
              Expanded(child: Divider(color: theme.colorScheme.outline)),
            ]),
            const SizedBox(height: RadhaSpacing.space20),
          ],

          // Date picker tile.
          Text(title, style: theme.textTheme.labelLarge),
          const SizedBox(height: RadhaSpacing.space8),
          _DateTile(
            label: _fmtDate(date),
            hasValue: date != null,
            onTap: () => _pickDate(isMfg: isMfg),
          ),

          const SizedBox(height: RadhaSpacing.space32),

          Row(
            children: [
              if (onSkip != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSkip,
                    child: const Text('Skip'),
                  ),
                ),
                const SizedBox(width: RadhaSpacing.space12),
              ],
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: 'Next',
                  icon: Icons.arrow_forward_rounded,
                  expand: true,
                  onPressed: onNext,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Step 4: Extras ────────────────────────────────────────────────

  Widget _buildExtrasStep(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(RadhaSpacing.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Additional Details',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: RadhaSpacing.space4),
          Text(
            'All fields are optional.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: RadhaSpacing.space24),

          // Summary chip.
          _SummaryBanner(
            productName: _productName,
            ean: _eanController.text.trim(),
            expiryDate: _expiryDate,
            mfgDate: _mfgDate,
            formatDate: _fmtDate,
          ),
          const SizedBox(height: RadhaSpacing.space24),

          // Batch number.
          Text(AppLocalizations.of(context).exBatchLabel,
              style: theme.textTheme.labelLarge),
          const SizedBox(height: RadhaSpacing.space8),
          TextFormField(
            controller: _batchController,
            enabled: !_submitting,
            decoration: InputDecoration(
                hintText: AppLocalizations.of(context).commonOptional),
          ),
          const SizedBox(height: RadhaSpacing.space20),

          // Quantity.
          Text(AppLocalizations.of(context).commonQuantity,
              style: theme.textTheme.labelLarge),
          const SizedBox(height: RadhaSpacing.space8),
          TextFormField(
            controller: _quantityController,
            enabled: !_submitting,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
                hintText: AppLocalizations.of(context).commonOptional),
          ),
          const SizedBox(height: RadhaSpacing.space20),

          // Location.
          Text(AppLocalizations.of(context).exLocationLabel,
              style: theme.textTheme.labelLarge),
          const SizedBox(height: RadhaSpacing.space8),
          TextFormField(
            controller: _locationController,
            enabled: !_submitting,
            decoration: InputDecoration(
              hintText:
                  AppLocalizations.of(context).exLocationHint,
            ),
          ),
          const SizedBox(height: RadhaSpacing.space32),

          PrimaryButton(
            label: AppLocalizations.of(context).exSaveRecord,
            expand: true,
            loading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Private widgets
// ─────────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        RadhaSpacing.space24,
        RadhaSpacing.space8,
        RadhaSpacing.space24,
        RadhaSpacing.space4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step ${current + 1} of $total',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: RadhaSpacing.space8),
          ClipRRect(
            borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
            child: LinearProgressIndicator(
              value: (current + 1) / total,
              minHeight: 4,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: const AlwaysStoppedAnimation(RadhaColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card with icon, title, subtitle — used for "Scan barcode" and "Scan
/// dates from pack" call-to-action tiles.
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: RadhaColors.primary.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(RadhaRadii.radiusSm),
                ),
                child: Icon(icon, color: RadhaColors.primary, size: 22),
              ),
              const SizedBox(width: RadhaSpacing.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                        )),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tappable date tile. Highlights when a date is already selected.
class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.hasValue,
    required this.onTap,
  });

  final String label;
  final bool hasValue;
  final VoidCallback onTap;

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
          color: hasValue
              ? RadhaColors.primary.withValues(alpha: 0.06)
              : null,
          border: Border.all(
            color: hasValue
                ? RadhaColors.primary
                : theme.colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(RadhaRadii.radiusSm),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: hasValue
                  ? RadhaColors.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: RadhaSpacing.space8),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: hasValue
                      ? RadhaColors.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight:
                      hasValue ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Green banner shown when the catalog lookup succeeds.
class _ProductFoundBanner extends StatelessWidget {
  const _ProductFoundBanner({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space12,
        vertical: RadhaSpacing.space8,
      ),
      decoration: BoxDecoration(
        color: RadhaColors.success.withValues(alpha: 0.1),
        border: Border.all(color: RadhaColors.success),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusSm),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              color: RadhaColors.success, size: 18),
          const SizedBox(width: RadhaSpacing.space8),
          Expanded(
            child: Text(
              name,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: RadhaColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact recap shown at the top of step 4 so the user can see what they
/// collected before submitting.
class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({
    required this.productName,
    required this.ean,
    required this.expiryDate,
    required this.mfgDate,
    required this.formatDate,
  });

  final String? productName;
  final String ean;
  final DateTime? expiryDate;
  final DateTime? mfgDate;
  final String Function(DateTime?) formatDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = productName ?? ean;
    return Container(
      padding: const EdgeInsets.all(RadhaSpacing.space12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryRow(
            icon: Icons.inventory_2_outlined,
            label: 'Product',
            value: name,
          ),
          const SizedBox(height: RadhaSpacing.space8),
          _SummaryRow(
            icon: Icons.event_outlined,
            label: 'Expires',
            value: formatDate(expiryDate),
          ),
          if (mfgDate != null) ...[
            const SizedBox(height: RadhaSpacing.space8),
            _SummaryRow(
              icon: Icons.factory_outlined,
              label: 'Manufactured',
              value: formatDate(mfgDate),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: RadhaSpacing.space8),
        Text(
          '$label: ',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

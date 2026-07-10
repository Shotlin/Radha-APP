// Batch-aware crowd-sourced expiry scanner (Feature B / Phase 9).
//
// One camera stream feeds two ML Kit recognizers on alternating frames:
//   even frames → BarcodeScanner  (EAN detection, 3-frame consensus)
//   odd  frames → TextRecognizer  (batch code + dates via FrameConsensusAggregator)
//
// Flow:
//   1. EAN confirmed (3 identical frames) → GET /products/lookup/{ean} for name
//   2. Batch code confirmed → GET /products/{ean}/batches/{batch}/dates
//        trusted/candidate hit → dates pre-fill + crowd chip
//        404 → OCR dates stand
//   3. Confirm sheet → two writes:
//        a. POST .../observations  (non-outbox; losing a vote is OK offline)
//        b. Expiry record via offline outbox + Idempotency-Key

import 'dart:async';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:uuid/uuid.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/network/api_client.dart';
import '../../core/network/dto/batch_dates_dto.dart';
import '../../core/network/dto/expiry_dto.dart';
import '../../core/offline/sync_service.dart';
import '../../design/tokens.dart';
import 'camera_image_converter.dart';
import 'domain/frame_consensus_aggregator.dart';
import 'domain/label_field_extractor.dart';
import 'domain/label_field_models.dart';
import 'utils/ean_validator.dart';

const Duration _kFrameInterval = Duration(milliseconds: 600);
const int _kEanRequired = 3;

/// Normalises a batch code to match the backend consensus function:
/// uppercase, strip everything that isn't A-Z 0-9.
String _normBatch(String raw) =>
    raw.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

String _fmtDate(DateTime d) {
  const m = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day.toString().padLeft(2, '0')} ${m[d.month - 1]} ${d.year}';
}

DateTime? _parseIso(String? s) =>
    s == null ? null : DateTime.tryParse(s);

class BatchScanScreen extends ConsumerStatefulWidget {
  const BatchScanScreen({super.key});

  @override
  ConsumerState<BatchScanScreen> createState() => _BatchScanScreenState();
}

class _BatchScanScreenState extends ConsumerState<BatchScanScreen>
    with WidgetsBindingObserver {
  // ── Camera ────────────────────────────────────────────────────────────────
  CameraController? _controller;
  TextRecognizer? _textRecognizer;
  BarcodeScanner? _barcodeScanner;
  bool _ready = false;
  bool _processingFrame = false;
  bool _torch = false;
  String? _error;
  DateTime? _lastProcessedAt;
  int _frameCount = 0;

  // ── EAN (barcode recognizer) ───────────────────────────────────────────────
  String? _ean;
  String? _eanCandidate;
  int _eanStreak = 0;

  // ── OCR (text recognizer via FrameConsensusAggregator) ────────────────────
  final _aggregator = FrameConsensusAggregator();

  // ── Product lookup (fires once EAN is confirmed) ──────────────────────────
  String? _productId;
  String? _productName;
  bool _lookingUpProduct = false;
  bool _productLookupDone = false;

  // ── Batch crowd-dates lookup (fires once batch + EAN both confirmed) ───────
  BatchDatesResponse? _crowdDates;
  bool _lookingUpBatch = false;
  bool _batchLookupDone = false;
  String? _lastLookedUpBatch;

  // ── Confirm sheet ──────────────────────────────────────────────────────────
  bool _showConfirm = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    _barcodeScanner = BarcodeScanner(formats: [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upca,
      BarcodeFormat.upce,
    ]);
    _setup();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _teardown();
    } else if (state == AppLifecycleState.resumed) {
      _setup();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _teardown();
    super.dispose();
  }

  Future<void> _setup() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _error = 'No camera found.');
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );
      _controller = controller;
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      await controller.startImageStream((img) => _onFrame(img, back));
      setState(() {
        _ready = true;
        _error = null;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Camera unavailable. Go back and try again.');
      }
    }
  }

  void _teardown() {
    final c = _controller;
    _controller = null;
    if (c != null) {
      try {
        if (c.value.isStreamingImages) c.stopImageStream();
        c.dispose();
      } catch (_) {}
    }
    _textRecognizer?.close();
    _textRecognizer = null;
    _barcodeScanner?.close();
    _barcodeScanner = null;
  }

  void _onFrame(CameraImage image, CameraDescription camera) {
    if (_processingFrame || !_ready || _showConfirm) return;
    final now = DateTime.now();
    if (_lastProcessedAt != null &&
        now.difference(_lastProcessedAt!) < _kFrameInterval) {
      return;
    }
    _lastProcessedAt = now;
    _processingFrame = true;
    _frameCount++;
    final Future<void> work = (_frameCount % 2 == 0)
        ? _processBarcodeFrame(image, camera)
        : _processTextFrame(image, camera);
    work.whenComplete(() => _processingFrame = false);
  }

  // ── Barcode (even frames) ─────────────────────────────────────────────────

  Future<void> _processBarcodeFrame(
    CameraImage image,
    CameraDescription camera,
  ) async {
    if (_ean != null) return; // already confirmed
    final scanner = _barcodeScanner;
    if (scanner == null) return;
    try {
      final inputImage = cameraImageToInputImage(image, camera);
      if (inputImage == null) return;
      final barcodes = await scanner.processImage(inputImage);
      if (!mounted) return;
      for (final bc in barcodes) {
        final raw = bc.rawValue;
        if (raw == null || !isValidEan(raw)) continue;
        if (raw == _eanCandidate) {
          _eanStreak++;
        } else {
          _eanCandidate = raw;
          _eanStreak = 1;
        }
        if (_eanStreak >= _kEanRequired) {
          final confirmed = _eanCandidate!;
          setState(() => _ean = confirmed);
          HapticFeedback.mediumImpact();
          if (!_productLookupDone) _lookupProduct(confirmed);
        } else {
          setState(() {});
        }
        break; // one barcode per frame is enough
      }
    } catch (_) {}
  }

  // ── OCR text (odd frames) ──────────────────────────────────────────────────

  Future<void> _processTextFrame(
    CameraImage image,
    CameraDescription camera,
  ) async {
    final recognizer = _textRecognizer;
    if (recognizer == null) return;
    try {
      final inputImage = cameraImageToInputImage(image, camera);
      if (inputImage == null) return;
      final recognized = await recognizer.processImage(inputImage);
      if (!mounted) return;
      final text = recognized.text.trim();
      if (text.isEmpty) return;

      final candidates = await compute(LabelFieldExtractor.extract, text);
      if (!mounted) return;
      if (candidates.isEmpty) return;

      _aggregator.addFrame(candidates);
      _aggregator.takeCorrections(); // drain corrections (not shown in this UI)

      final batchStatus = _aggregator.fieldStatus(LabelField.batchNumber);
      if (batchStatus.confirmed &&
          batchStatus.leadingValue != null &&
          _ean != null &&
          !_batchLookupDone) {
        final batch = _normBatch(batchStatus.leadingValue!);
        if (batch.isNotEmpty && batch != _lastLookedUpBatch) {
          _lastLookedUpBatch = batch;
          _lookupBatchDates(_ean!, batch);
        }
      }

      if (mounted) setState(() {});
    } catch (_) {}
  }

  // ── Remote lookups ─────────────────────────────────────────────────────────

  Future<void> _lookupProduct(String ean) async {
    if (_productLookupDone) return;
    setState(() => _lookingUpProduct = true);
    try {
      final result = await ref
          .read(apiClientProvider)
          .getProductLookup(ean, includeNutrition: false);
      if (mounted && result.found && result.product != null) {
        setState(() {
          _productId = result.product!.id;
          _productName = result.product!.name;
        });
      }
    } catch (_) {
      // Non-fatal: product name stays null and productId falls back to EAN.
    } finally {
      if (mounted) {
        setState(() {
          _lookingUpProduct = false;
          _productLookupDone = true;
        });
      }
    }
  }

  Future<void> _lookupBatchDates(String ean, String batch) async {
    if (_batchLookupDone) return;
    setState(() => _lookingUpBatch = true);
    try {
      final dates = await ref
          .read(apiClientProvider)
          .getBatchDates(ean, batch);
      if (mounted) setState(() => _crowdDates = dates);
    } on DioException catch (e) {
      if (e.response?.statusCode != 404) {
        // 404 is expected — this batch has no crowd data yet.
        // Any other error: silently ignore, OCR dates stand.
      }
    } catch (_) {} finally {
      if (mounted) {
        setState(() {
          _lookingUpBatch = false;
          _batchLookupDone = true;
        });
      }
    }
  }

  // ── Derived dates (crowd > OCR) ────────────────────────────────────────────

  DateTime? get _expiryDate {
    final crowdIso = _crowdDates?.expiryDate;
    if (crowdIso != null) return _parseIso(crowdIso);
    final ocrIso =
        _aggregator.fieldStatus(LabelField.expiryDate).leadingValue;
    return _parseIso(ocrIso);
  }

  DateTime? get _mfgDate {
    final crowdIso = _crowdDates?.mfgDate;
    if (crowdIso != null) return _parseIso(crowdIso);
    final ocrIso = _aggregator.fieldStatus(LabelField.mfgDate).leadingValue;
    return _parseIso(ocrIso);
  }

  String? get _confirmedBatch {
    final bs = _aggregator.fieldStatus(LabelField.batchNumber);
    if (!bs.confirmed) return null;
    final raw = bs.leadingValue;
    return raw == null ? null : _normBatch(raw);
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final expiry = _expiryDate;
    if (expiry == null) return;

    setState(() => _submitting = true);
    try {
      final ean = _ean!;
      final batch = _confirmedBatch;
      final mfg = _mfgDate;
      final storeId = ref.read(currentUserProvider)?.selectedStoreId ?? '';
      final productId = _productId ?? ean;

      // 1. Post batch observation (best-effort, non-outbox).
      if (batch != null) {
        try {
          await ref.read(apiClientProvider).postBatchObservation(
            ean, batch,
            CreateObservationDto(
              expiryDate: expiry.toIso8601String().split('T').first,
              mfgDate: mfg?.toIso8601String().split('T').first,
              capturedVia: 'live_scan',
              extractorConfidence: _crowdDates != null ? null : 0.85,
            ),
          );
        } catch (_) {
          // Non-fatal: losing a vote is acceptable offline per spec.
        }
      }

      // 2. Write expiry record via offline-first outbox.
      final dto = CreateExpiryDto(
        productId: productId,
        storeId: storeId,
        expiryDate: expiry.toIso8601String().split('T').first,
        manufactureDate: mfg?.toIso8601String().split('T').first,
        batchNumber: batch,
        source: 'batch_scan',
      );
      final result = await ref
          .read(syncServiceProvider)
          .enqueue<void>(
            endpoint: '/api/v1/expiry-records',
            method: 'POST',
            body: dto.toJson(),
            idempotencyKey: const Uuid().v4(),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.synced
            ? 'Expiry record saved!'
            : 'Saved offline — will sync when connected.'),
      ));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<void> _toggleTorch() async {
    try {
      await _controller
          ?.setFlashMode(_torch ? FlashMode.off : FlashMode.torch);
      if (mounted) setState(() => _torch = !_torch);
    } catch (_) {}
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_error != null) return _buildError();
    return Scaffold(
      backgroundColor: RadhaColors.ink,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_ready && _controller != null) CameraPreview(_controller!),
            IgnorePointer(child: CustomPaint(painter: _ScrimPainter())),
            _buildScanFrame(),
            _buildTopRow(),
            _buildBottomPanel(),
            if (_showConfirm) _buildConfirmSheet(),
          ],
        ),
      ),
    );
  }

  Widget _buildScanFrame() {
    final eanOk = _ean != null;
    return Center(
      child: Container(
        width: 300,
        height: 140,
        decoration: BoxDecoration(
          border: Border.all(
            color: eanOk ? RadhaColors.success : RadhaColors.primary,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    final String status;
    if (_ean == null) {
      final s = _eanStreak;
      status = s > 0 ? 'Reading barcode… $s/$_kEanRequired' : 'Scan product barcode';
    } else if (_confirmedBatch == null) {
      status = 'Barcode ✓ — now point at batch & dates';
    } else {
      status = 'Batch ✓ — ready to save';
    }

    return Positioned(
      top: RadhaSpacing.space8,
      left: RadhaSpacing.space8,
      right: RadhaSpacing.space8,
      child: Row(
        children: [
          _CircleBtn(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: RadhaSpacing.space12,
              vertical: RadhaSpacing.space4,
            ),
            decoration: BoxDecoration(
              color: RadhaColors.ink.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
            ),
            child: Text(
              status,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const Spacer(),
          _CircleBtn(
            icon: _torch ? Icons.flash_on_rounded : Icons.flash_off_rounded,
            active: _torch,
            onTap: _toggleTorch,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Positioned(
      bottom: RadhaSpacing.space24,
      left: RadhaSpacing.space16,
      right: RadhaSpacing.space16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Field chips ──────────────────────────────────────────────────
          if (_ean != null || _confirmedBatch != null || _expiryDate != null)
            _buildFieldCard(),

          const SizedBox(height: 12),

          // ── Action button ────────────────────────────────────────────────
          if (_expiryDate != null && _ean != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => setState(() => _showConfirm = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: RadhaColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(RadhaRadii.radiusMd),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                child: const Text('Review & Save'),
              ),
            )
          else
            Text(
              _ean == null
                  ? 'Aim at the barcode on the pack'
                  : 'Now aim at the dates / batch label',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
        ],
      ),
    );
  }

  Widget _buildFieldCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(RadhaSpacing.space12),
      decoration: BoxDecoration(
        color: RadhaColors.ink.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name / EAN
          if (_ean != null) ...[
            Row(
              children: [
                const Icon(Icons.qr_code, color: Colors.white70, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _lookingUpProduct
                        ? 'Looking up product…'
                        : (_productName ?? _ean!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                _StatusDot(ok: true),
              ],
            ),
            const SizedBox(height: 6),
          ],

          // Batch code
          if (_confirmedBatch != null) ...[
            _FieldRow(
              label: 'Batch',
              value: _confirmedBatch!,
              extra: _crowdChip(),
            ),
            const SizedBox(height: 4),
          ] else if (_ean != null && _lookingUpBatch) ...[
            const _FieldRow(label: 'Batch', value: 'Scanning…'),
            const SizedBox(height: 4),
          ],

          // Expiry
          if (_expiryDate != null) ...[
            _FieldRow(
              label: 'Expiry',
              value: _fmtDate(_expiryDate!),
              crowdSource: _crowdDates?.expiryDate != null,
            ),
            const SizedBox(height: 4),
          ],

          // MFG
          if (_mfgDate != null)
            _FieldRow(
              label: 'MFG',
              value: _fmtDate(_mfgDate!),
              crowdSource: _crowdDates?.mfgDate != null,
            ),
        ],
      ),
    );
  }

  Widget? _crowdChip() {
    final cd = _crowdDates;
    if (cd == null) return null;
    final label = cd.isTrusted
        ? 'Confirmed by ${cd.distinctUsers} users'
        : cd.isCandidate
            ? 'Unverified · ${cd.distinctUsers} user${cd.distinctUsers > 1 ? 's' : ''}'
            : null;
    if (label == null) return null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cd.isTrusted
            ? RadhaColors.success.withValues(alpha: 0.2)
            : Colors.amber.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: cd.isTrusted ? RadhaColors.success : Colors.amber,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          color: cd.isTrusted ? RadhaColors.success : Colors.amber,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildConfirmSheet() {
    final expiry = _expiryDate;
    final mfg = _mfgDate;
    final batch = _confirmedBatch;
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showConfirm = false),
        child: Container(
          color: Colors.black54,
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {}, // don't close when tapping sheet
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _productName ?? _ean ?? 'Product',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _ean ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 20),
                  _SheetRow(label: 'Expiry date',
                      value: expiry != null ? _fmtDate(expiry) : '—'),
                  if (mfg != null) ...[
                    const SizedBox(height: 8),
                    _SheetRow(label: 'Mfg date', value: _fmtDate(mfg)),
                  ],
                  if (batch != null) ...[
                    const SizedBox(height: 8),
                    _SheetRow(label: 'Batch', value: batch),
                  ],
                  if (_crowdDates != null) ...[
                    const SizedBox(height: 12),
                    _crowdChip() ?? const SizedBox.shrink(),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting || expiry == null
                          ? null
                          : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RadhaColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(RadhaRadii.radiusMd),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Confirm & Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Scaffold(
      backgroundColor: RadhaColors.ink,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_outlined,
                color: Colors.white54, size: 48),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go back',
                  style: TextStyle(color: RadhaColors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small helper widgets ───────────────────────────────────────────────────────

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.ok});
  final bool ok;
  @override
  Widget build(BuildContext context) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: ok ? RadhaColors.success : Colors.orange,
          shape: BoxShape.circle,
        ),
      );
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.label,
    required this.value,
    this.extra,
    this.crowdSource = false,
  });
  final String label;
  final String value;
  final Widget? extra;
  final bool crowdSource;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: crowdSource ? RadhaColors.success : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ?extra,
      ],
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.onTap, this.active = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  @override
  Widget build(BuildContext context) => Material(
        color: active
            ? RadhaColors.primary
            : RadhaColors.ink.withValues(alpha: 0.5),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: kMinTouchTarget,
            height: kMinTouchTarget,
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      );
}

class _ScrimPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const w = 300.0;
    const h = 140.0;
    final left = (size.width - w) / 2;
    final top = (size.height - h) / 2;
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(left, top, w, h),
            const Radius.circular(RadhaRadii.radiusMd),
          )),
      ),
      Paint()..color = Colors.black54,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// Quick Audit scan mode (replaces the old OCR-based Batch Scan).
//
// A rapid, continuous stock-check loop for walking a shelf: point the
// camera at a barcode, see whatever's already tracked for that product
// (expiry date, mfg date, current quantity) in a bottom sheet, optionally
// bump the quantity with +/-, tap Save, get a brief confirmation, and the
// camera is immediately ready for the next product — no per-item screen
// transitions.
//
// Flow:
//   1. EAN confirmed (3-frame consensus) → GET /products/lookup/{ean}
//   2. productId resolved → GET /expiry-records?storeId&productId
//        found    → sheet shows product/expiry/mfg/quantity + stepper
//        empty    → "not tracked yet" sheet with Skip / Add
//   3. Quantity changed → Save button appears → PATCH .../expiry-records/:id
//      via the offline-first outbox (same path every other write uses)
//   4. Save succeeds → brief green "Saved" flash → auto-resume scanning
//
// Unlike the old batch scanner, this screen never exits after one item —
// it's designed to be scanned through repeatedly.

import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:uuid/uuid.dart';
import 'package:vibration/vibration.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/network/api_client.dart';
import '../../core/network/dto/expiry_dto.dart';
import '../../core/offline/sync_service.dart';
import '../../core/router/app_router.dart';
import '../../design/tokens.dart';
import 'camera_image_converter.dart';
import 'utils/ean_validator.dart';

const Duration _kFrameInterval = Duration(milliseconds: 400);
const int _kEanRequired = 3;

String _fmtDate(String? iso) {
  if (iso == null) return '—';
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  const m = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day.toString().padLeft(2, '0')} ${m[d.month - 1]} ${d.year}';
}

enum _SheetKind { none, found, notFound }

class QuickAuditScreen extends ConsumerStatefulWidget {
  const QuickAuditScreen({super.key});

  @override
  ConsumerState<QuickAuditScreen> createState() => _QuickAuditScreenState();
}

class _QuickAuditScreenState extends ConsumerState<QuickAuditScreen>
    with WidgetsBindingObserver {
  // ── Camera ────────────────────────────────────────────────────────────
  CameraController? _controller;
  BarcodeScanner? _barcodeScanner;
  bool _ready = false;
  bool _processingFrame = false;
  bool _torch = false;
  String? _error;
  DateTime? _lastProcessedAt;

  // ── EAN consensus ─────────────────────────────────────────────────────
  String? _eanCandidate;
  int _eanStreak = 0;

  // ── Lookup pipeline ───────────────────────────────────────────────────
  bool _lookingUp = false;
  String? _lookupEan;
  String? _productId;
  String? _productName;
  ExpiryResponse? _record;

  // ── Sheet state ───────────────────────────────────────────────────────
  _SheetKind _sheet = _SheetKind.none;
  int? _originalQty;
  int _pendingQty = 0;
  bool _saving = false;
  bool _justSaved = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    _barcodeScanner?.close();
    _barcodeScanner = null;
  }

  void _onFrame(CameraImage image, CameraDescription camera) {
    if (_processingFrame || !_ready || _sheet != _SheetKind.none) return;
    final now = DateTime.now();
    if (_lastProcessedAt != null &&
        now.difference(_lastProcessedAt!) < _kFrameInterval) {
      return;
    }
    _lastProcessedAt = now;
    _processingFrame = true;
    _processBarcodeFrame(image, camera).whenComplete(() => _processingFrame = false);
  }

  Future<void> _processBarcodeFrame(
    CameraImage image,
    CameraDescription camera,
  ) async {
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
          HapticFeedback.mediumImpact();
          _eanStreak = 0;
          _eanCandidate = null;
          _lookup(confirmed);
        } else {
          setState(() {});
        }
        break; // one barcode per frame is enough
      }
    } catch (_) {}
  }

  // ── Lookup pipeline ───────────────────────────────────────────────────

  Future<void> _lookup(String ean) async {
    if (_lookingUp) return;
    setState(() {
      _lookingUp = true;
      _lookupEan = ean;
    });

    final api = ref.read(apiClientProvider);
    String? productId;
    String? productName;
    try {
      final result = await api.getProductLookup(ean, includeNutrition: false);
      if (result.found && result.product != null) {
        productId = result.product!.id;
        productName = result.product!.name;
      }
    } catch (_) {
      // Non-fatal — falls through to the "not tracked" sheet below.
    }

    ExpiryResponse? record;
    if (productId != null) {
      final storeId = ref.read(currentUserProvider)?.selectedStoreId;
      if (storeId != null) {
        try {
          final records = await api.getExpiryRecords(
            storeId: storeId,
            productId: productId,
            limit: 1,
          );
          if (records.isNotEmpty) record = records.first;
        } catch (_) {
          // Non-fatal — falls through to the "not tracked" sheet below.
        }
      }
    }

    if (!mounted) return;
    if (record?.status == 'expired') {
      // Distinct, stronger alert than the barcode-confirm haptic — an
      // expired product needs to grab attention mid-scan, not just click.
      // A single vibrate() reads as a faint click on many devices, so this
      // fires two short pulses plus a system alert sound.
      unawaited(_playExpiredAlert());
    }
    setState(() {
      _lookingUp = false;
      _productId = productId;
      _productName = productName;
      _record = record;
      if (record != null) {
        _originalQty = record.remainingQuantity ?? record.quantity ?? 0;
        _pendingQty = _originalQty!;
        _sheet = _SheetKind.found;
      } else {
        _sheet = _SheetKind.notFound;
      }
    });
  }

  /// Two short vibration pulses plus the system alert sound — fires once
  /// when the sheet opens on an expired product.
  ///
  /// Uses the `vibration` package's direct `Vibrator.vibrate()` call, not
  /// `HapticFeedback.vibrate()` — the latter routes through Android's
  /// "system haptic feedback" setting (`View.performHapticFeedback`), which
  /// several common device makers mute independently of the app's own
  /// VIBRATE permission, so it can silently no-op even when correctly
  /// declared. This bypasses that entirely.
  Future<void> _playExpiredAlert() async {
    SystemSound.play(SystemSoundType.alert);
    try {
      if (await Vibration.hasVibrator()) {
        // pattern: [wait, buzz, wait, buzz] in ms — two distinct pulses.
        Vibration.vibrate(pattern: [0, 300, 150, 300]);
      }
    } catch (_) {
      // No vibrator hardware / platform doesn't support it — sound alone
      // still fired above, so the expired hit isn't silent either way.
    }
  }

  void _adjustQty(int delta) {
    setState(() {
      _pendingQty = (_pendingQty + delta).clamp(0, 100000);
    });
  }

  Future<void> _save() async {
    final record = _record;
    if (record == null || _saving) return;
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      // Offline-queued writes still show the same "Saved" flash — the
      // outbox guarantees delivery once connectivity returns, and a rapid
      // shelf-walk audit can't pause to distinguish the two per item.
      await ref.read(syncServiceProvider).enqueue<void>(
            endpoint: '/api/v1/expiry-records/${record.id}',
            method: 'PATCH',
            body: {'remainingQuantity': _pendingQty},
            idempotencyKey: const Uuid().v4(),
          );
      if (!mounted) return;
      setState(() {
        _saving = false;
        _justSaved = true;
      });
      // Brief, in-place confirmation — no snackbar, no navigation. Auto
      // resumes scanning so a rapid string of scans never has to wait on
      // the user tapping anything extra.
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) _resetForNextScan();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saveError = 'Could not save — try again.';
      });
    }
  }

  void _resetForNextScan() {
    setState(() {
      _sheet = _SheetKind.none;
      _lookupEan = null;
      _productId = null;
      _productName = null;
      _record = null;
      _originalQty = null;
      _pendingQty = 0;
      _justSaved = false;
      _saveError = null;
    });
  }

  Future<void> _toggleTorch() async {
    try {
      await _controller
          ?.setFlashMode(_torch ? FlashMode.off : FlashMode.torch);
      if (mounted) setState(() => _torch = !_torch);
    } catch (_) {}
  }

  // ── Build ────────────────────────────────────────────────────────────

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
            _buildStatusChip(),
            if (_sheet == _SheetKind.found) _buildFoundSheet(),
            if (_sheet == _SheetKind.notFound) _buildNotFoundSheet(),
          ],
        ),
      ),
    );
  }

  Widget _buildScanFrame() {
    return Center(
      child: Container(
        width: 300,
        height: 140,
        decoration: BoxDecoration(
          border: Border.all(
            color: _lookingUp ? RadhaColors.warning : RadhaColors.primary,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        ),
      ),
    );
  }

  Widget _buildTopRow() {
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
            child: const Text(
              'Quick Audit',
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
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

  Widget _buildStatusChip() {
    if (_sheet != _SheetKind.none) return const SizedBox.shrink();
    final String status;
    if (_lookingUp) {
      status = 'Looking up product…';
    } else if (_eanStreak > 0) {
      status = 'Reading barcode… $_eanStreak/$_kEanRequired';
    } else {
      status = 'Aim at a product barcode';
    }
    return Positioned(
      bottom: RadhaSpacing.space32,
      left: RadhaSpacing.space16,
      right: RadhaSpacing.space16,
      child: Center(
        child: Text(
          status,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildFoundSheet() {
    final record = _record;
    if (record == null) return const SizedBox.shrink();
    final changed = _pendingQty != _originalQty;

    return _sheetScaffold(
      onDismiss: _resetForNextScan,
      child: _justSaved
          ? const _SavedFlash()
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dragHandle(),
                const SizedBox(height: 20),
                Text(
                  _productName ?? record.productName ?? _lookupEan ?? 'Product',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _lookupEan ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 20),
                _SheetRow(label: 'Expiry date', value: _fmtDate(record.expiryDate)),
                const SizedBox(height: 8),
                _SheetRow(label: 'Mfg date', value: _fmtDate(record.manufactureDate)),
                const SizedBox(height: 16),
                _StatusPill(status: record.status),
                if (record.status == 'expired') ...[
                  const SizedBox(height: 8),
                  const Text(
                    'This product has expired — do not sell or use it.',
                    style: TextStyle(color: RadhaColors.danger, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quantity',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    _QtyStepper(
                      value: _pendingQty,
                      onDecrement: () => _adjustQty(-1),
                      onIncrement: () => _adjustQty(1),
                    ),
                  ],
                ),
                if (_saveError != null) ...[
                  const SizedBox(height: 12),
                  Text(_saveError!, style: const TextStyle(color: RadhaColors.danger, fontSize: 13)),
                ],
                if (changed) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RadhaColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Save'),
                    ),
                  ),
                ] else
                  const SizedBox(height: 8),
              ],
            ),
    );
  }

  Widget _buildNotFoundSheet() {
    return _sheetScaffold(
      onDismiss: _resetForNextScan,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dragHandle(),
          const SizedBox(height: 20),
          Text(
            _productName ?? _lookupEan ?? 'Product',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _lookupEan ?? '',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Not in your expiry tracker yet.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetForNextScan,
                  child: const Text('Skip'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final ean = _lookupEan;
                    final productId = _productId;
                    final productName = _productName;
                    _resetForNextScan();
                    context.push(AppRoute.expiryNew, extra: {
                      if (ean != null) 'ean': ean,
                      if (productId != null) 'productId': productId,
                      if (productName != null) 'productName': productName,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RadhaColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sheetScaffold({required Widget child, required VoidCallback onDismiss}) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onDismiss,
        child: Container(
          color: Colors.black54,
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {}, // absorb taps so the sheet itself doesn't dismiss
            onVerticalDragEnd: (details) {
              if ((details.primaryVelocity ?? 0) > 200) onDismiss();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(2),
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
            const Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 48),
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
              child: const Text('Go back', style: TextStyle(color: RadhaColors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small helper widgets ─────────────────────────────────────────────────

/// Green "Safe" / yellow "Soon" / red "Expired" indicator on the found
/// sheet — mirrors the backend's `status` field (green|yellow|red|expired,
/// tenant-threshold-aware) rather than recomputing from the raw date, so it
/// always agrees with the Soon/Expired/Safe tabs on the Expiry tracker.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final String? status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      'green' => (RadhaColors.success, 'Safe'),
      'yellow' || 'red' => (RadhaColors.warning, 'Soon'),
      'expired' => (RadhaColors.danger, 'Expired'),
      _ => (RadhaColors.inkMuted, 'Unknown'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _SavedFlash extends StatelessWidget {
  const _SavedFlash();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 140,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, color: RadhaColors.success, size: 48),
          SizedBox(height: 8),
          Text('Saved', style: TextStyle(color: RadhaColors.success, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _stepBtn(Icons.remove_rounded, onDecrement, theme),
        SizedBox(
          width: 40,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        _stepBtn(Icons.add_rounded, onIncrement, theme),
      ],
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap, ThemeData theme) {
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(width: 36, height: 36, child: Icon(icon, size: 18)),
      ),
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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
        color: active ? RadhaColors.primary : RadhaColors.ink.withValues(alpha: 0.5),
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

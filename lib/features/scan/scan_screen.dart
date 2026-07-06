import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/router/app_router.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../l10n/generated/app_localizations.dart';
import 'utils/ean_validator.dart';

/// Side length of the central scan window / reticle, in logical pixels.
const double _kFrame = 260;

/// After this long with no successful scan we surface the "trouble scanning?"
/// helper (flash + scan-the-label fallback).
const Duration _kHelpAfter = Duration(seconds: 8);

/// Local session-scoped scan history. Resets when the app is killed.
final _scanHistoryProvider = StateProvider<List<String>>((ref) => []);

/// Full-screen barcode scanner. A dimmed scrim with a clear centre cut-out
/// frames the live camera; orange corner brackets + an animated scan-line
/// guide the user. Flashlight toggle, "enter manually", and a scan-history
/// sheet round it out. On web (no camera API) it falls back to a manual EAN
/// entry screen.
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  MobileScannerController? _controller;

  /// The user's *desired* torch setting. The actual hardware state lives in
  /// `_controller.value.torchState` (the icon renders from that, never from
  /// this) — the plugin force-resets the torch to off on every `stop()`, so
  /// after each scan→result→back round trip we re-apply this preference.
  bool _wantTorch = false;
  bool _processing = false;

  // Batch (continuous) scan mode — built for staff doing shelf audits.
  bool _batchMode = false;
  int _batchCount = 0;
  String? _lastBatchCode;
  DateTime? _lastBatchAt;

  // Pinch-zoom state (mobile_scanner uses a normalised 0..1 zoom scale).
  double _zoom = 0;
  double _baseZoom = 0;

  // Low-light / no-detection helper.
  bool _showHelp = false;
  Timer? _helpTimer;

  final TextEditingController _webEanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = MobileScannerController(
        // `noDuplicates` debounces repeated reads of the same code — better for
        // both single and batch modes.
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        // Higher analysis resolution keeps dense EAN-13 bars resolvable when
        // the phone is held close to small packs (the default feed is too
        // coarse for close-up scans on many devices).
        cameraResolution: const Size(1920, 1080),
        // Restrict to retail barcode symbologies → faster lock-on, fewer
        // false reads from QR/other codes on packaging.
        formats: const [
          BarcodeFormat.ean13,
          BarcodeFormat.ean8,
          BarcodeFormat.upcA,
          BarcodeFormat.upcE,
        ],
      );
      _startHelpTimer();
    }
  }

  @override
  void dispose() {
    _helpTimer?.cancel();
    _controller?.dispose();
    _webEanController.dispose();
    super.dispose();
  }

  void _startHelpTimer() {
    _helpTimer?.cancel();
    if (mounted) setState(() => _showHelp = false);
    _helpTimer = Timer(_kHelpAfter, () {
      if (mounted && !_batchMode) setState(() => _showHelp = true);
    });
  }

  /// First valid EAN/UPC in the capture, or null.
  String? _firstValidCode(BarcodeCapture capture) {
    for (final b in capture.barcodes) {
      final v = b.rawValue;
      if (v != null && isValidEan(v)) return v;
    }
    return null;
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    final code = _firstValidCode(capture);
    if (code == null) return;

    if (_batchMode) {
      // Debounce the same code so a lingering item isn't counted repeatedly.
      final now = DateTime.now();
      if (_lastBatchCode == code &&
          _lastBatchAt != null &&
          now.difference(_lastBatchAt!).inMilliseconds < 2500) {
        return;
      }
      _lastBatchCode = code;
      _lastBatchAt = now;
      HapticFeedback.lightImpact();
      ref.read(_scanHistoryProvider.notifier).update((list) => [code, ...list]);
      setState(() => _batchCount++);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 900),
            behavior: SnackBarBehavior.floating,
            content: Text(
              AppLocalizations.of(context).scanBatchAdded(code, _batchCount),
            ),
          ),
        );
      return;
    }

    if (_processing) return;
    _processing = true;
    HapticFeedback.mediumImpact();
    _helpTimer?.cancel();
    _controller?.stop();

    ref.read(_scanHistoryProvider.notifier).update((list) => [code, ...list]);

    context.push('/scan/result/$code').then((_) async {
      if (mounted) {
        _processing = false;
        await _controller?.start();
        // stop() force-reset the torch; restore the user's setting.
        if (mounted) await _applyTorch();
        if (mounted) _startHelpTimer();
      }
    });
  }

  void _toggleBatchMode() {
    HapticFeedback.selectionClick();
    setState(() {
      _batchMode = !_batchMode;
      _batchCount = 0;
      _lastBatchCode = null;
      _showHelp = false;
    });
    if (_batchMode) {
      _helpTimer?.cancel();
    } else {
      _startHelpTimer();
    }
  }

  void _onZoomStart(ScaleStartDetails _) => _baseZoom = _zoom;

  void _onZoomUpdate(ScaleUpdateDetails details) {
    if (_controller == null) return;
    final next = (_baseZoom + (details.scale - 1) * 0.6).clamp(0.0, 1.0);
    if ((next - _zoom).abs() < 0.005) return;
    setState(() => _zoom = next);
    _controller!.setZoomScale(next);
  }

  void _openLabelScan() {
    HapticFeedback.selectionClick();
    context.push(AppRoute.labelScan);
  }

  Future<void> _galleryImport() async {
    HapticFeedback.selectionClick();
    final XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null || !mounted) return;
    final capture = await _controller?.analyzeImage(file.path);
    final code = capture == null ? null : _firstValidCode(capture);
    if (!mounted) return;
    if (code != null) {
      HapticFeedback.mediumImpact();
      ref.read(_scanHistoryProvider.notifier).update((list) => [code, ...list]);
      context.push('/scan/result/$code');
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(AppLocalizations.of(context).scanGalleryNoBarcode),
          ),
        );
    }
  }

  void _onWebLookup() {
    final code = _webEanController.text.trim();
    if (!isValidEan(code)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).scanInvalidEan),
        ),
      );
      return;
    }
    HapticFeedback.mediumImpact();
    ref.read(_scanHistoryProvider.notifier).update((list) => [code, ...list]);
    context.push('/scan/result/$code');
  }

  void _toggleTorch() {
    HapticFeedback.selectionClick();
    _wantTorch = !_wantTorch;
    _applyTorch();
  }

  /// Drives the hardware torch towards [_wantTorch]. Reads the plugin's own
  /// state notion so a toggle is only issued on a genuine mismatch — calling
  /// `toggleTorch()` blindly inverts, which is how the icon and the LED got
  /// out of sync before.
  Future<void> _applyTorch() async {
    final controller = _controller;
    if (controller == null) return;
    final actual = controller.value.torchState;
    if (actual == TorchState.unavailable) return;
    final isOn = actual == TorchState.on;
    if (isOn != _wantTorch) {
      try {
        await controller.toggleTorch();
      } catch (_) {
        // Camera mid-restart — the post-start re-apply will retry.
      }
    }
  }

  Future<void> _manualEntry() async {
    HapticFeedback.selectionClick();
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const _ManualEntrySheet(),
    );
    if (code != null && code.isNotEmpty && mounted) {
      ref.read(_scanHistoryProvider.notifier).update((l) => [code, ...l]);
      if (mounted) context.push('/scan/result/$code');
    }
  }

  void _showHistory() {
    HapticFeedback.selectionClick();
    final history = ref.read(_scanHistoryProvider);
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => _ScanHistorySheet(history: history),
    );
  }

  void _openBulkAudit() {
    HapticFeedback.selectionClick();
    context.push(AppRoute.eanAudit);
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return _buildWebFallback(context);
    return _buildCameraScanner(context);
  }

  Widget _buildCameraScanner(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    final topPad = media.padding.top;
    final bottomPad = media.padding.bottom;
    // Restrict detection to the central reticle for faster, steadier lock-on.
    final scanWindow = Rect.fromCenter(
      center: Offset(media.size.width / 2, media.size.height / 2),
      width: _kFrame,
      height: _kFrame,
    );

    return Scaffold(
      backgroundColor: RadhaColors.ink,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen camera preview. Pinch to zoom; detection is limited to
          // the central window so off-centre packaging codes don't mis-trigger.
          GestureDetector(
            onScaleStart: _onZoomStart,
            onScaleUpdate: _onZoomUpdate,
            child: MobileScanner(
              controller: _controller!,
              onDetect: _onBarcodeDetected,
              scanWindow: scanWindow,
              fit: BoxFit.cover,
            ),
          ),

          // Dimmed scrim with a clear centre cut-out + animated reticle.
          const Positioned.fill(child: _ScannerReticle()),

          // Translucent top bar: back, title, torch.
          Positioned(
            top: topPad + RadhaSpacing.space8,
            left: RadhaSpacing.space8,
            right: RadhaSpacing.space8,
            child: Row(
              children: [
                _CircularIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () {
                    if (context.canPop()) context.pop();
                  },
                ),
                Expanded(
                  child: Text(
                    l10n.scanTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: RadhaColors.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _CircularIconButton(
                  icon: _batchMode
                      ? Icons.dynamic_feed_rounded
                      : Icons.filter_none_rounded,
                  active: _batchMode,
                  onTap: _toggleBatchMode,
                ),
                const SizedBox(width: RadhaSpacing.space8),
                // Icon renders from the controller's REAL torch state (the
                // plugin resets it on stop/start), so it can never show "on"
                // while the LED is off.
                ValueListenableBuilder<MobileScannerState>(
                  valueListenable: _controller!,
                  builder: (context, state, _) {
                    final on = state.torchState == TorchState.on;
                    return _CircularIconButton(
                      icon: on
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      active: on,
                      onTap: _toggleTorch,
                    );
                  },
                ),
              ],
            ),
          ),

          // Dynamic helper below the frame: a low-light/no-detection rescue
          // card after a few idle seconds, a batch-mode hint, or the default
          // alignment nudge.
          Positioned(
            left: RadhaSpacing.space24,
            right: RadhaSpacing.space24,
            bottom: 184,
            child: Center(
              child: _showHelp
                  ? _TroubleCard(onFlash: _toggleTorch, onLabel: _openLabelScan)
                  : _HelperPill(
                      text: _batchMode ? l10n.scanBatchHint : l10n.scanAlignHint,
                    ),
            ),
          ),

          // Bottom controls.
          Positioned(
            left: RadhaSpacing.space24,
            right: RadhaSpacing.space24,
            bottom: bottomPad + RadhaSpacing.space32,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: RadhaSpacing.space12,
              runSpacing: RadhaSpacing.space12,
              children: [
                if (_batchMode)
                  _PillTextButton(
                    icon: Icons.check_circle_rounded,
                    label: l10n.scanBatchDone(_batchCount),
                    onTap: _toggleBatchMode,
                  ),
                _PillTextButton(
                  icon: Icons.document_scanner_outlined,
                  label: l10n.scanLabelAction,
                  onTap: _openLabelScan,
                ),
                _PillTextButton(
                  icon: Icons.photo_library_outlined,
                  label: l10n.scanGalleryAction,
                  onTap: _galleryImport,
                ),
                _PillTextButton(
                  icon: Icons.keyboard_rounded,
                  label: l10n.scanEnterManually,
                  onTap: _manualEntry,
                ),
                _PillTextButton(
                  icon: Icons.fact_check_outlined,
                  label: l10n.scanBulkAudit,
                  onTap: _openBulkAudit,
                ),
                _PillTextButton(
                  icon: Icons.history_rounded,
                  label: l10n.scanHistoryAction,
                  onTap: _showHistory,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebFallback(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanWebTitle)),
      body: Padding(
        padding: const EdgeInsets.all(RadhaSpacing.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.qr_code_scanner_rounded,
              size: 64,
              color: RadhaColors.primary,
            ),
            const SizedBox(height: RadhaSpacing.space24),
            Text(
              l10n.scanWebUnavailable,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: RadhaSpacing.space24),
            TextField(
              controller: _webEanController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.scanEanFieldLabel,
                hintText: l10n.scanEanHintExample,
              ),
              onSubmitted: (_) => _onWebLookup(),
            ),
            const SizedBox(height: RadhaSpacing.space16),
            SizedBox(
              height: kMinTouchTarget,
              width: double.infinity,
              child: FilledButton(
                onPressed: _onWebLookup,
                child: Text(l10n.scanLookUp),
              ),
            ),
            const SizedBox(height: RadhaSpacing.space16),
            TextButton.icon(
              onPressed: _showHistory,
              icon: const Icon(Icons.history),
              label: Text(l10n.scanHistoryTitle),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reticle (scrim + cut-out + corners + scan line) ─────────────────────────

/// Paints a dark scrim over the camera with a clear rounded cut-out window,
/// orange corner brackets, and a vertical scan-line that sweeps up and down
/// inside the window. Honors `disableAnimations` (static line when reduced).
class _ScannerReticle extends StatefulWidget {
  const _ScannerReticle();

  @override
  State<_ScannerReticle> createState() => _ScannerReticleState();
}

class _ScannerReticleState extends State<_ScannerReticle>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion || _ctrl != null) return;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _ctrl;
    if (ctrl == null) {
      return IgnorePointer(
        child: CustomPaint(painter: _ReticlePainter(lineT: 0.5)),
      );
    }
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: ctrl,
        builder: (context, _) =>
            CustomPaint(painter: _ReticlePainter(lineT: ctrl.value)),
      ),
    );
  }
}

class _ReticlePainter extends CustomPainter {
  _ReticlePainter({required this.lineT});

  /// 0..1 vertical position of the scan line within the window.
  final double lineT;

  static const double _frame = 260;
  static const double _radius = 20;
  static const double _cornerLen = 30;
  static const double _cornerW = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCenter(
      center: center,
      width: _frame,
      height: _frame,
    );
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(_radius),
    );

    // Scrim with the window punched out.
    final scrim = Paint()..color = RadhaColors.ink.withValues(alpha: 0.62);
    final scrimPath = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(scrimPath, scrim);

    // Corner brackets.
    final corner = Paint()
      ..color = RadhaColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = _cornerW
      ..strokeCap = StrokeCap.round;
    final l = rect.left, t = rect.top, r = rect.right, b = rect.bottom;
    // top-left
    canvas.drawLine(Offset(l, t + _cornerLen), Offset(l, t + _radius), corner);
    canvas.drawLine(Offset(l + _radius, t), Offset(l + _cornerLen, t), corner);
    // top-right
    canvas.drawLine(Offset(r - _cornerLen, t), Offset(r - _radius, t), corner);
    canvas.drawLine(Offset(r, t + _radius), Offset(r, t + _cornerLen), corner);
    // bottom-left
    canvas.drawLine(Offset(l, b - _cornerLen), Offset(l, b - _radius), corner);
    canvas.drawLine(Offset(l + _radius, b), Offset(l + _cornerLen, b), corner);
    // bottom-right
    canvas.drawLine(Offset(r - _cornerLen, b), Offset(r - _radius, b), corner);
    canvas.drawLine(Offset(r, b - _cornerLen), Offset(r, b - _radius), corner);

    // Scan line — clipped to the window, with a soft gradient glow.
    canvas.save();
    canvas.clipRRect(rrect);
    final y = rect.top + 16 + (rect.height - 32) * lineT;
    final glow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          RadhaColors.primary.withValues(alpha: 0.0),
          RadhaColors.primary.withValues(alpha: 0.28),
          RadhaColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(rect.left, y - 18, rect.width, 36));
    canvas.drawRect(Rect.fromLTWH(rect.left, y - 18, rect.width, 36), glow);
    final line = Paint()
      ..color = RadhaColors.primary
      ..strokeWidth = 2;
    canvas.drawLine(Offset(rect.left + 8, y), Offset(rect.right - 8, y), line);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ReticlePainter old) => old.lineT != lineT;
}

// ─── Small UI pieces ─────────────────────────────────────────────────────────

class _HelperPill extends StatelessWidget {
  const _HelperPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space16,
        vertical: RadhaSpacing.space8,
      ),
      decoration: BoxDecoration(
        color: RadhaColors.ink.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: RadhaColors.onPrimary,
        ),
      ),
    );
  }
}

/// Appears after a few seconds of no successful scan — the low-light / damaged
/// barcode rescue. Offers the flash and the OCR "scan the label" fallback so
/// the user is never stuck on a barcode that won't read.
class _TroubleCard extends StatelessWidget {
  const _TroubleCard({required this.onFlash, required this.onLabel});

  final VoidCallback onFlash;
  final VoidCallback onLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(RadhaSpacing.space16),
      decoration: BoxDecoration(
        color: RadhaColors.ink.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
        border: Border.all(color: RadhaColors.onPrimary.withValues(alpha: 0.12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.scanTroubleTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              color: RadhaColors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: RadhaSpacing.space4),
          Text(
            l10n.scanTroubleBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: RadhaColors.onPrimary.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: RadhaSpacing.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PillTextButton(
                icon: Icons.flash_on_rounded,
                label: l10n.scanFlash,
                onTap: onFlash,
              ),
              const SizedBox(width: RadhaSpacing.space12),
              _PillTextButton(
                icon: Icons.document_scanner_outlined,
                label: l10n.scanLabelAction,
                onTap: onLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 44pt+ circular icon button used in the top bar. Tints orange when active.
class _CircularIconButton extends StatelessWidget {
  const _CircularIconButton({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Material(
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
          child: Icon(icon, color: RadhaColors.onPrimary, size: 22),
        ),
      ),
    );
  }
}

/// Translucent pill text-button for the bottom controls.
class _PillTextButton extends StatelessWidget {
  const _PillTextButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: RadhaColors.ink.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: RadhaSpacing.space16,
            vertical: RadhaSpacing.space12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: RadhaColors.onPrimary, size: 18),
              const SizedBox(width: RadhaSpacing.space8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: RadhaColors.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Manual EAN entry bottom sheet — used as the "enter manually" path on the
/// camera scanner. Returns the entered code via `Navigator.pop`.
class _ManualEntrySheet extends StatefulWidget {
  const _ManualEntrySheet();

  @override
  State<_ManualEntrySheet> createState() => _ManualEntrySheetState();
}

class _ManualEntrySheetState extends State<_ManualEntrySheet> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _controller.text.trim();
    if (!isValidEan(code)) {
      setState(
        () => _error = AppLocalizations.of(context).scanInvalidEan,
      );
      return;
    }
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        RadhaSpacing.space24,
        RadhaSpacing.space24,
        RadhaSpacing.space24,
        RadhaSpacing.space24 + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.scanEnterBarcode, style: theme.textTheme.titleLarge),
          const SizedBox(height: RadhaSpacing.space16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              hintText: l10n.scanEanHintExample,
              errorText: _error,
            ),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: RadhaSpacing.space16),
          SizedBox(
            width: double.infinity,
            height: kMinTouchTarget,
            child: FilledButton(
              onPressed: _submit,
              child: Text(l10n.scanLookUp),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet listing this session's scan history.
class _ScanHistorySheet extends StatelessWidget {
  const _ScanHistorySheet({required this.history});

  final List<String> history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: RadhaSpacing.space16,
          vertical: RadhaSpacing.space24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.scanHistoryTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: RadhaSpacing.space16),
            if (history.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: RadhaSpacing.space24,
                ),
                child: Center(
                  child: Text(
                    l10n.scanNoHistory,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: history.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: RadhaSpacing.space8),
                  itemBuilder: (ctx, i) => Material(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
                      ),
                      leading: const Icon(
                        Icons.qr_code_2_rounded,
                        color: RadhaColors.primary,
                      ),
                      title: Text(
                        history[i],
                        style: radhaMonoStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push('/scan/result/${history[i]}');
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

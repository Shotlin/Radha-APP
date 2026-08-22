import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../design/tokens.dart';
import '../scan/domain/barcode_candidate_tracker.dart';
import '../scan/utils/ean_validator.dart';

const int _kRequiredAgreement = 3;

/// How many times a camera-start failure auto-retries before falling back to
/// a manual Retry button — see [_EanPickerScreenState._buildCameraError].
const int _kMaxAutoRetries = 3;
const Duration _kRetryDelay = Duration(milliseconds: 500);

/// Minimal full-screen barcode scanner that returns a single validated EAN
/// string to its caller via [Navigator.pop]. Used by the expiry wizard's
/// first step so the form can look up the product in the catalog without
/// going through the full scan→result flow.
class EanPickerScreen extends StatefulWidget {
  const EanPickerScreen({super.key});

  @override
  State<EanPickerScreen> createState() => _EanPickerScreenState();
}

class _EanPickerScreenState extends State<EanPickerScreen>
    with WidgetsBindingObserver {
  late final MobileScannerController _controller;

  // Multi-frame consensus — same hysteresis tracker used by the main scan
  // tab (see barcode_candidate_tracker.dart): a single stray misread decays
  // an in-progress candidate instead of resetting it to square one.
  final _tracker = BarcodeCandidateTracker(requiredAgreement: _kRequiredAgreement);

  bool _torch = false;
  bool _accepted = false;

  // This screen is pushed on top of the tab shell while the Scan tab's own
  // camera controller may still be alive underneath it (the shell keeps
  // inactive tabs mounted). If that controller still holds the camera when
  // this one tries to start, Android's camera stack rejects the second
  // session and mobile_scanner surfaces it as an error — which by default
  // renders as a bare icon with no way out. Auto-retry a few times (the
  // other session's release is usually a few hundred ms away), then fall
  // back to a manual retry so the user is never stuck on a dead screen.
  int _retryAttempts = 0;
  bool _retryScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 200,
      facing: CameraFacing.back,
      formats: const [
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
      ],
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) return;
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _controller.stop();
      case AppLifecycleState.resumed:
        _controller.start();
      case AppLifecycleState.detached:
        break;
    }
  }

  String? _firstValidCode(BarcodeCapture capture) {
    for (final b in capture.barcodes) {
      final v = b.rawValue;
      if (v != null && isValidEan(v)) return v;
    }
    return null;
  }

  void _onDetect(BarcodeCapture capture) {
    if (_accepted) return;
    final code = _firstValidCode(capture);
    if (code == null) return;
    if (!_tracker.addRead(code)) return;

    if (_tracker.confirmed) {
      _accepted = true;
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop(_tracker.code);
      return;
    }
    if (mounted) setState(() {});
  }

  Future<void> _toggleTorch() async {
    try {
      await _controller.toggleTorch();
      if (mounted) setState(() => _torch = !_torch);
    } catch (_) {}
  }

  void _retryNow() {
    setState(() {
      _retryAttempts = 0;
      _retryScheduled = false;
    });
    _controller.start().catchError((_) {});
  }

  Widget _buildCameraError(
    BuildContext context,
    MobileScannerException error,
    Widget? child,
  ) {
    final permanent = error.errorCode == MobileScannerErrorCode.permissionDenied ||
        error.errorCode == MobileScannerErrorCode.unsupported;

    if (!permanent && !_retryScheduled && _retryAttempts < _kMaxAutoRetries) {
      _retryScheduled = true;
      _retryAttempts++;
      Future.delayed(_kRetryDelay, () {
        _retryScheduled = false;
        if (!mounted) return;
        _controller.start().catchError((_) {});
      });
    }

    final String message;
    final bool showRetryButton;
    switch (error.errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        message = 'Camera permission is needed to scan a barcode. '
            'Please allow it in system settings.';
        showRetryButton = false;
      case MobileScannerErrorCode.unsupported:
        message = 'Scanning isn\'t supported on this device.';
        showRetryButton = false;
      default:
        final outOfAutoRetries = _retryAttempts >= _kMaxAutoRetries;
        message = outOfAutoRetries
            ? 'Camera is busy. This can happen right after leaving another '
                'scan screen — try again in a moment.'
            : 'Starting camera…';
        showRetryButton = outOfAutoRetries;
    }

    return ColoredBox(
      color: RadhaColors.ink,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(RadhaSpacing.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: RadhaColors.onPrimary,
                size: 40,
              ),
              const SizedBox(height: RadhaSpacing.space12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: RadhaColors.onPrimary),
              ),
              if (showRetryButton) ...[
                const SizedBox(height: RadhaSpacing.space16),
                FilledButton(
                  onPressed: _retryNow,
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: RadhaColors.ink,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: _buildCameraError,
            ),
            // Dimmed scrim with clear centre rectangle cut-out.
            IgnorePointer(
              child: CustomPaint(painter: _ScrimPainter()),
            ),
            // Orange scan-frame border.
            Center(
              child: Container(
                width: 260,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: RadhaColors.primary, width: 3),
                  borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
                ),
              ),
            ),
            // Top controls.
            Positioned(
              top: RadhaSpacing.space8,
              left: RadhaSpacing.space8,
              right: RadhaSpacing.space8,
              child: Row(
                children: [
                  _CircleButton(
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
                      borderRadius:
                          BorderRadius.circular(RadhaRadii.radiusFull),
                    ),
                    child: Text(
                      _tracker.code != null
                          ? 'Confirming… ${_tracker.streak} / $_kRequiredAgreement'
                          : 'Point at barcode',
                      style: const TextStyle(
                        color: RadhaColors.onPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _CircleButton(
                    icon: _torch
                        ? Icons.flash_on_rounded
                        : Icons.flash_off_rounded,
                    active: _torch,
                    onTap: _toggleTorch,
                  ),
                ],
              ),
            ),
            // Bottom hint.
            Positioned(
              bottom: RadhaSpacing.space32,
              left: RadhaSpacing.space24,
              right: RadhaSpacing.space24,
              child: Text(
                'Align the barcode inside the frame',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: RadhaColors.onPrimary.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrimPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const frameW = 260.0;
    const frameH = 120.0;
    final left = (size.width - frameW) / 2;
    final top = (size.height - frameH) / 2;
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(left, top, frameW, frameH),
              const Radius.circular(RadhaRadii.radiusMd),
            ),
          ),
      ),
      Paint()..color = Colors.black54,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
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

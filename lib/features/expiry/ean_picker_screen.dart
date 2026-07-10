import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../design/tokens.dart';
import '../scan/utils/ean_validator.dart';

const int _kRequiredAgreement = 3;

/// Minimal full-screen barcode scanner that returns a single validated EAN
/// string to its caller via [Navigator.pop]. Used by the expiry wizard's
/// first step so the form can look up the product in the catalog without
/// going through the full scan→result flow.
class EanPickerScreen extends StatefulWidget {
  const EanPickerScreen({super.key});

  @override
  State<EanPickerScreen> createState() => _EanPickerScreenState();
}

class _EanPickerScreenState extends State<EanPickerScreen> {
  late final MobileScannerController _controller;
  bool _torch = false;
  String? _candidate;
  int _streak = 0;
  bool _accepted = false;

  @override
  void initState() {
    super.initState();
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
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_accepted) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null || !isValidEan(raw)) continue;
      if (raw == _candidate) {
        _streak++;
        if (_streak >= _kRequiredAgreement) {
          _accepted = true;
          HapticFeedback.mediumImpact();
          Navigator.of(context).pop(raw);
          return;
        }
      } else {
        _candidate = raw;
        _streak = 1;
      }
      break;
    }
    if (mounted) setState(() {});
  }

  Future<void> _toggleTorch() async {
    try {
      await _controller.toggleTorch();
      if (mounted) setState(() => _torch = !_torch);
    } catch (_) {}
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
                      _candidate != null
                          ? 'Confirming… $_streak / $_kRequiredAgreement'
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

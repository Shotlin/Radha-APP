import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../design/tokens.dart';
import '../scan/camera_image_converter.dart';
import '../scan/domain/label_field_extractor.dart';
import '../scan/domain/label_field_models.dart';

/// Which date field this scanner is looking for.
enum DateScanMode { expiry, mfg }

// Auto-confirm after 3 frames agree. User can also tap "Confirm" immediately.
const int _kRequired = 3;
const Duration _kFrameInterval = Duration(milliseconds: 300);

/// Barcode-scanner-style full-screen screen that reads a single date field
/// (expiry or manufacturing) from a product label using ML Kit OCR.
///
/// Returns a [DateTime] via [Navigator.pop] when detected. The user can
/// confirm immediately via the Confirm button, or wait for [_kRequired]
/// consecutive frames to auto-confirm.
class DateScannerScreen extends StatefulWidget {
  const DateScannerScreen({super.key, required this.mode});

  final DateScanMode mode;

  @override
  State<DateScannerScreen> createState() => _DateScannerScreenState();
}

class _DateScannerScreenState extends State<DateScannerScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  TextRecognizer? _recognizer;
  bool _ready = false;
  bool _processingFrame = false;
  bool _torch = false;
  bool _accepted = false;
  String? _error;
  DateTime? _lastProcessedAt;

  DateTime? _candidate;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
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
        if (mounted) setState(() => _error = 'No camera found on this device.');
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
        // nv21 required for vivo I2217 (Android 15 / Qualcomm ISP).
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
    _recognizer?.close();
    _recognizer = null;
  }

  void _onFrame(CameraImage image, CameraDescription camera) {
    if (_processingFrame || !_ready || _accepted) return;
    final now = DateTime.now();
    if (_lastProcessedAt != null &&
        now.difference(_lastProcessedAt!) < _kFrameInterval) {
      return;
    }
    _lastProcessedAt = now;
    _processingFrame = true;
    _processFrame(image, camera).whenComplete(() => _processingFrame = false);
  }

  Future<void> _processFrame(
    CameraImage image,
    CameraDescription camera,
  ) async {
    final recognizer = _recognizer;
    if (recognizer == null || _accepted) return;
    try {
      final inputImage = cameraImageToInputImage(image, camera);
      if (inputImage == null) return;
      final recognized = await recognizer.processImage(inputImage);
      if (!mounted || _accepted) return;
      final text = recognized.text.trim();
      if (text.isEmpty) return;

      final candidates = await compute(LabelFieldExtractor.extract, text);
      if (!mounted || _accepted) return;

      final field = widget.mode == DateScanMode.expiry
          ? LabelField.expiryDate
          : LabelField.mfgDate;
      final hit = candidates.byField[field];
      if (hit == null) return;

      final date = DateTime.tryParse(hit.value);
      if (date == null) return;

      _checkStreak(date);
    } catch (_) {}
  }

  void _checkStreak(DateTime date) {
    if (_candidate != null && _sameDay(_candidate!, date)) {
      _streak++;
    } else {
      _candidate = date;
      _streak = 1;
    }

    if (_streak >= _kRequired && !_accepted) {
      _confirmDate(_candidate!);
      return;
    }
    if (mounted) setState(() {});
  }

  void _confirmDate(DateTime date) {
    if (_accepted) return;
    _accepted = true;
    HapticFeedback.mediumImpact();
    final c = _controller;
    if (c != null && c.value.isStreamingImages) {
      c.stopImageStream().then((_) {
        if (mounted) Navigator.of(context).pop(date);
      });
    } else {
      if (mounted) Navigator.of(context).pop(date);
    }
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _toggleTorch() async {
    try {
      await _controller
          ?.setFlashMode(_torch ? FlashMode.off : FlashMode.torch);
      if (mounted) setState(() => _torch = !_torch);
    } catch (_) {}
  }

  String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day.toString().padLeft(2, '0')} '
        '${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final hint = widget.mode == DateScanMode.expiry
        ? 'expiry date'
        : 'manufacturing date';

    if (_error != null) {
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
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 14),
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

    return Scaffold(
      backgroundColor: RadhaColors.ink,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Camera preview
            if (_ready && _controller != null) CameraPreview(_controller!),

            // Dimmed scrim with transparent centre rectangle.
            IgnorePointer(child: CustomPaint(painter: _ScrimPainter())),

            // Orange scan-frame border.
            Center(
              child: Container(
                width: 280,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _candidate != null
                        ? RadhaColors.success
                        : RadhaColors.primary,
                    width: 3,
                  ),
                  borderRadius:
                      BorderRadius.circular(RadhaRadii.radiusMd),
                ),
              ),
            ),

            // Top row: back · status pill · torch.
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
                      borderRadius: BorderRadius.circular(
                          RadhaRadii.radiusFull),
                    ),
                    child: Text(
                      _candidate != null
                          ? (_streak >= _kRequired
                              ? 'Confirmed!'
                              : 'Tap Confirm or wait ($_streak/$_kRequired)')
                          : 'Point at $hint',
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

            // Bottom area: detected date + Confirm button, or hint text.
            Positioned(
              bottom: RadhaSpacing.space32,
              left: RadhaSpacing.space24,
              right: RadhaSpacing.space24,
              child: _candidate != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Detected date banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: RadhaSpacing.space12,
                              horizontal: RadhaSpacing.space16),
                          decoration: BoxDecoration(
                            color:
                                RadhaColors.success.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(
                                RadhaRadii.radiusMd),
                          ),
                          child: Text(
                            _fmtDate(_candidate!),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: RadhaColors.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Confirm button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _confirmDate(_candidate!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: RadhaColors.primary,
                              foregroundColor: RadhaColors.onPrimary,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    RadhaRadii.radiusMd),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            icon: const Icon(Icons.check_circle_outline,
                                size: 20),
                            label: const Text('Confirm'),
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Align the $hint within the frame',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: RadhaColors.onPrimary
                                .withValues(alpha: 0.8),
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
    const w = 280.0;
    const h = 120.0;
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

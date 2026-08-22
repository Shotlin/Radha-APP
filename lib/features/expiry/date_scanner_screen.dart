import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

import '../../design/tokens.dart';
import '../../design/widgets/snackbar_host.dart';
import '../scan/camera_image_converter.dart';
import '../scan/data/product_submission_repository.dart';
import '../scan/domain/frame_consensus_aggregator.dart';
import '../scan/domain/label_field_extractor.dart';
import '../scan/domain/label_field_models.dart';
import 'data/date_photo_analysis_repository.dart';

/// Which date field this scanner is looking for.
enum DateScanMode { expiry, mfg }

/// Result popped by [DateScannerScreen]. Both a barcode/OCR photo and a
/// single cloud vision call already read the WHOLE label in one pass —
/// they were never only capable of seeing the field [DateScanMode]
/// happened to be targeting, so a confirmed/returned read of the OTHER
/// field is opportunistically included too. The caller (the expiry
/// wizard) uses this to fill both date fields from a single scan instead
/// of requiring a second scan-and-API-call for the other field (real
/// feedback, 2026-08-22: scanning expiry and then separately scanning
/// mfg was sending the same photo's worth of information twice).
typedef DateScanResult = ({DateTime? expiryDate, DateTime? mfgDate});

const Duration _kFrameInterval = Duration(milliseconds: 300);

/// Matches [ConsensusConfig.requiredAgreement]'s default — used only for
/// the "x/3 reads agree" status text, since [FrameConsensusAggregator]
/// doesn't expose its config back out.
const int _kRequired = 3;

/// `takePicture()` captures at the camera's native still-photo resolution —
/// on the I2217 this measured several thousand pixels on a side, regardless
/// of the `ResolutionPreset` used for the live preview/stream, which only
/// governs `startImageStream`. Sent unresized, a single photo cost gpt-4o-
/// mini ~14,400 input tokens (real measurement, 2026-08-22) — reading a
/// small embossed date doesn't need that much resolution. Bounding the
/// longest side to this keeps text legible while cutting tokens (and
/// upload time) drastically.
const int _kMaxUploadDimension = 1024;

/// Runs in a background isolate via [compute] — JPEG decode/resize/encode
/// is CPU-bound and would otherwise block the UI thread for a multi-
/// megapixel photo right as the "Reading with AI…" spinner needs to render.
Uint8List _resizeJpegForUpload(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;
  if (decoded.width <= _kMaxUploadDimension && decoded.height <= _kMaxUploadDimension) {
    return bytes;
  }
  final resized = decoded.width >= decoded.height
      ? img.copyResize(decoded, width: _kMaxUploadDimension)
      : img.copyResize(decoded, height: _kMaxUploadDimension);
  return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
}

/// Barcode-scanner-style full-screen screen that reads a single date field
/// (expiry or manufacturing) from a product label using ML Kit OCR.
///
/// Returns a [DateTime] via [Navigator.pop] when detected. The user can
/// confirm immediately via the Confirm button, or wait for [_kRequired]
/// consecutive frames to auto-confirm.
class DateScannerScreen extends ConsumerStatefulWidget {
  const DateScannerScreen({super.key, required this.mode});

  final DateScanMode mode;

  @override
  ConsumerState<DateScannerScreen> createState() => _DateScannerScreenState();
}

class _DateScannerScreenState extends ConsumerState<DateScannerScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  CameraDescription? _backCamera;
  TextRecognizer? _recognizer;
  bool _ready = false;
  bool _processingFrame = false;
  bool _torch = false;
  bool _accepted = false;
  bool _aiScanning = false;
  String? _error;
  DateTime? _lastProcessedAt;

  // Multi-frame consensus — the same aggregator live_label_scanner_screen.dart
  // uses, instead of a hand-rolled streak that resets to 1 on any single
  // differing frame (see barcode_candidate_tracker.dart for why that's a
  // real, reproducible bug: one stray OCR misread wiping out real progress).
  final _aggregator = FrameConsensusAggregator();

  LabelField get _targetField =>
      widget.mode == DateScanMode.expiry ? LabelField.expiryDate : LabelField.mfgDate;

  LabelField get _otherField =>
      widget.mode == DateScanMode.expiry ? LabelField.mfgDate : LabelField.expiryDate;

  /// The non-target field's date, but ONLY if the aggregator has
  /// independently confirmed it too (same trust bar as the target field)
  /// — a merely-leading, unconfirmed guess for the other field is not
  /// worth silently pre-filling.
  DateTime? get _confirmedOtherDate {
    final status = _aggregator.fieldStatus(_otherField);
    if (!status.confirmed) return null;
    return DateTime.tryParse(status.leadingValue ?? '');
  }

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
      _backCamera = back;
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
    // Set synchronously, before the async cleanup below even starts — a
    // build that races this teardown must never see a controller that's
    // non-null but mid-disposal. (This was previously missing entirely:
    // _ready stayed true after teardown, so a rebuild landing between
    // dispose() being called and it completing could still hit
    // CameraPreview(_controller!) with a controller that Android had
    // already torn down, throwing "buildPreview() was called on a
    // disposed CameraController" in a loop.)
    _ready = false;
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
      // A genuine suspension point — the user can navigate away (disposing
      // this State) while a frame is mid-recognition.
      if (!mounted || _accepted) return;
      final text = recognized.text.trim();
      if (text.isEmpty) return;

      final candidates = await compute(LabelFieldExtractor.extract, text);
      // compute() is itself a genuine suspension point — same disposal
      // risk as the ML Kit await above.
      if (!mounted || _accepted) return;
      if (candidates.isEmpty) return;

      _aggregator.addFrame(candidates);
      final status = _aggregator.fieldStatus(_targetField);
      if (status.confirmed && !_accepted) {
        final date = DateTime.tryParse(status.leadingValue ?? '');
        if (date != null) {
          _confirmDate(date, otherDate: _confirmedOtherDate);
          return;
        }
      }
      if (mounted) setState(() {});
    } catch (_) {
      // A failed frame just means one fewer vote this round — the next
      // frame gets another chance. Never surface per-frame OCR errors.
    }
  }

  /// [date] is this screen's target field ([DateScanMode]); [otherDate],
  /// when the caller has one, is the OPPOSITE field read from the same
  /// scan — see [DateScanResult].
  void _confirmDate(DateTime date, {DateTime? otherDate}) {
    if (_accepted) return;
    _accepted = true;
    HapticFeedback.mediumImpact();
    final result = widget.mode == DateScanMode.expiry
        ? (expiryDate: date, mfgDate: otherDate)
        : (expiryDate: otherDate, mfgDate: date);
    final c = _controller;
    if (c != null && c.value.isStreamingImages) {
      c.stopImageStream().then((_) {
        if (mounted) Navigator.of(context).pop(result);
      });
    } else {
      if (mounted) Navigator.of(context).pop(result);
    }
  }

  /// Escalates to a cloud vision model for a single still photo — the fix
  /// for labels on-device OCR can't read at all (debossed/embossed text on
  /// curved, translucent plastic; see date_photo_analysis_repository.dart
  /// for the real-device evidence). Deliberately manual/opt-in (a button
  /// tap), not automatic, so it never fires — and never costs anything —
  /// on the many labels local scanning already handles fine.
  Future<void> _scanWithAi() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        _aiScanning ||
        _accepted) {
      return;
    }
    setState(() => _aiScanning = true);
    HapticFeedback.selectionClick();

    var streamStopped = false;
    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
        streamStopped = true;
      }
      final photo = await controller.takePicture();
      final rawBytes = await File(photo.path).readAsBytes();
      final resizedBytes = await compute(_resizeJpegForUpload, rawBytes);
      final resizedFile = await File('${photo.path}_upload.jpg').writeAsBytes(resizedBytes);
      final uploaded = await ref
          .read(productSubmissionRepositoryProvider)
          .uploadPhotoEarly(resizedFile);
      final result = await ref
          .read(datePhotoAnalysisRepositoryProvider)
          .analyzePhoto(mediaId: uploaded.mediaId);

      // The vision call reads the WHOLE photo in one pass — it already
      // returned both dates when both were legible, not just this
      // screen's target field. Carry the other one along so the wizard
      // can fill both fields from this single scan/API call instead of
      // needing a second one.
      final targetDateStr =
          widget.mode == DateScanMode.expiry ? result.expiryDate : result.mfgDate;
      final otherDateStr =
          widget.mode == DateScanMode.expiry ? result.mfgDate : result.expiryDate;
      final date = targetDateStr != null ? DateTime.tryParse(targetDateStr) : null;
      final otherDate = otherDateStr != null ? DateTime.tryParse(otherDateStr) : null;

      if (!mounted) return;
      if (date != null) {
        _confirmDate(date, otherDate: otherDate);
        return;
      }
      SnackbarHost.error(
        "Couldn't read the date clearly — try better lighting or hold steadier.",
      );
    } catch (_) {
      if (mounted) {
        SnackbarHost.error('AI scan failed — check your connection and try again.');
      }
    } finally {
      if (mounted && !_accepted) {
        setState(() => _aiScanning = false);
        if (streamStopped && _controller != null && _backCamera != null) {
          try {
            await _controller!.startImageStream((img) => _onFrame(img, _backCamera!));
          } catch (_) {}
        }
      }
    }
  }

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

    final status = _aggregator.fieldStatus(_targetField);
    final leadingDate = status.leadingValue != null
        ? DateTime.tryParse(status.leadingValue!)
        : null;

    return Scaffold(
      backgroundColor: RadhaColors.ink,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Camera preview — only ever built while _ready is true, which
            // _teardown() clears synchronously before any async cleanup
            // starts, so this can never race a disposed controller.
            if (_ready && _controller != null && _controller!.value.isInitialized)
              CameraPreview(_controller!),

            // Dimmed scrim with transparent centre rectangle.
            IgnorePointer(child: CustomPaint(painter: _ScrimPainter())),

            // Orange scan-frame border.
            Center(
              child: Container(
                width: 280,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: leadingDate != null
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
                      leadingDate != null
                          ? (status.confirmed
                              ? 'Confirmed!'
                              : 'Tap Confirm or wait '
                                  '(${status.agreementCount}/$_kRequired)')
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

            // Bottom area: detected date + Confirm button, or hint text —
            // plus an always-available "Scan with AI" escape hatch below.
            Positioned(
              bottom: RadhaSpacing.space32,
              left: RadhaSpacing.space24,
              right: RadhaSpacing.space24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leadingDate != null) ...[
                    // Detected date banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: RadhaSpacing.space12,
                          horizontal: RadhaSpacing.space16),
                      decoration: BoxDecoration(
                        color: RadhaColors.success.withValues(alpha: 0.9),
                        borderRadius:
                            BorderRadius.circular(RadhaRadii.radiusMd),
                      ),
                      child: Text(
                        _fmtDate(leadingDate),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: RadhaColors.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Confirm button — lets the user accept the current
                    // best reading immediately instead of waiting for
                    // auto-confirm, same escape hatch as before.
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _confirmDate(leadingDate, otherDate: _confirmedOtherDate),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: RadhaColors.primary,
                          foregroundColor: RadhaColors.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(RadhaRadii.radiusMd),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        icon: const Icon(Icons.check_circle_outline, size: 20),
                        label: const Text('Confirm'),
                      ),
                    ),
                  ] else
                    Text(
                      'Align the $hint within the frame',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: RadhaColors.onPrimary
                                .withValues(alpha: 0.8),
                          ),
                    ),
                  const SizedBox(height: 12),
                  // Escalation for labels local OCR can't read at all (the
                  // real case: dates debossed into curved, translucent
                  // plastic) — a single cloud vision call on a still photo,
                  // opt-in so it's never triggered — or billed — silently.
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _aiScanning ? null : _scanWithAi,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: RadhaColors.onPrimary,
                        side: BorderSide(
                          color: RadhaColors.onPrimary.withValues(alpha: 0.6),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(RadhaRadii.radiusMd),
                        ),
                      ),
                      icon: _aiScanning
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: RadhaColors.onPrimary,
                              ),
                            )
                          : const Icon(Icons.auto_awesome_rounded, size: 18),
                      label: Text(
                        _aiScanning ? 'Reading with AI…' : "Can't read it? Scan with AI",
                      ),
                    ),
                  ),
                ],
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

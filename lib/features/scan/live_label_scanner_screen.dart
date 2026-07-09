// Live label scanner — replaces the old "hold steady, auto-capture one
// still" flow (label_camera_screen.dart) with a continuously-scanning
// camera feed: every ~600ms the current frame is OCR'd on-device and fed
// into a multi-frame consensus aggregator (frame_consensus_aggregator.dart)
// so a field is only ever shown as reliable once several independent
// frames agree — never on the strength of one lucky (or unlucky) frame.
//
// Top half: live camera preview. Bottom half: one card per field the
// extractor understands, each carrying a confidence chip (Confirmed /
// Needs review / Scanning…). Accept & Save is only enabled once the
// mandatory field (expiry date) is confirmed, or the user has switched to
// manual entry — nothing is ever written back silently.
//
// Re-exports LiveScanResult so callers only need one import to both push
// this screen and type its return value.
export 'domain/label_field_models.dart' show LiveScanResult;

import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../design/tokens.dart';
import '../../design/widgets/primary_button.dart';
import '../../design/widgets/radha_status_chip.dart';
import 'camera_image_converter.dart';
import 'domain/frame_consensus_aggregator.dart';
import 'domain/label_field_extractor.dart';
import 'domain/label_field_models.dart';

/// Minimum gap between two processed frames. ML Kit recognition on every
/// single camera frame (~30/s) would burn battery for no accuracy gain —
/// a label's text doesn't change in 1/30s, and the consensus aggregator
/// only needs a handful of independent reads over ~2-3 seconds to confirm.
const Duration _kFrameInterval = Duration(milliseconds: 600);

class LiveLabelScannerScreen extends StatefulWidget {
  const LiveLabelScannerScreen({super.key});

  @override
  State<LiveLabelScannerScreen> createState() =>
      _LiveLabelScannerScreenState();
}

class _LiveLabelScannerScreenState extends State<LiveLabelScannerScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  TextRecognizer? _recognizer;
  bool _ready = false;
  bool _processingFrame = false;
  bool _torch = false;
  String? _error;
  DateTime? _lastProcessedAt;

  final _aggregator = FrameConsensusAggregator();
  String _lastTranscript = '';

  /// Field-card key -> most recent correction, cleared 2s after it lands.
  /// Key scheme mirrors the aggregator's internal window keys: LabelField
  /// name for scalar fields, `'nutrition.$nutrientKey'` for nutrients —
  /// see FrameConsensusAggregator._push/_rankedFor.
  final Map<String, FieldCorrection> _recentCorrections = {};

  String _correctionKey(FieldCorrection c) => c.nutrientKey != null
      ? 'nutrition.${c.nutrientKey}'
      : c.field.name;

  bool _manualEditMode = false;
  DateTime? _manualExpiry;
  DateTime? _manualMfg;
  final _manualBatchController = TextEditingController();
  final _manualSkuController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    _setup();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _teardownController();
    } else if (state == AppLifecycleState.resumed) {
      _setup();
    }
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
        // `medium` + yuv420 failed outright on a real vivo I2217 (Android
        // 15): the platform's ImageAnalysis pipeline threw "Getting Image
        // failed / IllegalArgumentException" on every frame, before any
        // frame ever reached Dart — this Qualcomm-ISP camera stack
        // (qdgralloc in logcat) has a known plane-stride incompatibility
        // with CameraX's YUV_420_888 acquisition path on some devices.
        // `nv21` (below) forces the plugin's legacy Camera2-compatible
        // conversion path instead and fixed it outright — confirmed live
        // that resolution wasn't actually the cause, so this stays at
        // `medium` rather than `low`: this preset also governs the LIVE
        // PREVIEW's resolution (the plugin doesn't expose a separate
        // preview vs. analysis resolution), and `low` made the on-screen
        // camera view visibly blurry for no remaining benefit.
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
      await controller.startImageStream((image) => _onFrame(image, back));
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

  void _onFrame(CameraImage image, CameraDescription camera) {
    if (_processingFrame || !_ready || _manualEditMode) return;
    final now = DateTime.now();
    if (_lastProcessedAt != null &&
        now.difference(_lastProcessedAt!) < _kFrameInterval) {
      return;
    }
    _lastProcessedAt = now;
    _processingFrame = true;
    _recognizeFrame(image, camera).whenComplete(() => _processingFrame = false);
  }

  Future<void> _recognizeFrame(
    CameraImage image,
    CameraDescription camera,
  ) async {
    final recognizer = _recognizer;
    if (recognizer == null) return;
    try {
      final inputImage = cameraImageToInputImage(image, camera);
      if (inputImage == null) return;
      final recognized = await recognizer.processImage(inputImage);
      // The await above is a genuine suspension point — the user can
      // navigate away (disposing this State) while a frame is
      // mid-recognition. SemanticsService.sendAnnouncement below needs a
      // still-mounted BuildContext; bail out immediately if unmounted.
      if (!mounted) return;
      final text = recognized.text;
      if (text.trim().isEmpty) return;
      final candidates = LabelFieldExtractor.extract(text);
      if (candidates.isEmpty) return;
      _aggregator.addFrame(candidates);
      final corrections = _aggregator.takeCorrections();
      for (final correction in corrections) {
        final key = _correctionKey(correction);
        _recentCorrections[key] = correction;
        if (mounted) {
          SemanticsService.sendAnnouncement(
            View.of(context),
            '${_fieldLabel(correction.field, correction.nutrientKey)} '
            'corrected to ${correction.newValue}',
            TextDirection.ltr,
          );
        }
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          if (identical(_recentCorrections[key], correction)) {
            setState(() => _recentCorrections.remove(key));
          }
        });
      }
      _lastTranscript = text;
      if (mounted) setState(() {});
    } catch (_) {
      // A failed frame just means one fewer vote this round — the next
      // frame ~600ms later gets another chance. Never surface per-frame
      // OCR errors to the user; only sustained failure across many frames
      // would ever matter, and that already reads as "still scanning".
    }
  }

  Future<void> _toggleTorch() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    HapticFeedback.selectionClick();
    _torch = !_torch;
    try {
      await controller.setFlashMode(_torch ? FlashMode.torch : FlashMode.off);
    } catch (_) {
      _torch = !_torch;
    }
    if (mounted) setState(() {});
  }

  void _rescan() {
    HapticFeedback.mediumImpact();
    setState(() {
      _aggregator.reset();
      _lastTranscript = '';
      _manualEditMode = false;
      _recentCorrections.clear();
    });
  }

  void _enterManualEdit() {
    HapticFeedback.selectionClick();
    final expiry = _aggregator.fieldStatus(LabelField.expiryDate);
    final mfg = _aggregator.fieldStatus(LabelField.mfgDate);
    final batch = _aggregator.fieldStatus(LabelField.batchNumber);
    final sku = _aggregator.fieldStatus(LabelField.skuOrProductId);
    setState(() {
      _manualEditMode = true;
      _manualExpiry = expiry.leadingValue != null
          ? DateTime.tryParse(expiry.leadingValue!)
          : null;
      _manualMfg =
          mfg.leadingValue != null ? DateTime.tryParse(mfg.leadingValue!) : null;
      _manualBatchController.text = batch.leadingValue ?? '';
      _manualSkuController.text = sku.leadingValue ?? '';
    });
  }

  bool get _canAccept {
    if (_manualEditMode) return _manualExpiry != null;
    return _aggregator.fieldStatus(LabelField.expiryDate).confirmed;
  }

  void _accept() {
    if (!_canAccept) return;
    HapticFeedback.mediumImpact();

    if (_manualEditMode) {
      Navigator.of(context).pop(
        LiveScanResult(
          transcript: _lastTranscript,
          expiryDate: _manualExpiry,
          mfgDate: _manualMfg,
          batchNumber: _manualBatchController.text.trim().isEmpty
              ? null
              : _manualBatchController.text.trim(),
          skuOrProductId: _manualSkuController.text.trim().isEmpty
              ? null
              : _manualSkuController.text.trim(),
        ),
      );
      return;
    }

    final expiry = _aggregator.fieldStatus(LabelField.expiryDate);
    final mfg = _aggregator.fieldStatus(LabelField.mfgDate);
    final batch = _aggregator.fieldStatus(LabelField.batchNumber);
    final sku = _aggregator.fieldStatus(LabelField.skuOrProductId);
    final nutrition = <String, String>{};
    for (final entry in _aggregator.nutritionStatus().entries) {
      if (entry.value.confirmed && entry.value.leadingValue != null) {
        nutrition[entry.key] = entry.value.leadingValue!;
      }
    }

    Navigator.of(context).pop(
      LiveScanResult(
        transcript: _lastTranscript,
        expiryDate: DateTime.tryParse(expiry.leadingValue ?? ''),
        mfgDate: mfg.confirmed ? DateTime.tryParse(mfg.leadingValue ?? '') : null,
        batchNumber: batch.confirmed ? batch.leadingValue : null,
        skuOrProductId: sku.confirmed ? sku.leadingValue : null,
        nutrition: nutrition,
        fieldConfidence: {
          LabelField.expiryDate: expiry.combinedConfidence,
          LabelField.mfgDate: mfg.combinedConfidence,
          LabelField.batchNumber: batch.combinedConfidence,
          LabelField.skuOrProductId: sku.combinedConfidence,
        },
      ),
    );
  }

  Future<void> _teardownController() async {
    final controller = _controller;
    _controller = null;
    _ready = false;
    if (controller != null) {
      try {
        if (controller.value.isStreamingImages) {
          await controller.stopImageStream();
        }
      } catch (_) {
        /* ignore */
      }
      await controller.dispose();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _teardownController();
    _recognizer?.close();
    _manualBatchController.dispose();
    _manualSkuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(flex: 5, child: _buildCameraArea(context)),
            Expanded(flex: 4, child: _buildDataPanel(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraArea(BuildContext context) {
    if (_error != null) {
      return Container(
        color: RadhaColors.ink,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(RadhaSpacing.space24),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: RadhaColors.onPrimary),
            ),
          ),
        ),
      );
    }
    if (!_ready || _controller == null) {
      return const ColoredBox(
        color: RadhaColors.ink,
        child: Center(
          child: CircularProgressIndicator(color: RadhaColors.primary),
        ),
      );
    }
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 300,
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(color: RadhaColors.primary, width: 3),
                  borderRadius: BorderRadius.circular(RadhaRadii.radiusLg),
                ),
              ),
            ),
          ),
          Positioned(
            top: RadhaSpacing.space8,
            left: RadhaSpacing.space8,
            right: RadhaSpacing.space8,
            child: Row(
              children: [
                _RoundButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                const Spacer(),
                if (!_manualEditMode)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: RadhaSpacing.space12,
                      vertical: RadhaSpacing.space4,
                    ),
                    decoration: BoxDecoration(
                      color: RadhaColors.ink.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
                    ),
                    child: Text(
                      'Scanning… ${_aggregator.framesProcessed} frames',
                      style: const TextStyle(
                        color: RadhaColors.onPrimary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                const Spacer(),
                _RoundButton(
                  icon: _torch ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  active: _torch,
                  onTap: _toggleTorch,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataPanel(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(RadhaRadii.radiusXl),
          topRight: Radius.circular(RadhaRadii.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              RadhaSpacing.space20,
              RadhaSpacing.space16,
              RadhaSpacing.space20,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _manualEditMode ? 'Enter details manually' : 'Detected data',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (!_manualEditMode)
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Rescan',
                    onPressed: _rescan,
                  ),
              ],
            ),
          ),
          Expanded(
            child: _manualEditMode
                ? _buildManualEditForm(context)
                : _buildFieldCards(context),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              RadhaSpacing.space20,
              0,
              RadhaSpacing.space20,
              RadhaSpacing.space16,
            ),
            child: _buildActionButtons(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldCards(BuildContext context) {
    final expiry = _aggregator.fieldStatus(LabelField.expiryDate);
    final mfg = _aggregator.fieldStatus(LabelField.mfgDate);
    final batch = _aggregator.fieldStatus(LabelField.batchNumber);
    final sku = _aggregator.fieldStatus(LabelField.skuOrProductId);
    final nutrition = _aggregator.nutritionStatus();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        RadhaSpacing.space20,
        RadhaSpacing.space12,
        RadhaSpacing.space20,
        RadhaSpacing.space8,
      ),
      children: [
        FieldCard(
          label: 'Expiry Date',
          consensus: expiry,
          formatAsDate: true,
          correction: _recentCorrections[LabelField.expiryDate.name],
        ),
        const SizedBox(height: RadhaSpacing.space8),
        FieldCard(
          label: 'Manufacturing Date',
          consensus: mfg,
          formatAsDate: true,
          correction: _recentCorrections[LabelField.mfgDate.name],
        ),
        if (batch.hasAnyReading) ...[
          const SizedBox(height: RadhaSpacing.space8),
          FieldCard(
            label: 'Batch / Lot Number',
            consensus: batch,
            correction: _recentCorrections[LabelField.batchNumber.name],
          ),
        ],
        if (sku.hasAnyReading) ...[
          const SizedBox(height: RadhaSpacing.space8),
          FieldCard(
            label: 'SKU / Product ID',
            consensus: sku,
            correction: _recentCorrections[LabelField.skuOrProductId.name],
          ),
        ],
        for (final entry in nutrition.entries) ...[
          const SizedBox(height: RadhaSpacing.space8),
          FieldCard(
            label: _nutrientLabel(entry.key),
            consensus: entry.value,
            correction: _recentCorrections['nutrition.${entry.key}'],
          ),
        ],
      ],
    );
  }

  static String _nutrientLabel(String key) {
    switch (key) {
      case 'energy':
        return 'Calories / Energy';
      default:
        return key[0].toUpperCase() + key.substring(1);
    }
  }

  static String _fieldLabel(LabelField field, String? nutrientKey) {
    if (nutrientKey != null) return _nutrientLabel(nutrientKey);
    switch (field) {
      case LabelField.expiryDate:
        return 'Expiry date';
      case LabelField.mfgDate:
        return 'Manufacturing date';
      case LabelField.batchNumber:
        return 'Batch / lot number';
      case LabelField.skuOrProductId:
        return 'SKU / product ID';
      case LabelField.nutrition:
        return 'Nutrition value';
    }
  }

  Widget _buildManualEditForm(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        RadhaSpacing.space20,
        RadhaSpacing.space12,
        RadhaSpacing.space20,
        RadhaSpacing.space8,
      ),
      children: [
        Text('Expiry date *', style: theme.textTheme.labelLarge),
        const SizedBox(height: RadhaSpacing.space4),
        _ManualDateTile(
          value: _manualExpiry,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _manualExpiry ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) setState(() => _manualExpiry = picked);
          },
        ),
        const SizedBox(height: RadhaSpacing.space16),
        Text('Manufacturing date', style: theme.textTheme.labelLarge),
        const SizedBox(height: RadhaSpacing.space4),
        _ManualDateTile(
          value: _manualMfg,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _manualMfg ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) setState(() => _manualMfg = picked);
          },
        ),
        const SizedBox(height: RadhaSpacing.space16),
        Text('Batch / lot number', style: theme.textTheme.labelLarge),
        const SizedBox(height: RadhaSpacing.space4),
        TextField(controller: _manualBatchController),
        const SizedBox(height: RadhaSpacing.space16),
        Text('SKU / product ID', style: theme.textTheme.labelLarge),
        const SizedBox(height: RadhaSpacing.space4),
        TextField(controller: _manualSkuController),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!_canAccept && !_manualEditMode)
          Padding(
            padding: const EdgeInsets.only(bottom: RadhaSpacing.space8),
            child: Text(
              'Keep the label steady in frame — waiting for enough matching '
              'reads before saving.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: RadhaSpacing.space8),
            if (!_manualEditMode)
              Expanded(
                child: OutlinedButton(
                  onPressed: _enterManualEdit,
                  child: const Text('Edit Manually'),
                ),
              )
            else
              Expanded(
                child: OutlinedButton(
                  onPressed: _rescan,
                  child: const Text('Back to Scan'),
                ),
              ),
            const SizedBox(width: RadhaSpacing.space8),
            Expanded(
              flex: 2,
              child: PrimaryButton(
                label: 'Accept & Save',
                icon: Icons.check_rounded,
                expand: true,
                onPressed: _canAccept ? _accept : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class FieldCard extends StatelessWidget {
  const FieldCard({
    super.key,
    required this.label,
    required this.consensus,
    this.formatAsDate = false,
    this.correction,
  });

  final String label;
  final FieldConsensus consensus;
  final bool formatAsDate;

  /// When non-null, this card just got outvoted/demoted to a new value —
  /// render the amber "Corrected" state instead of the normal chip.
  final FieldCorrection? correction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCorrected = correction != null;
    final (chipLabel, tone) = isCorrected
        ? ('Corrected', RadhaStatusTone.warning)
        : _statusFor(consensus);
    final displayValue = _displayValue();

    return Container(
      padding: const EdgeInsets.all(RadhaSpacing.space12),
      decoration: BoxDecoration(
        color: isCorrected
            ? RadhaColors.warning.withValues(alpha: 0.08)
            : theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        border: Border.all(
          color: isCorrected ? RadhaColors.warning : theme.colorScheme.outline,
          width: isCorrected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) {
                    final incoming =
                        (child.key as ValueKey<String>).value == displayValue;
                    final offset = Tween<Offset>(
                      begin: Offset(0, incoming ? 0.4 : 0),
                      end: Offset(0, incoming ? 0 : -0.4),
                    ).animate(animation);
                    final fade = FadeTransition(opacity: animation, child: child);
                    return SlideTransition(
                      position: offset,
                      child: incoming
                          ? fade
                          : DefaultTextStyle.merge(
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                              ),
                              child: fade,
                            ),
                    );
                  },
                  child: Text(
                    displayValue,
                    key: ValueKey(displayValue),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isCorrected)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'corrected: ${correction!.reason}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: RadhaColors.warning,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else if (consensus.derivedFrom != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Derived: ${consensus.derivedFrom}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: RadhaSpacing.space8),
          RadhaStatusChip(label: chipLabel, tone: tone),
        ],
      ),
    );
  }

  String _displayValue() {
    if (!consensus.hasAnyReading) return 'Not detected yet';
    if (formatAsDate) {
      final date = DateTime.tryParse(consensus.leadingValue!);
      if (date != null) {
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
        ];
        return '${date.day} ${months[date.month - 1]} ${date.year}';
      }
    }
    return consensus.leadingValue!;
  }

  (String, RadhaStatusTone) _statusFor(FieldConsensus c) {
    if (!c.hasAnyReading) return ('Scanning…', RadhaStatusTone.neutral);
    if (c.confirmed) return ('Confirmed', RadhaStatusTone.success);
    return ('${c.agreementCount}/${c.windowSize} reads', RadhaStatusTone.warning);
  }
}

class _ManualDateTile extends StatelessWidget {
  const _ManualDateTile({required this.value, required this.onTap});

  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: RadhaSpacing.space16,
          vertical: RadhaSpacing.space12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 18),
            const SizedBox(width: RadhaSpacing.space8),
            Text(value == null
                ? 'Not set'
                : '${value!.day}/${value!.month}/${value!.year}'),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
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
      color: active ? RadhaColors.primary : RadhaColors.ink.withValues(alpha: 0.5),
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

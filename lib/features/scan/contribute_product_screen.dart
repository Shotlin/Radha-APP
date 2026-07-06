// Contribute-product screen — the "own infrastructure" fallback when a
// scanned EAN isn't in any third-party product database (Open Food Facts,
// Open Beauty Facts, Open Products Facts, UPCitemdb) *or* RADHA's own
// catalog yet.
//
// Reuses the exact domain layer the live expiry scanner uses
// (LabelFieldExtractor + FrameConsensusAggregator — the same multi-frame
// consensus mechanics, so a nutrition value is only ever shown as reliable
// once several independent frames agree) plus its FieldCard widget for a
// consistent look. What's different from LiveLabelScannerScreen:
//   - A required, manually-typed product name (brand/product naming is too
//     irregular for reliable OCR-guessing, unlike dates/nutrition which
//     have structured patterns).
//   - A still photo is captured at submit time (the expiry scanner only
//     ever processes CameraImage frames for OCR and discards them).
//   - The result isn't handed back to a form — it's uploaded + submitted
//     to POST /products/learn for moderator review, with a clear
//     "submitted for review" confirmation instead of an instant save.
import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../design/tokens.dart';
import '../../design/widgets/primary_button.dart';
import 'camera_image_converter.dart';
import 'data/product_submission_repository.dart';
import 'domain/frame_consensus_aggregator.dart';
import 'domain/label_field_extractor.dart';
import 'live_label_scanner_screen.dart' show FieldCard;
import '../../core/network/dto/product_submission_dto.dart';

const Duration _kFrameInterval = Duration(milliseconds: 600);

class ContributeProductScreen extends ConsumerStatefulWidget {
  const ContributeProductScreen({super.key, required this.ean});

  final String ean;

  @override
  ConsumerState<ContributeProductScreen> createState() =>
      _ContributeProductScreenState();
}

enum _Stage { scanning, submitting, submitted, failed }

class _ContributeProductScreenState
    extends ConsumerState<ContributeProductScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  TextRecognizer? _recognizer;
  bool _ready = false;
  bool _processingFrame = false;
  String? _cameraError;
  DateTime? _lastProcessedAt;

  final _aggregator = FrameConsensusAggregator();
  final _nameController = TextEditingController();
  final _ingredientsController = TextEditingController();

  /// Once the user types into the ingredients field directly, auto-OCR
  /// updates stop overwriting it — their edit wins.
  bool _ingredientsEditedByUser = false;

  _Stage _stage = _Stage.scanning;
  String? _submitError;

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
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _teardownController();
    } else if (state == AppLifecycleState.resumed && _stage == _Stage.scanning) {
      _setup();
    }
  }

  Future<void> _setup() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _cameraError = 'No camera found on this device.');
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
        imageFormatGroup: ImageFormatGroup.yuv420,
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
        _cameraError = null;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _cameraError = 'Camera unavailable. Go back and try again.');
      }
    }
  }

  void _onFrame(CameraImage image, CameraDescription camera) {
    if (_processingFrame || !_ready || _stage != _Stage.scanning) return;
    final now = DateTime.now();
    if (_lastProcessedAt != null && now.difference(_lastProcessedAt!) < _kFrameInterval) {
      return;
    }
    _lastProcessedAt = now;
    _processingFrame = true;
    _recognizeFrame(image, camera).whenComplete(() => _processingFrame = false);
  }

  Future<void> _recognizeFrame(CameraImage image, CameraDescription camera) async {
    final recognizer = _recognizer;
    if (recognizer == null) return;
    try {
      final inputImage = cameraImageToInputImage(image, camera);
      if (inputImage == null) return;
      final recognized = await recognizer.processImage(inputImage);
      final text = recognized.text;
      if (text.trim().isEmpty) return;
      final candidates = LabelFieldExtractor.extract(text);
      if (!candidates.isEmpty) _aggregator.addFrame(candidates);

      // Ingredients text doesn't fit the numeric multi-frame consensus
      // model (it's free text, not a value repeated across frames), so
      // this just keeps the longest candidate seen — OCR usually
      // truncates the tail, so a longer read is a strictly better one.
      final ingredients = _extractIngredients(text);
      if (ingredients != null &&
          !_ingredientsEditedByUser &&
          ingredients.length > _ingredientsController.text.length) {
        _ingredientsController.text = ingredients;
      }

      if (candidates.isEmpty && ingredients == null) return;
      if (mounted) setState(() {});
    } catch (_) {
      // Same policy as the expiry scanner: a failed frame is just one
      // fewer vote this round, never a surfaced error.
    }
  }

  // Boundary keywords that mark the end of an INGREDIENTS run-on section —
  // whichever comes first cuts the capture so it doesn't swallow the
  // nutrition panel or MFG/EXP/batch block that typically follows it.
  static final RegExp _ingredientsHeader = RegExp(
    r'INGREDIENTS?(?:\s*LIST)?\s*[:.\-]?\s*',
    caseSensitive: false,
  );
  static final RegExp _ingredientsBoundary = RegExp(
    r'\b(NUTRITION(?:AL)?|ENERGY|ALLERGEN|STORAGE|STORE\s*IN|MFD|MFG|EXP|'
    r'EXPIRY|BEST\s*BEFORE|USE\s*BY|BATCH|NET\s*(WT|WEIGHT|QTY)|BARCODE|'
    r'FSSAI|CUSTOMER\s*CARE)\b',
    caseSensitive: false,
  );

  /// Best-effort extraction of the label's INGREDIENTS run-on text from
  /// one frame's OCR transcript, or null if no INGREDIENTS header was
  /// found at all. Deliberately simple/free-text (unlike the structured
  /// date/nutrition parsers) — ingredient lists have no fixed format.
  static String? _extractIngredients(String text) {
    final headerMatch = _ingredientsHeader.firstMatch(text);
    if (headerMatch == null) return null;
    final afterHeader = text.substring(headerMatch.end);
    final boundaryMatch = _ingredientsBoundary.firstMatch(afterHeader);
    final raw = boundaryMatch != null
        ? afterHeader.substring(0, boundaryMatch.start)
        : afterHeader;
    final cleaned = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.length < 8) return null;
    return cleaned.length > 800 ? cleaned.substring(0, 800).trim() : cleaned;
  }

  bool get _canSubmit =>
      _stage == _Stage.scanning && _nameController.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    HapticFeedback.mediumImpact();
    final controller = _controller;
    setState(() => _stage = _Stage.submitting);

    File? photo;
    try {
      if (controller != null && controller.value.isInitialized) {
        if (controller.value.isStreamingImages) {
          await controller.stopImageStream();
        }
        final shot = await controller.takePicture();
        photo = File(shot.path);
      }
    } catch (_) {
      // Missing photo isn't fatal — the moderator can still review a
      // text-only submission. Continue without one.
    }

    final nutrition = _buildNutritionPayload();

    try {
      await ref.read(productSubmissionRepositoryProvider).submit(
            ean: widget.ean,
            name: _nameController.text.trim(),
            ingredients: _ingredientsController.text,
            nutrition: nutrition,
            photo: photo,
          );
      if (mounted) setState(() => _stage = _Stage.submitted);
    } catch (_) {
      if (mounted) {
        setState(() {
          _stage = _Stage.failed;
          _submitError = 'Couldn\'t submit — check your connection and try again.';
        });
      }
    }
  }

  NutritionPanelPayload? _buildNutritionPayload() {
    final n = _aggregator.nutritionStatus();
    double? confirmedDouble(String key) {
      final c = n[key];
      if (c == null || !c.confirmed || c.leadingValue == null) return null;
      return double.tryParse(c.leadingValue!);
    }

    final payload = NutritionPanelPayload(
      calories: confirmedDouble('energy'),
      protein: confirmedDouble('protein'),
      carbohydrates: confirmedDouble('carbohydrate'),
      sugars: confirmedDouble('sugar'),
      fat: confirmedDouble('fat'),
      sodium: confirmedDouble('sodium'),
      // Potassium has no direct product_nutrition column — omitted here;
      // the raw OCR transcript already isn't retained by this flow since
      // (unlike the expiry scanner) there's no downstream field that
      // reads it back.
    );
    return payload.isEmpty ? null : payload;
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
    _nameController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: const Text('Add this product')),
      body: SafeArea(
        child: switch (_stage) {
          _Stage.scanning => _buildScanningBody(context),
          _Stage.submitting => const Center(child: CircularProgressIndicator()),
          _Stage.submitted => _buildSubmittedBody(context),
          _Stage.failed => _buildFailedBody(context),
        },
      ),
    );
  }

  Widget _buildScanningBody(BuildContext context) {
    return Column(
      children: [
        Expanded(flex: 4, child: _buildCameraArea(context)),
        Expanded(flex: 5, child: _buildFormArea(context)),
      ],
    );
  }

  Widget _buildCameraArea(BuildContext context) {
    if (_cameraError != null) {
      return ColoredBox(
        color: RadhaColors.ink,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(RadhaSpacing.space24),
            child: Text(
              _cameraError!,
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
        child: Center(child: CircularProgressIndicator(color: RadhaColors.primary)),
      );
    }
    return ClipRect(child: CameraPreview(_controller!));
  }

  Widget _buildFormArea(BuildContext context) {
    final theme = Theme.of(context);
    final nutrition = _aggregator.nutritionStatus();
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                RadhaSpacing.space20,
                RadhaSpacing.space16,
                RadhaSpacing.space20,
                RadhaSpacing.space8,
              ),
              children: [
                Text('EAN ${widget.ean}', style: theme.textTheme.labelMedium),
                const SizedBox(height: RadhaSpacing.space12),
                Text('Product name *', style: theme.textTheme.labelLarge),
                const SizedBox(height: RadhaSpacing.space4),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'e.g. Amul Butter 500g'),
                  onChanged: (_) => setState(() {}),
                ),
                if (nutrition.values.any((c) => c.hasAnyReading)) ...[
                  const SizedBox(height: RadhaSpacing.space16),
                  Text('Nutrition panel (auto-detected)', style: theme.textTheme.labelLarge),
                  const SizedBox(height: RadhaSpacing.space8),
                  for (final entry in nutrition.entries)
                    if (entry.value.hasAnyReading)
                      Padding(
                        padding: const EdgeInsets.only(bottom: RadhaSpacing.space8),
                        child: FieldCard(label: _nutrientLabel(entry.key), consensus: entry.value),
                      ),
                ],
                const SizedBox(height: RadhaSpacing.space16),
                Text('Ingredients', style: theme.textTheme.labelLarge),
                const SizedBox(height: RadhaSpacing.space4),
                TextField(
                  controller: _ingredientsController,
                  maxLines: 4,
                  minLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Point the camera at the INGREDIENTS list to '
                        'auto-fill, or type it in',
                  ),
                  onChanged: (_) => setState(() => _ingredientsEditedByUser = true),
                ),
                const SizedBox(height: RadhaSpacing.space8),
                Text(
                  'This is what health ratings are judged on — sodium, sugar, '
                  'oils, additives. Check it matches the pack before submitting.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              RadhaSpacing.space20,
              0,
              RadhaSpacing.space20,
              RadhaSpacing.space16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: RadhaSpacing.space8),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    label: 'Capture & Submit',
                    icon: Icons.check_rounded,
                    expand: true,
                    onPressed: _canSubmit ? _submit : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildSubmittedBody(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RadhaSpacing.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: RadhaColors.primary, size: 56),
            const SizedBox(height: RadhaSpacing.space16),
            Text(
              'Submitted for review',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: RadhaSpacing.space8),
            Text(
              'Thanks — a moderator will check "${_nameController.text.trim()}" '
              'before it goes live for everyone.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: RadhaSpacing.space24),
            PrimaryButton(
              label: 'Done',
              expand: true,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailedBody(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RadhaSpacing.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: theme.colorScheme.error, size: 56),
            const SizedBox(height: RadhaSpacing.space16),
            Text(_submitError ?? 'Something went wrong.', textAlign: TextAlign.center),
            const SizedBox(height: RadhaSpacing.space24),
            PrimaryButton(
              label: 'Try again',
              expand: true,
              onPressed: () => setState(() => _stage = _Stage.scanning),
            ),
          ],
        ),
      ),
    );
  }
}

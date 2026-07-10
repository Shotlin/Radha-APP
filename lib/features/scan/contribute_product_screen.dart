// Contribute-product screen — the "own infrastructure" fallback when a
// scanned EAN isn't in any third-party product database (Open Food Facts,
// Open Beauty Facts, Open Products Facts, UPCitemdb) *or* RADHA's own
// catalog yet.
//
// A 4-step guided capture wizard (photo -> name -> ingredients/nutrition ->
// review & submit), all sharing ONE continuous camera + OCR session for the
// whole screen lifetime — switching steps only changes what's rendered
// below the live preview, it never tears down or restarts the camera
// (camera lifecycle churn is a known source of bugs elsewhere in this
// app — see live_label_scanner_screen.dart's WidgetsBindingObserver fix).
//
// Reuses the exact domain layer the live expiry scanner uses
// (LabelFieldExtractor + FrameConsensusAggregator — the same multi-frame
// consensus mechanics, so a nutrition value is only ever shown as reliable
// once several independent frames agree) plus its FieldCard widget, PLUS a
// new product_name_extractor.dart heuristic (tallest non-boilerplate OCR
// line = likely the brand/product name) with its own streak-based
// consensus, so the name field auto-fills instead of requiring the user to
// type the whole thing by hand — while always staying manually editable.
//
// The result isn't handed back to a form — it's uploaded + submitted to
// POST /products/learn for moderator review, with a clear "submitted for
// review" confirmation instead of an instant save.
import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../design/tokens.dart';
import '../../design/widgets/primary_button.dart';
import '../../design/widgets/radha_status_chip.dart';
import 'camera_image_converter.dart';
import 'data/label_photo_analysis_repository.dart';
import 'data/product_submission_repository.dart';
import 'domain/frame_consensus_aggregator.dart';
import 'domain/frame_extraction_worker.dart';
import 'domain/label_field_extractor.dart';
import 'domain/label_field_models.dart';
import 'domain/label_source_merger.dart';
import 'domain/product_name_extractor.dart';
import '../../core/network/dto/ai_dto.dart';
import '../../core/network/dto/product_submission_dto.dart';

const Duration _kFrameInterval = Duration(milliseconds: 300);

/// Consecutive identical/steady reads required before auto-filling a value
/// from OCR — same "repeated checking before trusting" discipline used for
/// barcode scanning (scan_screen.dart) and date consensus
/// (frame_consensus_aggregator.dart). One shaky frame never writes a field.
const int _kRequiredAgreement = 3;

enum _Step { photo, name, details, review }

enum _Stage { editing, submitting, submitted, failed }

class ContributeProductScreen extends ConsumerStatefulWidget {
  const ContributeProductScreen({super.key, required this.ean});

  final String ean;

  @override
  ConsumerState<ContributeProductScreen> createState() =>
      _ContributeProductScreenState();
}

class _ContributeProductScreenState extends ConsumerState<ContributeProductScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  CameraDescription? _camera;
  TextRecognizer? _recognizer;
  bool _ready = false;
  bool _processingFrame = false;
  bool _capturing = false;
  String? _cameraError;
  DateTime? _lastProcessedAt;

  final _aggregator = FrameConsensusAggregator();
  final _nameController = TextEditingController();
  final _ingredientsController = TextEditingController();

  /// Once the user edits a field directly, auto-OCR updates stop
  /// overwriting it — their edit always wins.
  bool _nameEditedByUser = false;
  bool _ingredientsEditedByUser = false;

  /// Per-nutrient manual overrides — take precedence over the aggregator's
  /// live consensus value once the user edits a nutrition-table cell.
  final Map<String, String> _nutritionOverrides = {};

  /// "g" or "ml" — the nutrition panel's own printed basis (Indian labels
  /// print either "Per 100g" or "Per 100ml" depending on whether the
  /// product is solid or liquid; a bottled drink is never "per 100g").
  /// Defaults to "g" until the label itself says otherwise.
  String _nutritionUnit = 'g';
  static final RegExp _nutritionBasisPattern = RegExp(
    r'PER\s*100\s*(ML|M\.?L\.?|G|GM|GRAM)',
    caseSensitive: false,
  );

  // Step-1 auto-capture: once N consecutive frames find ANY plausible
  // label content, the photo is captured automatically. A manual capture
  // button is always available too, so nobody is stuck waiting. See the
  // long comment at the auto-capture call site (_recognizeFrame) for why
  // this intentionally does NOT also wait for the nutrition table
  // specifically to be in frame.
  int _goodFrameStreak = 0;
  File? _photo;

  /// Ticks up on every successfully processed live frame, on every step
  /// — the only visible proof the camera+OCR pipeline is actually still
  /// running once past the photo step, where the capture-streak pill no
  /// longer applies. Without this there's no way to tell "quietly
  /// scanning" apart from "silently stuck."
  int _framesProcessed = 0;

  /// User-controlled: the live scan otherwise keeps running (feeding OCR,
  /// re-merging fields) on every step for as long as this screen is open,
  /// even well after a value has already looked right — a field can keep
  /// getting silently re-voted and drift away from a correct reading the
  /// user already saw (founder-reported, 2026-07-09). Tapping the live-scan
  /// pill stops the camera's image-analysis stream outright (not just a
  /// processing no-op) so it also stops costing battery/CPU, not merely
  /// stops touching the form.
  bool _liveScanPaused = false;

  // Step-2 product-name consensus (see product_name_extractor.dart). Once
  // a candidate reaches _kRequiredAgreement once, it's confirmed and OCR
  // stops touching the field — otherwise the camera drifting onto some
  // OTHER tall printed text later (e.g. "NET QUANTITY") could silently
  // overwrite an already-correct name with a fresh 3-frame streak of its
  // own. Retaking the photo (_retakePhoto) resets this so a genuine
  // re-scan starts clean.
  String? _nameCandidate;
  int _nameStreak = 0;

  // Cloud vision-native analysis (Gemini reads the photo directly — see
  // label_photo_analysis_repository.dart). Runs concurrently with the
  // on-device still-photo OCR pass, not instead of it; the two are merged
  // via label_source_merger.dart once both are available. Never a hard
  // dependency — any failure here silently leaves the on-device flow as
  // the sole source of truth, per the founder's explicit "manual/on-device
  // stays the fallback" requirement.
  UploadedPhoto? _uploadedPhoto;
  LabelPhotoAnalysis? _cloudResult;
  bool _cloudAnalyzing = false;
  String? _cloudError;

  /// Fields where the cloud and on-device readings genuinely disagreed
  /// beyond tolerance — keyed the same way _nutritionOverrides is (nutrient
  /// key, or 'name' for the product name). Populated by _applyCloudMerge;
  /// cleared once the user resolves it via the normal edit affordance.
  final Map<String, (String cloud, String live)> _disagreements = {};

  /// Subset of _nutritionOverrides.keys that were filled by the cloud
  /// merge (agreeing with, or unopposed by, the live scan) rather than the
  /// user typing a value — shown with a distinct "From cloud" chip.
  /// Removed from this set (but the override itself kept) once the user
  /// edits that field directly, since their edit is no longer "from cloud."
  final Set<String> _cloudFilledKeys = {};
  bool _nameConfirmedByOcr = false;

  /// True while the post-capture still-photo OCR cross-check
  /// (_verifyPhotoWithOcr) is in flight — drives a visible "Verifying
  /// with high-resolution photo…" progress state so this async pass
  /// never feels like an unexplained stall.
  bool _verifyingStillPhoto = false;

  _Step _step = _Step.photo;
  _Stage _stage = _Stage.editing;
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
    } else if (state == AppLifecycleState.resumed && _stage == _Stage.editing) {
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
      _camera = back;
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
      // Respect a scan the user had already paused before the app was
      // backgrounded (didChangeAppLifecycleState rebuilds the controller
      // from scratch on resume) — otherwise resuming would silently
      // restart the camera's image-analysis stream against their choice.
      if (!_liveScanPaused) {
        await controller.startImageStream((image) => _onFrame(image, back));
      }
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
    if (_liveScanPaused || _processingFrame || !_ready || _stage != _Stage.editing) return;
    final now = DateTime.now();
    if (_lastProcessedAt != null && now.difference(_lastProcessedAt!) < _kFrameInterval) {
      return;
    }
    _lastProcessedAt = now;
    _processingFrame = true;
    _recognizeFrame(image, camera).whenComplete(() => _processingFrame = false);
  }

  Future<void> _toggleLiveScan() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final camera = _camera;
    if (_liveScanPaused) {
      if (camera != null && !controller.value.isStreamingImages) {
        await controller.startImageStream((image) => _onFrame(image, camera));
      }
      if (mounted) setState(() => _liveScanPaused = false);
    } else {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
      if (mounted) setState(() => _liveScanPaused = true);
    }
  }

  Future<void> _recognizeFrame(CameraImage image, CameraDescription camera) async {
    final recognizer = _recognizer;
    if (recognizer == null) return;
    try {
      final inputImage = cameraImageToInputImage(image, camera);
      if (inputImage == null) return;
      final recognized = await recognizer.processImage(inputImage);
      // The await above is a genuine suspension point — the user can
      // navigate away (disposing this State, including _nameController /
      // _ingredientsController) while a frame is mid-recognition. Every
      // line below this either mutates a controller or calls setState;
      // touching either after disposal throws ("TextEditingController
      // used after being disposed"), which then cascades into build-phase
      // errors on the next frame. Bail out immediately if unmounted.
      if (!mounted) return;
      _framesProcessed++;
      final text = recognized.text;
      if (text.trim().isEmpty) {
        _goodFrameStreak = 0;
        if (mounted) setState(() {});
        return;
      }

      // Product name candidate selection needs the OCR block/line
      // structure (a name often spans a couple of stacked lines of
      // different sizes — brand + flavour/variant — and ML Kit's own
      // block grouping already clusters those together), built here on
      // the main isolate since ML Kit's result objects themselves aren't
      // sendable across isolates.
      final blocks = <List<(String, double)>>[
        for (final block in recognized.blocks)
          [for (final line in block.lines) (line.text, line.boundingBox.height)],
      ];

      // The actual extraction work (regex field matching, name-candidate
      // selection, ingredients text) is CPU-bound pure Dart that used to
      // run inline on every frame, competing with widget build/layout/
      // paint on the same UI thread — disproportionately costly on a
      // low-end device. Run it on a background isolate instead; see
      // frame_extraction_worker.dart.
      final extraction = await compute(
        extractFrameData,
        FrameExtractionInput(text: text, blocks: blocks, extractIngredients: true),
      );
      // compute() is itself a genuine suspension point — same disposal
      // risk as the ML Kit await above.
      if (!mounted) return;

      final candidates = extraction.candidates;
      if (!candidates.isEmpty) _aggregator.addFrame(candidates);

      final nameGuess = extraction.nameGuess;
      if (nameGuess != null && !_nameConfirmedByOcr && !_nameEditedByUser) {
        // Fuzzy-tolerant streak, not byte-exact — a live, shaky, low-res
        // feed rarely reads the exact same string twice in a row (motion
        // blur, one dropped/extra character, a stray space), and requiring
        // exact equality reset the streak to 1 on nearly every frame,
        // making convergence unreliable. Same discipline the aggregator
        // already uses for date/nutrition consensus, just applied here
        // (levenshtein() is already exported by frame_consensus_aggregator.dart,
        // imported above). Tolerance scales with length so short names stay
        // strict while longer ones get proportionally more slack.
        final candidate = _nameCandidate;
        final tolerance = (nameGuess.length * 0.15).ceil().clamp(1, 5);
        final isFuzzyMatch =
            candidate != null && levenshtein(nameGuess, candidate) <= tolerance;
        if (isFuzzyMatch) {
          if (_nameStreak < _kRequiredAgreement) _nameStreak++;
          // Keep the more complete reading as the streak's representative —
          // same "longer read wins" logic used for ingredients below.
          if (nameGuess.length > candidate.length) _nameCandidate = nameGuess;
        } else {
          _nameCandidate = nameGuess;
          _nameStreak = 1;
        }
        if (_nameStreak >= _kRequiredAgreement) {
          // Use the streak's accumulated representative, not necessarily
          // this exact frame's read — _nameCandidate may already hold a
          // more complete variant seen earlier in the same streak.
          _nameController.text = _nameCandidate!;
          _nameConfirmedByOcr = true;
        }
      }

      final basisMatch = _nutritionBasisPattern.firstMatch(text);
      if (basisMatch != null) {
        final unit = basisMatch.group(1)!.toUpperCase();
        _nutritionUnit = unit.startsWith('ML') || unit.startsWith('M.L') ? 'ml' : 'g';
      }

      // Ingredients text doesn't fit the numeric multi-frame consensus
      // model (it's free text, not a value repeated across frames), so
      // this just keeps the longest candidate seen — OCR usually
      // truncates the tail, so a longer read is a strictly better one.
      final ingredients = extraction.ingredients;
      if (ingredients != null &&
          !_ingredientsEditedByUser &&
          ingredients.length > _ingredientsController.text.length) {
        _ingredientsController.text = ingredients;
      }

      final hasAnything = !candidates.isEmpty || nameGuess != null || ingredients != null;
      _goodFrameStreak = hasAnything ? _goodFrameStreak + 1 : 0;

      // Step 1's auto-capture: once the frame has looked steadily
      // "readable" for a few frames in a row, take the representative
      // photo automatically. Never fires more than once per screen visit
      // (guarded by _photo == null); a manual button covers anyone whose
      // label doesn't OCR-detect cleanly.
      //
      // This deliberately does NOT wait for the nutrition table
      // specifically to be visible (it used to, via a second
      // "_nutritionFrameStreak >= 2" condition that the capture-status
      // pill never reflected — the pill would say "ready" while capture
      // silently waited on a condition the user had no way to see or
      // satisfy, which was the single biggest contributor to the
      // "stuck for minutes" complaint). The cloud photo-analysis pass
      // (_analyzePhotoWithCloud) is now the nutrition source of truth, so
      // capture only needs to be "worth a round-trip," not "guaranteed to
      // contain every panel."
      if (_step == _Step.photo &&
          _photo == null &&
          !_capturing &&
          _goodFrameStreak >= _kRequiredAgreement) {
        unawaited(_capturePhoto());
      }

      if (mounted) setState(() {});
    } catch (_) {
      // Same policy as the expiry scanner: a failed frame is just one
      // fewer vote this round, never a surfaced error.
    }
  }

  Future<void> _capturePhoto() async {
    final controller = _controller;
    final camera = _camera;
    if (controller == null || camera == null || !controller.value.isInitialized) return;
    if (_capturing) return;
    _capturing = true;
    try {
      final wasStreaming = controller.value.isStreamingImages;
      if (wasStreaming) await controller.stopImageStream();
      final shot = await controller.takePicture();
      if (wasStreaming && mounted && _stage == _Stage.editing) {
        await controller.startImageStream((image) => _onFrame(image, camera));
      }
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      final photo = File(shot.path);
      setState(() {
        _photo = photo;
        _step = _Step.name;
        _verifyingStillPhoto = true;
      });
      // The live stream only ever sees small, motion-blurred frames. The
      // still photo just captured is full sensor resolution and
      // perfectly sharp — a strictly stronger OCR signal. Cross-check it
      // once as an independent second opinion, exactly the "verify twice
      // before trusting" discipline used everywhere else in this app.
      // _verifyingStillPhoto drives a visible "Verifying with
      // high-resolution photo…" state on the name step so this never
      // reads as a silent, unexplained pause.
      unawaited(_verifyPhotoWithOcr(photo));
      // Cloud vision-native pass — runs concurrently, not sequentially.
      // Uploads immediately (not waiting for final submit) so the round
      // trip starts as early as possible; typically resolves in a few
      // seconds while the user is still on the name/details steps.
      unawaited(_analyzePhotoWithCloud(photo));
    } catch (_) {
      // Leave _photo null — the manual capture button lets the user retry.
    } finally {
      _capturing = false;
    }
  }

  /// Runs one OCR pass against the full-resolution captured still photo
  /// (as opposed to the continuous low-res live-stream frames) and treats
  /// it as a second, independently stronger opinion for name, nutrition,
  /// AND unit basis — a full-res still is a cleaner read than any single
  /// live frame in every respect, not just the name.
  ///
  /// This matters most for a curved bottle label: ML Kit's own line
  /// segmentation can lose track of which row a nutrition value belongs
  /// to on small, low-res, motion-blurred live frames, occasionally
  /// scrambling reading order enough that no nutrient safely matches at
  /// all (confirmed live, 2026-07-09 — a Campa bottle's whole nutrition
  /// table stayed empty through the live stream). A full-resolution
  /// still photo gives ML Kit far more pixels to correctly cluster each
  /// row, so it's fed into the SAME consensus aggregator the live stream
  /// uses — but as [_kRequiredAgreement] identical "frames" at once, so
  /// a single clean high-res read can confirm on its own rather than
  /// waiting on more (likely still-scrambled) low-res frames to agree
  /// with it.
  Future<void> _verifyPhotoWithOcr(File photo) async {
    final recognizer = _recognizer;
    if (recognizer == null) return;
    try {
      final inputImage = InputImage.fromFilePath(photo.path);
      final recognized = await recognizer.processImage(inputImage);
      if (!mounted) return;

      if (!_nameEditedByUser) {
        final blocks = <List<(String, double)>>[
          for (final block in recognized.blocks)
            [for (final line in block.lines) (line.text, line.boundingBox.height)],
        ];
        final nameGuess = ProductNameExtractor.bestCandidate(blocks);
        if (nameGuess != null) {
          final current = _nameController.text;
          // Confidence rule: the still photo is always at least as
          // reliable as the live stream, but if the live stream already
          // confirmed a value, only replace it with a LONGER (more
          // complete) read rather than blindly overwriting a good value
          // with a shorter one — the same "longer read wins" logic
          // already used for ingredients below, where truncation (not
          // wrongness) is the dominant OCR failure mode.
          if (!_nameConfirmedByOcr || nameGuess.length > current.length) {
            setState(() {
              _nameController.text = nameGuess;
              _nameConfirmedByOcr = true;
            });
          }
        }
      }

      final basisMatch = _nutritionBasisPattern.firstMatch(recognized.text);
      if (basisMatch != null) {
        final unit = basisMatch.group(1)!.toUpperCase();
        setState(() {
          _nutritionUnit = unit.startsWith('ML') || unit.startsWith('M.L') ? 'ml' : 'g';
        });
      }

      final candidates = LabelFieldExtractor.extract(recognized.text);
      if (!candidates.isEmpty) {
        for (var i = 0; i < _kRequiredAgreement; i++) {
          _aggregator.addFrame(candidates);
        }
        final ingredients = extractFrameData(
          FrameExtractionInput(text: recognized.text, extractIngredients: true),
        ).ingredients;
        if (ingredients != null &&
            !_ingredientsEditedByUser &&
            ingredients.length > _ingredientsController.text.length) {
          _ingredientsController.text = ingredients;
        }
        setState(() {});
      }
    } catch (_) {
      // Best-effort second opinion — the live stream keeps running
      // regardless, so a failure here just means one fewer cross-check.
    } finally {
      if (mounted) setState(() => _verifyingStillPhoto = false);
    }
  }

  static const Map<String, String> _cloudNutrientKeyMap = {
    'energy': 'calories',
    'protein': 'protein',
    'fat': 'fat',
    'carbohydrate': 'carbohydrates',
    'sugar': 'sugars',
    'sodium': 'sodium',
  };

  /// Uploads the captured photo (if not already uploaded) and sends it to
  /// the vision-native cloud analysis endpoint — reads the label as an
  /// image directly rather than flattening it to OCR text first, which is
  /// what actually fixes wrong/missing nutrition values on curved labels
  /// (see label_source_merger.dart's file doc for the full rationale).
  /// Never a hard dependency: any failure here (network, quota, provider
  /// down) leaves the on-device flow as the sole source of truth, exactly
  /// as if this method didn't exist.
  Future<void> _analyzePhotoWithCloud(File photo) async {
    if (!mounted) return;
    setState(() {
      _cloudAnalyzing = true;
      _cloudError = null;
    });
    try {
      final uploaded = _uploadedPhoto ??
          await ref.read(productSubmissionRepositoryProvider).uploadPhotoEarly(photo);
      if (!mounted) return;
      _uploadedPhoto = uploaded;

      final result = await ref
          .read(labelPhotoAnalysisRepositoryProvider)
          .analyzePhoto(mediaId: uploaded.mediaId);
      if (!mounted) return;
      setState(() => _cloudResult = result);
      if (result.hasContent) {
        _applyCloudMerge(result);
      } else if (result.warnings.isNotEmpty) {
        setState(() => _cloudError = result.warnings.first);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _cloudError = 'Cloud analysis unavailable — using on-device scan only');
      }
    } finally {
      if (mounted) setState(() => _cloudAnalyzing = false);
    }
  }

  /// Compares the cloud result against whatever the live on-device scan
  /// already found, field by field, via label_source_merger.dart. Never
  /// overwrites a field the user has already edited by hand.
  void _applyCloudMerge(LabelPhotoAnalysis result) {
    if (!_nameEditedByUser) {
      final nameMerge = LabelSourceMerger.mergeText(
        cloudValue: result.productName,
        liveValue: _nameConfirmedByOcr ? _nameController.text : null,
        liveConfirmed: _nameConfirmedByOcr,
      );
      switch (nameMerge.status) {
        case MergeStatus.cloudOnly:
        case MergeStatus.agreed:
          if (nameMerge.value != null) {
            setState(() {
              _nameController.text = nameMerge.value!;
              _nameConfirmedByOcr = true;
              _disagreements.remove('name');
            });
          }
        case MergeStatus.disagreement:
          setState(() {
            _disagreements['name'] = (nameMerge.cloudValue!, nameMerge.liveValue!);
          });
        case MergeStatus.none:
          break;
      }
    }

    // Ingredients are free text (not a fixed-tolerance comparable value) —
    // same "longer read wins" heuristic used for the on-device still-photo
    // merge, no formal disagreement UI.
    if (result.ingredients.isNotEmpty && !_ingredientsEditedByUser) {
      final cloudText = result.ingredients.join(', ');
      if (cloudText.length > _ingredientsController.text.length) {
        setState(() => _ingredientsController.text = cloudText);
      }
    }

    final panel = result.nutritionPanel;
    if (panel == null) return;

    final live = _aggregator.nutritionStatus();
    for (final entry in _cloudNutrientKeyMap.entries) {
      final localKey = entry.key;
      // A field the user already resolved by hand (typed, or picked one
      // side of an earlier disagreement) is settled — never revisit it.
      if (_nutritionOverrides.containsKey(localKey) && !_cloudFilledKeys.contains(localKey)) {
        continue;
      }
      final cloudValue = _panelValue(panel, entry.value);
      if (cloudValue == null) continue;

      final liveConsensus = live[localKey];
      final liveConfirmed = liveConsensus?.confirmed ?? false;
      final liveValue =
          liveConfirmed ? double.tryParse(liveConsensus!.leadingValue ?? '') : null;
      final merged = LabelSourceMerger.mergeNumber(
        cloudValue: cloudValue,
        liveValue: liveValue,
        liveConfirmed: liveConfirmed,
      );
      switch (merged.status) {
        case MergeStatus.cloudOnly:
        case MergeStatus.agreed:
          if (merged.value != null) {
            setState(() {
              _nutritionOverrides[localKey] = _formatNutrientValue(localKey, merged.value!);
              _cloudFilledKeys.add(localKey);
              _disagreements.remove(localKey);
            });
          }
        case MergeStatus.disagreement:
          setState(() {
            _disagreements[localKey] = (
              _formatNutrientValue(localKey, merged.cloudValue!),
              _formatNutrientValue(localKey, merged.liveValue!),
            );
          });
        case MergeStatus.none:
          break;
      }
    }

    if (panel.servingUnit != null) {
      final resolved = panel.servingUnit!.toUpperCase().startsWith('ML') ? 'ml' : 'g';
      if (resolved != _nutritionUnit) {
        setState(() => _nutritionUnit = resolved);
      }
    }
  }

  static double? _panelValue(LabelPhotoNutritionPanel panel, String key) {
    switch (key) {
      case 'calories':
        return panel.calories;
      case 'protein':
        return panel.protein;
      case 'fat':
        return panel.fat;
      case 'carbohydrates':
        return panel.carbohydrates;
      case 'sugars':
        return panel.sugars;
      case 'sodium':
        return panel.sodium;
      default:
        return null;
    }
  }

  /// Per-nutrient unit is fixed regardless of the panel's overall serving
  /// basis (_nutritionUnit is "g" vs "ml" for the *denominator* — "per
  /// 100ml" — not the nutrient's own measurement unit; sodium is always
  /// measured in mg even on a per-100ml liquid label). Matches
  /// label_field_extractor.dart's own normalization convention.
  static String _unitFor(String localKey) {
    if (localKey == 'energy') return 'kcal';
    if (localKey == 'sodium') return 'mg';
    return 'g';
  }

  static String _formatNutrientValue(String localKey, double value) {
    // Whole numbers display without a trailing ".0"; otherwise keep one
    // decimal place — matches the precision nutrition labels actually print.
    final rounded = (value * 10).round() / 10;
    final text = rounded == rounded.roundToDouble()
        ? rounded.toInt().toString()
        : rounded.toStringAsFixed(1);
    return '$text${_unitFor(localKey)}';
  }

  void _retakePhoto() {
    HapticFeedback.selectionClick();
    setState(() {
      _photo = null;
      _goodFrameStreak = 0;
      _step = _Step.photo;
      // A new photo needs its own fresh cloud analysis — the old upload/
      // result belonged to the discarded photo. Leave already-resolved
      // nutrition overrides/disagreements alone: those reflect the live
      // stream's own ongoing state, not this specific photo.
      _uploadedPhoto = null;
      _cloudResult = null;
      _cloudAnalyzing = false;
      _cloudError = null;
      if (!_nameEditedByUser) {
        _nameConfirmedByOcr = false;
        _nameCandidate = null;
        _nameStreak = 0;
        _nameController.clear();
      }
    });
  }

  void _goToStep(_Step step) {
    HapticFeedback.selectionClick();
    setState(() => _step = step);
  }

  bool get _canSubmit => _nameController.text.trim().isNotEmpty && _photo != null;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    HapticFeedback.mediumImpact();
    setState(() => _stage = _Stage.submitting);

    final nutrition = _buildNutritionPayload();

    final photo = _photo;
    try {
      await ref.read(productSubmissionRepositoryProvider).submit(
            ean: widget.ean,
            name: _nameController.text.trim(),
            ingredients: _ingredientsController.text,
            nutrition: nutrition,
            photo: photo,
            // Already uploaded right after capture (for the cloud analysis
            // pass) — reuse it instead of uploading the same bytes twice.
            alreadyUploaded: _uploadedPhoto,
          );
      // The local temp photo has done its job (auto-fill source, and
      // whatever the repository already uploaded/attached) — delete the
      // on-device copy now rather than leaving it sitting in app storage.
      if (photo != null) {
        unawaited(photo.delete().catchError((_) => photo));
      }
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

  /// Confirmed (or manually overridden) value for one nutrient, or null if
  /// neither exists yet — used both for the payload and for rendering.
  String? _nutritionValue(String key, Map<String, FieldConsensus> live) {
    final override = _nutritionOverrides[key];
    if (override != null) return override;
    final c = live[key];
    if (c == null || !c.confirmed || c.leadingValue == null) return null;
    return c.leadingValue;
  }

  /// Matches the leading numeric portion of a value string — values are
  /// stored/displayed with their unit attached ("11.5g", "5mg") or, for a
  /// manual entry, potentially as free text ("Not mentioned", "<1g"), so
  /// a bare `double.tryParse` on the whole string always failed silently
  /// whenever a unit or qualitative text followed the number. A
  /// qualitative entry with no leading digit correctly yields null here —
  /// there's no number to submit for "Not mentioned".
  static final RegExp _leadingNumber = RegExp(r'^-?\d+(?:\.\d+)?');

  NutritionPanelPayload? _buildNutritionPayload() {
    final live = _aggregator.nutritionStatus();
    double? asDouble(String key) {
      final v = _nutritionValue(key, live);
      if (v == null) return null;
      final match = _leadingNumber.firstMatch(v.trim());
      return match == null ? null : double.tryParse(match.group(0)!);
    }

    final payload = NutritionPanelPayload(
      calories: asDouble('energy'),
      protein: asDouble('protein'),
      carbohydrates: asDouble('carbohydrate'),
      sugars: asDouble('sugar'),
      fat: asDouble('fat'),
      sodium: asDouble('sodium'),
      // Potassium has no direct product_nutrition column — omitted here;
      // the raw OCR transcript already isn't retained by this flow since
      // (unlike the expiry scanner) there's no downstream field that
      // reads it back.
    );
    return payload.isEmpty ? null : payload;
  }

  Future<void> _editNutrientValue(String key) async {
    final live = _aggregator.nutritionStatus();
    final disagreement = _disagreements[key];
    final current = disagreement == null ? (_nutritionValue(key, live) ?? '') : '';
    final controller = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_nutrientLabel(key)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (disagreement != null) ...[
              Text(
                'The camera and the cloud scan disagreed — pick one, or type your own.',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
              const SizedBox(height: RadhaSpacing.space8),
              Wrap(
                spacing: RadhaSpacing.space8,
                children: [
                  ActionChip(
                    label: Text('Cloud: ${disagreement.$1}'),
                    onPressed: () => Navigator.of(ctx).pop(disagreement.$1),
                  ),
                  ActionChip(
                    label: Text('Camera: ${disagreement.$2}'),
                    onPressed: () => Navigator.of(ctx).pop(disagreement.$2),
                  ),
                ],
              ),
              const SizedBox(height: RadhaSpacing.space12),
            ],
            TextField(
              controller: controller,
              autofocus: disagreement == null,
              // Plain text, not a numeric keypad — a value here is often
              // more than a bare number ("11.5 g", "250 ml", "<1g", "Not
              // mentioned"), and a numeric-only keyboard makes typing that
              // awkward or impossible on some devices.
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'e.g. 11.5 $_nutritionUnit, or "Not mentioned"',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null && result.isNotEmpty && mounted) {
      setState(() {
        _nutritionOverrides[key] = result;
        _cloudFilledKeys.remove(key);
        _disagreements.remove(key);
      });
    }
  }

  /// Fallback for labels the camera genuinely can't parse reliably (e.g. a
  /// curved bottle label, where OCR reading order gets scrambled by the
  /// surface curvature and no auto-extraction heuristic can safely
  /// recover it) — lets the user pick and fill in any nutrient by hand
  /// rather than being stuck with an empty table.
  Future<void> _addNutrientManually() async {
    final live = _aggregator.nutritionStatus();
    final missing = _NutritionTable._knownOrder.where((k) {
      final hasReading = live[k]?.hasAnyReading ?? false;
      return !hasReading && !_nutritionOverrides.containsKey(k);
    }).toList();
    if (missing.isEmpty) return;

    final chosen = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final key in missing)
              ListTile(
                title: Text(_nutrientLabel(key)),
                onTap: () => Navigator.of(ctx).pop(key),
              ),
          ],
        ),
      ),
    );
    if (chosen != null && mounted) await _editNutrientValue(chosen);
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
    // Abandoned mid-flow (back button, etc. — _stage never reached
    // submitted/submitting) — the captured temp photo never got used for
    // anything and shouldn't linger in app storage.
    if (_stage == _Stage.editing) {
      final photo = _photo;
      if (photo != null) unawaited(photo.delete().catchError((_) => photo));
    }
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
          _Stage.editing => _buildWizardBody(context),
          _Stage.submitting => const Center(child: CircularProgressIndicator()),
          _Stage.submitted => _buildSubmittedBody(context),
          _Stage.failed => _buildFailedBody(context),
        },
      ),
    );
  }

  Widget _buildWizardBody(BuildContext context) {
    return Column(
      children: [
        _StepIndicator(step: _step),
        Expanded(flex: 4, child: _buildCameraArea(context)),
        Expanded(flex: 6, child: _buildStepArea(context)),
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
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          // Always-visible proof-of-life: the camera keeps running and
          // feeding OCR on every step, not just during photo capture —
          // without this there's no way to tell "still scanning" apart
          // from "silently stuck" once past step 1.
          if (_step != _Step.review)
            Positioned(
              top: RadhaSpacing.space12,
              right: RadhaSpacing.space12,
              child: _LiveScanIndicator(
                frames: _framesProcessed,
                paused: _liveScanPaused,
                onToggle: _toggleLiveScan,
              ),
            ),
          if (_step == _Step.photo)
            Positioned(
              left: 0,
              right: 0,
              bottom: RadhaSpacing.space12,
              child: Center(
                child: _CaptureStatusPill(
                  streak: _goodFrameStreak,
                  required: _kRequiredAgreement,
                  capturing: _capturing,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepArea(BuildContext context) {
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
          Expanded(
            child: switch (_step) {
              _Step.photo => _buildPhotoStep(context),
              _Step.name => _buildNameStep(context),
              _Step.details => _buildDetailsStep(context),
              _Step.review => _buildReviewStep(context),
            },
          ),
          _buildStepFooter(context),
        ],
      ),
    );
  }

  Widget _buildPhotoStep(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        RadhaSpacing.space20,
        RadhaSpacing.space16,
        RadhaSpacing.space20,
        RadhaSpacing.space8,
      ),
      children: [
        Text('Photograph this product', style: theme.textTheme.titleMedium),
        const SizedBox(height: RadhaSpacing.space4),
        Text(
          'EAN ${widget.ean}',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: RadhaSpacing.space12),
        Text(
          'Hold the front of the pack steady in view. It captures '
          'automatically once the label is readable — or tap Capture now.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildNameStep(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        RadhaSpacing.space20,
        RadhaSpacing.space16,
        RadhaSpacing.space20,
        RadhaSpacing.space8,
      ),
      children: [
        if (_photo != null) _PhotoThumbnail(photo: _photo!, onRetake: _retakePhoto),
        const SizedBox(height: RadhaSpacing.space8),
        _VerificationProgress(verifying: _verifyingStillPhoto),
        const SizedBox(height: RadhaSpacing.space16),
        Text('Product name *', style: theme.textTheme.labelLarge),
        const SizedBox(height: RadhaSpacing.space4),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'e.g. Amul Butter 500g',
            suffixIcon: _nameConfirmedByOcr && !_nameEditedByUser
                ? const Icon(Icons.auto_awesome_rounded, color: RadhaColors.primary)
                : null,
          ),
          onChanged: (_) => setState(() => _nameEditedByUser = true),
        ),
        const SizedBox(height: RadhaSpacing.space8),
        Text(
          _verifyingStillPhoto
              ? 'Cross-checking against the full-resolution photo…'
              : _nameConfirmedByOcr
                  ? 'Detected from the label — edit if it\'s not quite right.'
                  : 'Point the camera at the front of the pack to auto-fill this.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: RadhaSpacing.space16),
        _StepReadyBanner(
          ready: _nameController.text.trim().isNotEmpty,
          readyText: 'Name set — tap Next to continue.',
          pendingText: 'Enter or wait for a product name to continue.',
        ),
      ],
    );
  }

  Widget _buildDetailsStep(BuildContext context) {
    final theme = Theme.of(context);
    final nutrition = _aggregator.nutritionStatus();
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        RadhaSpacing.space20,
        RadhaSpacing.space16,
        RadhaSpacing.space20,
        RadhaSpacing.space8,
      ),
      children: [
        _CloudAnalysisStatus(
          analyzing: _cloudAnalyzing,
          hasResult: _cloudResult?.hasContent ?? false,
          error: _cloudError,
        ),
        const SizedBox(height: RadhaSpacing.space12),
        Text('Nutrition (per 100$_nutritionUnit)', style: theme.textTheme.labelLarge),
        const SizedBox(height: RadhaSpacing.space8),
        _NutritionTable(
          nutrition: nutrition,
          unit: _nutritionUnit,
          overrideKeys: _nutritionOverrides.keys.toSet(),
          cloudKeys: _cloudFilledKeys,
          disagreements: _disagreements,
          valueOf: (key) => _nutritionValue(key, nutrition),
          onEdit: _editNutrientValue,
        ),
        const SizedBox(height: RadhaSpacing.space8),
        TextButton.icon(
          onPressed: _addNutrientManually,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add a value the camera missed'),
        ),
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
          'oils, additives. Check it matches the pack before continuing.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep(BuildContext context) {
    final theme = Theme.of(context);
    final nutrition = _aggregator.nutritionStatus();
    final hasNutrition =
        nutrition.values.any((c) => c.hasAnyReading) || _nutritionOverrides.isNotEmpty;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        RadhaSpacing.space20,
        RadhaSpacing.space16,
        RadhaSpacing.space20,
        RadhaSpacing.space8,
      ),
      children: [
        Text('Review before submitting', style: theme.textTheme.titleMedium),
        const SizedBox(height: RadhaSpacing.space12),
        if (_photo != null) _PhotoThumbnail(photo: _photo!, onRetake: _retakePhoto),
        const SizedBox(height: RadhaSpacing.space16),
        _ReviewRow(
          label: 'Product name',
          value: _nameController.text.trim().isEmpty
              ? 'Not set'
              : _nameController.text.trim(),
          onEdit: () => _goToStep(_Step.name),
        ),
        const Divider(height: RadhaSpacing.space24),
        _ReviewRow(
          label: 'Ingredients',
          value: _ingredientsController.text.trim().isEmpty
              ? 'Not set'
              : _ingredientsController.text.trim(),
          onEdit: () => _goToStep(_Step.details),
        ),
        if (hasNutrition) ...[
          const Divider(height: RadhaSpacing.space24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nutrition (per 100$_nutritionUnit)', style: theme.textTheme.labelLarge),
              TextButton(
                onPressed: () => _goToStep(_Step.details),
                child: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: RadhaSpacing.space8),
          _NutritionTable(
            nutrition: nutrition,
            unit: _nutritionUnit,
            overrideKeys: _nutritionOverrides.keys.toSet(),
            cloudKeys: _cloudFilledKeys,
            disagreements: _disagreements,
            valueOf: (key) => _nutritionValue(key, nutrition),
            onEdit: _editNutrientValue,
          ),
        ],
      ],
    );
  }

  Widget _buildStepFooter(BuildContext context) {
    final isFirst = _step == _Step.photo;
    final isReview = _step == _Step.review;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        RadhaSpacing.space20,
        0,
        RadhaSpacing.space20,
        RadhaSpacing.space16,
      ),
      child: Row(
        children: [
          if (!isFirst)
            Expanded(
              child: OutlinedButton(
                onPressed: () => _goToStep(_Step.values[_step.index - 1]),
                child: const Text('Back'),
              ),
            ),
          if (!isFirst) const SizedBox(width: RadhaSpacing.space8),
          Expanded(
            flex: 2,
            child: isReview
                ? PrimaryButton(
                    label: 'Submit',
                    icon: Icons.check_rounded,
                    expand: true,
                    onPressed: _canSubmit ? _submit : null,
                  )
                : PrimaryButton(
                    label: _step == _Step.photo ? 'Capture now' : 'Next',
                    icon: _step == _Step.photo
                        ? Icons.camera_alt_rounded
                        : Icons.arrow_forward_rounded,
                    expand: true,
                    onPressed: _step == _Step.photo
                        ? (_photo == null ? _capturePhoto : () => _goToStep(_Step.name))
                        : (_step == _Step.name && _nameController.text.trim().isEmpty
                            ? null
                            : () => _goToStep(_Step.values[_step.index + 1])),
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
              onPressed: () => setState(() => _stage = _Stage.editing),
            ),
          ],
        ),
      ),
    );
  }
}

/// Four dots across the top of the sheet showing wizard progress.
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step});

  final _Step step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: RadhaSpacing.space8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final s in _Step.values) ...[
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: s.index <= step.index
                    ? RadhaColors.primary
                    : Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Explicit "is this step done yet" signal — green check + confirmation
/// text once ready, neutral pending text otherwise. Every step needs its
/// own unambiguous done/not-done state; without this a user has no way to
/// tell whether they can safely move on.
class _StepReadyBanner extends StatelessWidget {
  const _StepReadyBanner({
    required this.ready,
    required this.readyText,
    required this.pendingText,
  });

  final bool ready;
  final String readyText;
  final String pendingText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space12,
        vertical: RadhaSpacing.space8,
      ),
      decoration: BoxDecoration(
        color: ready
            ? RadhaColors.success.withValues(alpha: 0.10)
            : theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        border: Border.all(
          color: ready ? RadhaColors.success : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Icon(
            ready ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: ready ? RadhaColors.success : theme.colorScheme.onSurfaceVariant,
            size: 18,
          ),
          const SizedBox(width: RadhaSpacing.space8),
          Expanded(
            child: Text(
              ready ? readyText : pendingText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: ready ? RadhaColors.success : theme.colorScheme.onSurfaceVariant,
                fontWeight: ready ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Live status pill over the camera preview during the photo step — shows
/// streak progress towards auto-capture, or a brief "Capturing…" state.
/// Small persistent pill in the corner of the camera preview, present on
/// every step while the camera is active — a pulsing dot plus the live
/// running frame count, so it's never ambiguous whether the camera is
/// actually still scanning or has silently stalled.
///
/// Tappable: the live scan otherwise never stops on its own for as long as
/// this screen stays open, which can keep re-voting a field long after the
/// user is satisfied with it — this is the manual "stop scanning" control
/// (founder-requested, 2026-07-09) so the camera's image stream can be shut
/// off outright once the visible fields look right, not just muted.
class _LiveScanIndicator extends StatefulWidget {
  const _LiveScanIndicator({
    required this.frames,
    required this.paused,
    required this.onToggle,
  });

  final int frames;
  final bool paused;
  final VoidCallback onToggle;

  @override
  State<_LiveScanIndicator> createState() => _LiveScanIndicatorState();
}

class _LiveScanIndicatorState extends State<_LiveScanIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paused = widget.paused;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: widget.onToggle,
        borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: RadhaSpacing.space12,
            vertical: RadhaSpacing.space4,
          ),
          decoration: BoxDecoration(
            color: RadhaColors.ink.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (paused)
                const _Dot(color: RadhaColors.onPrimary)
              else
                FadeTransition(opacity: _pulse, child: const _Dot()),
              const SizedBox(width: RadhaSpacing.space8),
              Text(
                paused ? 'Scanning paused · tap to resume' : 'Scanning live · ${widget.frames}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: RadhaColors.onPrimary,
                ),
              ),
              const SizedBox(width: RadhaSpacing.space8),
              Icon(
                paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                size: 16,
                color: RadhaColors.onPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({this.color = RadhaColors.success});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _CaptureStatusPill extends StatelessWidget {
  const _CaptureStatusPill({
    required this.streak,
    required this.required,
    required this.capturing,
  });

  final int streak;
  final int required;
  final bool capturing;

  @override
  Widget build(BuildContext context) {
    final ready = streak >= required;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space16,
        vertical: RadhaSpacing.space8,
      ),
      decoration: BoxDecoration(
        color: RadhaColors.ink.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusFull),
        border: Border.all(
          color: ready ? RadhaColors.success : RadhaColors.onPrimary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ready)
            const Icon(Icons.check_circle_rounded, color: RadhaColors.success, size: 16)
          else
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: RadhaColors.primary),
            ),
          const SizedBox(width: RadhaSpacing.space8),
          Text(
            capturing
                ? 'Capturing…'
                : ready
                    ? 'Readable — capturing'
                    : 'Reading label… $streak/$required',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: RadhaColors.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  const _PhotoThumbnail({required this.photo, required this.onRetake});

  final File photo;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
          child: Image.file(photo, width: 56, height: 56, fit: BoxFit.cover),
        ),
        const SizedBox(width: RadhaSpacing.space12),
        Expanded(
          child: Text(
            'Photo captured',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        TextButton(onPressed: onRetake, child: const Text('Retake')),
      ],
    );
  }
}

/// Explicit "what's happening right now" line for the post-capture
/// still-photo OCR cross-check — a small spinner + label while it's in
/// flight, a checkmark once it's done, so the async pause between
/// "Photo captured" and the name field settling never reads as a stall.
class _VerificationProgress extends StatelessWidget {
  const _VerificationProgress({required this.verifying});

  final bool verifying;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 14,
          height: 14,
          child: verifying
              ? const CircularProgressIndicator(strokeWidth: 2)
              : Icon(Icons.check_circle_rounded, size: 14, color: RadhaColors.success),
        ),
        const SizedBox(width: RadhaSpacing.space8),
        Text(
          verifying
              ? 'Verifying with high-resolution photo…'
              : 'Verified against the captured photo',
          style: theme.textTheme.bodySmall?.copyWith(
            color: verifying ? theme.colorScheme.onSurfaceVariant : RadhaColors.success,
          ),
        ),
      ],
    );
  }
}

/// Visible status for the cloud vision-native analysis pass — mirrors
/// _VerificationProgress's "never a silent wait" discipline. Renders
/// nothing until the pass has actually started (before that, there's
/// nothing meaningful to report yet).
class _CloudAnalysisStatus extends StatelessWidget {
  const _CloudAnalysisStatus({
    required this.analyzing,
    required this.hasResult,
    required this.error,
  });

  final bool analyzing;
  final bool hasResult;
  final String? error;

  @override
  Widget build(BuildContext context) {
    if (!analyzing && !hasResult && error == null) return const SizedBox.shrink();
    final theme = Theme.of(context);

    final (icon, text, color) = analyzing
        ? (null, 'Verifying with cloud scan…', theme.colorScheme.onSurfaceVariant)
        : error != null
            ? (Icons.info_outline_rounded, error!, theme.colorScheme.onSurfaceVariant)
            : (Icons.check_circle_rounded, 'Cloud scan complete', RadhaColors.success);

    return Row(
      children: [
        SizedBox(
          width: 14,
          height: 14,
          child: analyzing
              ? const CircularProgressIndicator(strokeWidth: 2)
              : Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: RadhaSpacing.space8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value, required this.onEdit});

  final String label;
  final String value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.labelLarge),
            TextButton(onPressed: onEdit, child: const Text('Edit')),
          ],
        ),
        Text(value, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

/// Responsive nutrition-facts table — every row is built from Expanded
/// cells (never fixed widths), so it can never overflow horizontally on a
/// narrow screen; long labels/values ellipsize instead.
class _NutritionTable extends StatelessWidget {
  const _NutritionTable({
    required this.nutrition,
    required this.unit,
    this.overrideKeys = const {},
    this.cloudKeys = const {},
    this.disagreements = const {},
    required this.valueOf,
    required this.onEdit,
  });

  final Map<String, FieldConsensus> nutrition;
  final String unit;
  /// Nutrients the user filled in by hand (via "Add a value the camera
  /// missed") — shown even when the camera never produced any reading at
  /// all for them, which a hard case (e.g. a curved bottle label
  /// scrambling OCR reading order) can genuinely leave empty forever.
  final Set<String> overrideKeys;
  /// Subset of [overrideKeys] that came from the cloud photo analysis
  /// (agreeing with, or unopposed by, the live scan) rather than the user
  /// typing a value directly — shown with a distinct "From cloud" chip so
  /// the user knows it wasn't manually entered.
  final Set<String> cloudKeys;
  /// Nutrients where the cloud and live scans genuinely disagreed —
  /// (cloudValue, liveValue) — shown with a "Review" chip prompting the
  /// user to pick one via [onEdit], never silently resolved either way.
  final Map<String, (String, String)> disagreements;
  final String? Function(String key) valueOf;
  final void Function(String key) onEdit;

  static const List<String> _knownOrder = [
    'energy',
    'protein',
    'fat',
    'carbohydrate',
    'sugar',
    'sodium',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keys = _knownOrder
        .where(
          (k) =>
              (nutrition[k]?.hasAnyReading ?? false) ||
              overrideKeys.contains(k) ||
              disagreements.containsKey(k),
        )
        .toList();
    if (keys.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(RadhaSpacing.space12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
        ),
        child: Text(
          'Point the camera at the nutrition panel to auto-fill this table.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(RadhaRadii.radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: theme.colorScheme.surfaceContainer,
            padding: const EdgeInsets.symmetric(
              horizontal: RadhaSpacing.space12,
              vertical: RadhaSpacing.space8,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Nutrient', style: theme.textTheme.labelSmall),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Per 100$unit', style: theme.textTheme.labelSmall),
                ),
                const Expanded(flex: 2, child: SizedBox.shrink()),
              ],
            ),
          ),
          for (final key in keys)
            _NutritionRow(
              label: _labelFor(key),
              value: disagreements.containsKey(key) ? '—' : _formatForDisplay(valueOf(key)),
              consensus: nutrition[key] ??
                  FieldConsensus(
                    field: LabelField.nutrition,
                    leadingValue: valueOf(key),
                    leadingRaw: valueOf(key),
                    agreementCount: 1,
                    windowSize: 1,
                    combinedConfidence: 1,
                    confirmed: true,
                  ),
              manual: overrideKeys.contains(key) &&
                  !cloudKeys.contains(key) &&
                  !(nutrition[key]?.hasAnyReading ?? false),
              fromCloud: cloudKeys.contains(key),
              disagreement: disagreements[key],
              onEdit: () => onEdit(key),
            ),
        ],
      ),
    );
  }

  static String _labelFor(String key) {
    switch (key) {
      case 'energy':
        return 'Calories / Energy';
      default:
        return key[0].toUpperCase() + key.substring(1);
    }
  }

  /// "11.5g" -> "11.5 g" for readability — a value and its unit are
  /// stored concatenated (see label_field_extractor.dart's encoding
  /// contract, which the payload parser and consensus engine both key
  /// off), so this only affects what's drawn on screen. A qualitative
  /// manual entry ("Not mentioned") has no number/unit split to make and
  /// passes through unchanged.
  static final RegExp _valueUnitSplit = RegExp(r'^(-?\d+(?:\.\d+)?)([a-zA-Z%]+)$');

  static String _formatForDisplay(String? value) {
    if (value == null) return '—';
    final m = _valueUnitSplit.firstMatch(value.trim());
    if (m == null) return value;
    return '${m.group(1)} ${m.group(2)}';
  }
}

class _NutritionRow extends StatelessWidget {
  const _NutritionRow({
    required this.label,
    required this.value,
    required this.consensus,
    this.manual = false,
    this.fromCloud = false,
    this.disagreement,
    required this.onEdit,
  });

  final String label;
  final String value;
  final FieldConsensus consensus;
  final bool manual;
  final bool fromCloud;
  /// (cloudValue, liveValue) when the two sources disagreed — takes
  /// priority over every other chip state; tapping edit is how the user
  /// resolves it.
  final (String, String)? disagreement;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (chipLabel, tone) = disagreement != null
        ? ('Review', RadhaStatusTone.danger)
        : fromCloud
            ? ('From cloud', RadhaStatusTone.info)
            : manual
                ? ('Manual', RadhaStatusTone.info)
                : consensus.confirmed
                    ? ('Verified', RadhaStatusTone.success)
                    : ('${consensus.agreementCount}/${consensus.windowSize}', RadhaStatusTone.warning);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RadhaSpacing.space12,
        vertical: RadhaSpacing.space8,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(child: RadhaStatusChip(label: chipLabel, tone: tone)),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: onEdit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

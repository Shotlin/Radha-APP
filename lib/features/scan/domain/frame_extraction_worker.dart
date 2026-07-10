// Bundles the CPU-bound pure-Dart post-processing that both live-scanner
// screens run on EVERY camera frame — field extraction, product-name
// candidate selection, ingredients-text extraction — into a single
// compute()-able call, so it runs on a background isolate instead of
// blocking the UI thread every ~300ms. `grep -rn "compute(\|Isolate\."
// lib/` returned zero matches before this file; this was the confirmed
// cause of disproportionate jank on low-end devices (same synchronous
// regex/clustering work competes harder for a weaker CPU's single UI
// thread) — see the Phase 4 plan.
//
// Deliberately does NOT include FrameConsensusAggregator.addFrame, even
// though it's pure Dart too: the aggregator holds mutable state
// (accumulating windows) that lives on the main isolate and must stay
// there — compute()/Isolate.run copy the callback's argument and result
// across the isolate boundary, they don't let a background isolate mutate
// an object the main isolate still holds. The caller applies addFrame
// synchronously with this function's output; that step alone is a bounded
// clustering update, not a full regex sweep, so leaving it on the main
// isolate is not a meaningful cost.
import 'label_field_extractor.dart';
import 'label_field_models.dart';
import 'product_name_extractor.dart';

class FrameExtractionInput {
  const FrameExtractionInput({
    required this.text,
    this.blocks = const [],
    this.extractIngredients = false,
  });

  final String text;

  /// OCR blocks (grouped lines with heights), used for product-name
  /// candidate selection. Pass empty when the caller doesn't need a name
  /// guess (e.g. the expiry/date-only live scanner).
  final List<List<(String text, double height)>> blocks;

  /// Whether to also run ingredients-header extraction — only the
  /// "contribute a product" flow has an ingredients field.
  final bool extractIngredients;
}

class FrameExtractionResult {
  const FrameExtractionResult({
    required this.candidates,
    this.nameGuess,
    this.ingredients,
  });

  final LabelFieldCandidates candidates;
  final String? nameGuess;
  final String? ingredients;
}

// Boundary keywords marking the end of an INGREDIENTS run-on section —
// whichever comes first cuts the capture so it doesn't swallow the
// nutrition panel or MFG/EXP/batch block that typically follows it.
final RegExp _ingredientsHeader = RegExp(
  r'INGREDIENTS?(?:\s*LIST)?\s*[:.\-]?\s*',
  caseSensitive: false,
);
final RegExp _ingredientsBoundary = RegExp(
  r'\b(NUTRITION(?:AL)?|ENERGY|ALLERGEN|STORAGE|STORE\s*IN|MFD|MFG|EXP|'
  r'EXPIRY|BEST\s*BEFORE|USE\s*BY|BATCH|NET\s*(WT|WEIGHT|QTY)|BARCODE|'
  r'FSSAI|CUSTOMER\s*CARE)\b',
  caseSensitive: false,
);

String? _extractIngredientsText(String text) {
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

/// Top-level (not a closure/instance method) so it's usable directly as a
/// `compute()` callback: `await compute(extractFrameData, input)`.
FrameExtractionResult extractFrameData(FrameExtractionInput input) {
  final candidates = LabelFieldExtractor.extract(input.text);
  final nameGuess =
      input.blocks.isEmpty ? null : ProductNameExtractor.bestCandidate(input.blocks);
  final ingredients =
      input.extractIngredients ? _extractIngredientsText(input.text) : null;
  return FrameExtractionResult(
    candidates: candidates,
    nameGuess: nameGuess,
    ingredients: ingredients,
  );
}

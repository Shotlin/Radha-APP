// Data models shared by the live label-scanner's extraction engine and
// multi-frame consensus aggregator. Kept dependency-free (no Flutter imports)
// so the extraction/consensus logic is plain-Dart and unit-testable without
// a widget test harness or a real camera.

/// The fields the live scanner knows how to extract. Each maps to one card
/// in the scanner UI and one slot in [LiveScanResult].
enum LabelField {
  expiryDate,
  mfgDate,
  batchNumber,
  skuOrProductId,
  nutrition,
}

/// One field reading pulled from a single OCR frame/transcript.
///
/// `value` is the normalized representation used for cross-frame equality
/// checks (e.g. an ISO date string, an uppercased batch code) — never the
/// raw matched substring, so frames that agree in substance but differ in
/// whitespace/case still count as agreement in the consensus aggregator.
/// `raw` is kept for on-screen display/audit ("read from: EXP 15/03/2025").
class FieldCandidate {
  const FieldCandidate({
    required this.field,
    required this.value,
    required this.raw,
    required this.confidence,
    this.derivedFrom,
  });

  final LabelField field;
  final String value;
  final String raw;

  /// Pattern-level confidence (0–1) — how unambiguous the matched format is,
  /// independent of how many frames have agreed on it so far. An `EXP`-
  /// prefixed DD/MM/YYYY match is more confident than a bare, unprefixed one.
  final double confidence;

  /// Set when this candidate was calculated rather than read directly (e.g.
  /// "expiry = MFG + 6 months" from a shelf-life phrase) — shown to the user
  /// so they can see how a computed date was derived, not just the result.
  final String? derivedFrom;
}

/// All field candidates pulled from a single frame's recognized text.
/// A frame may yield zero, one, or several candidates per field (e.g. both
/// an EXP and a bare date match) — the extractor keeps only the
/// highest-confidence one per field per frame.
class LabelFieldCandidates {
  const LabelFieldCandidates({required this.transcript, required this.byField});

  final String transcript;
  final Map<LabelField, FieldCandidate> byField;

  bool get isEmpty => byField.isEmpty;
}

/// Aggregated status of one field across the rolling frame window.
class FieldConsensus {
  const FieldConsensus({
    required this.field,
    required this.leadingValue,
    required this.leadingRaw,
    required this.agreementCount,
    required this.windowSize,
    required this.combinedConfidence,
    required this.confirmed,
    this.derivedFrom,
  });

  final LabelField field;

  /// The most-agreed-upon value in the current window. Null if no frame has
  /// ever produced a candidate for this field.
  final String? leadingValue;
  final String? leadingRaw;

  /// How many of the last [windowSize] frames (that had *any* reading for
  /// this field) agreed with [leadingValue].
  final int agreementCount;
  final int windowSize;

  /// Pattern confidence scaled by frame agreement — this is what the UI
  /// shows and what gates auto-population; never a single frame's raw score.
  final double combinedConfidence;

  /// True once agreement/confidence clears the aggregator's thresholds.
  /// Only a confirmed field is safe to silently carry into the form —
  /// everything else must be shown as a low-confidence hint the user can
  /// accept, edit, or ignore.
  final bool confirmed;

  final String? derivedFrom;

  bool get hasAnyReading => leadingValue != null;
}

/// Emitted by [FrameConsensusAggregator] (frame_consensus_aggregator.dart)
/// when a confirmed field's leading value is replaced by a stronger,
/// sustained challenger — the "post-accept reconciliation" fix so a value
/// shown to the user as confirmed can still be visibly corrected rather
/// than silently swapped or frozen forever. The live scanner UI (Phase 7)
/// consumes this to drive the strikethrough/slide-in correction animation.
class FieldCorrection {
  const FieldCorrection({
    required this.field,
    required this.oldValue,
    required this.newValue,
    required this.reason,
    this.nutrientKey,
  });

  final LabelField field;
  final String oldValue;
  final String newValue;

  /// e.g. `'outvoted'`, `'cross-field: R1 expiry must be after MFG'`.
  final String reason;

  /// Set only when [field] is [LabelField.nutrition] — the specific
  /// nutrient key (e.g. `'energy'`), since a label can carry several
  /// independent nutrient readings and `field` alone can't distinguish
  /// them. Null for every other field.
  final String? nutrientKey;
}

/// Final payload handed back to the caller (expiry form / label-analysis
/// screen) when the user taps Accept & Save.
class LiveScanResult {
  const LiveScanResult({
    required this.transcript,
    this.expiryDate,
    this.mfgDate,
    this.batchNumber,
    this.skuOrProductId,
    this.nutrition = const {},
    this.fieldConfidence = const {},
  });

  final String transcript;
  final DateTime? expiryDate;
  final DateTime? mfgDate;
  final String? batchNumber;
  final String? skuOrProductId;

  /// Nutrient name (lowercase, e.g. "protein", "sodium") → value as printed
  /// (kept as a display string since units vary — "8g", "120mg", "350kcal").
  final Map<String, String> nutrition;

  /// Combined confidence per field at the moment of accept, so the caller
  /// (e.g. the expiry form) can still flag "this was accepted at 55%
  /// confidence" even after the scanner screen is gone.
  final Map<LabelField, double> fieldConfidence;
}

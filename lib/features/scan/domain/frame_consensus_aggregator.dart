// Multi-frame consensus aggregator.
//
// This is the piece that actually fixes "the app trusts a single OCR read."
// Every processed camera frame produces zero or more field candidates
// (label_field_extractor.dart); this class keeps a rolling window of recent
// candidates per field and only marks a field "confirmed" once enough
// recent frames independently agree on the same value. A field that only
// ever appeared once, or that keeps flip-flopping between different reads,
// never confirms — the UI is expected to show that honestly (low
// confidence / keep scanning) rather than silently picking whichever
// frame happened to be read most recently.
//
// Deliberately plain Dart (no Flutter import) so this is unit-testable with
// synthetic frame sequences, independent of any real camera or ML Kit call.

import 'label_field_models.dart';

/// Tuning constants. Kept together so the accuracy/speed trade-off is one
/// place to adjust, not scattered through the aggregation logic.
class ConsensusConfig {
  const ConsensusConfig({
    this.windowSize = 8,
    this.requiredAgreement = 3,
    this.confirmThreshold = 0.6,
  });

  /// How many of the most recent observations for a field are kept.
  final int windowSize;

  /// How many of those observations must agree before a field can confirm.
  final int requiredAgreement;

  /// Minimum combined (pattern-confidence × agreement) score to confirm,
  /// even if [requiredAgreement] is met — a low-confidence pattern that
  /// happens to repeat 3 times (e.g. a badly-OCR'd bare date) still isn't
  /// necessarily correct, so agreement count alone is not sufficient.
  final double confirmThreshold;
}

class _Observation {
  const _Observation({
    required this.value,
    required this.raw,
    required this.confidence,
    this.derivedFrom,
  });

  final String value;
  final String raw;
  final double confidence;
  final String? derivedFrom;
}

class FrameConsensusAggregator {
  FrameConsensusAggregator({ConsensusConfig config = const ConsensusConfig()})
      : _config = config;

  final ConsensusConfig _config;

  /// Key: LabelField.name for scalar fields, "nutrition.NUTRIENT" for each
  /// nutrient — one generic windowing mechanism serves both.
  final Map<String, List<_Observation>> _windows = {};

  int _framesProcessed = 0;
  int get framesProcessed => _framesProcessed;

  /// Feeds one frame's extracted candidates into the rolling windows.
  void addFrame(LabelFieldCandidates candidates) {
    _framesProcessed++;
    for (final entry in candidates.byField.entries) {
      final field = entry.key;
      final candidate = entry.value;
      if (field == LabelField.nutrition) {
        _addNutritionFrame(candidate.value);
        continue;
      }
      _push(
        field.name,
        _Observation(
          value: candidate.value,
          raw: candidate.raw,
          confidence: candidate.confidence,
          derivedFrom: candidate.derivedFrom,
        ),
      );
    }
  }

  void _addNutritionFrame(String encoded) {
    for (final pair in encoded.split(';')) {
      final idx = pair.indexOf('=');
      if (idx < 0) continue;
      final nutrient = pair.substring(0, idx);
      final value = pair.substring(idx + 1);
      _push(
        'nutrition.$nutrient',
        _Observation(value: value, raw: '$nutrient: $value', confidence: 0.75),
      );
    }
  }

  void _push(String key, _Observation observation) {
    final window = _windows.putIfAbsent(key, () => []);
    window.add(observation);
    if (window.length > _config.windowSize) {
      window.removeAt(0);
    }
  }

  /// Consensus status for one of the four scalar fields (not nutrition —
  /// use [nutritionStatus] for that, since a label can carry several
  /// independent nutrient readings at once).
  FieldConsensus fieldStatus(LabelField field) {
    assert(field != LabelField.nutrition, 'use nutritionStatus() instead');
    return _consensusFor(field, field.name);
  }

  /// Per-nutrient consensus for every nutrient observed at least once so
  /// far. A nutrient absent from every frame never appears here — the
  /// scanner UI only renders cards for nutrients actually printed on the
  /// label, not a fixed checklist of every nutrient it knows how to read.
  Map<String, FieldConsensus> nutritionStatus() {
    final result = <String, FieldConsensus>{};
    for (final key in _windows.keys) {
      if (!key.startsWith('nutrition.')) continue;
      final nutrient = key.substring('nutrition.'.length);
      result[nutrient] = _consensusFor(LabelField.nutrition, key);
    }
    return result;
  }

  FieldConsensus _consensusFor(LabelField field, String key) {
    final window = _windows[key];
    if (window == null || window.isEmpty) {
      return FieldConsensus(
        field: field,
        leadingValue: null,
        leadingRaw: null,
        agreementCount: 0,
        windowSize: 0,
        combinedConfidence: 0,
        confirmed: false,
      );
    }

    // Tally agreement by value, keep the most-agreed-upon one. Ties break
    // toward the most recently seen value, since a run of newer frames
    // outweighing an equal but stale count is the more useful default when
    // the user has re-framed the label.
    final counts = <String, int>{};
    final confidenceSum = <String, double>{};
    final lastRaw = <String, String>{};
    final lastDerivedFrom = <String, String?>{};
    for (final obs in window) {
      counts[obs.value] = (counts[obs.value] ?? 0) + 1;
      confidenceSum[obs.value] = (confidenceSum[obs.value] ?? 0) + obs.confidence;
      lastRaw[obs.value] = obs.raw;
      lastDerivedFrom[obs.value] = obs.derivedFrom;
    }

    String leadingValue = window.last.value;
    var leadingCount = counts[leadingValue] ?? 0;
    for (final entry in counts.entries) {
      if (entry.value > leadingCount) {
        leadingValue = entry.key;
        leadingCount = entry.value;
      }
    }

    final avgConfidence = confidenceSum[leadingValue]! / leadingCount;
    final agreementRatio =
        (leadingCount / _config.requiredAgreement).clamp(0.0, 1.0);
    final combined = (avgConfidence * agreementRatio).clamp(0.0, 1.0);
    final confirmed = leadingCount >= _config.requiredAgreement &&
        combined >= _config.confirmThreshold;

    return FieldConsensus(
      field: field,
      leadingValue: leadingValue,
      leadingRaw: lastRaw[leadingValue],
      agreementCount: leadingCount,
      windowSize: window.length,
      combinedConfidence: combined,
      confirmed: confirmed,
      derivedFrom: lastDerivedFrom[leadingValue],
    );
  }

  /// Clears all accumulated state — used by the scanner's Rescan action so
  /// a fresh scan never carries over a stale consensus from a previous,
  /// possibly different, label.
  void reset() {
    _windows.clear();
    _framesProcessed = 0;
  }
}

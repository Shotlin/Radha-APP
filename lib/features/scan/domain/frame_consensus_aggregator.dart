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
// Three additional guarantees on top of that (Phase 6 / spec §A2):
//   - Fuzzy vote clustering: two frames reading "2026-03-15" and
//     "2026-03-16" (one bad OCR digit) no longer split into two 1-vote
//     buckets that both fail to confirm — they pool into one cluster.
//   - Cross-field validation: an expiry that isn't after its own MFG date,
//     or a date that's implausibly far from today, gets demoted rather
//     than silently accepted (see cross_field_validator.dart).
//   - Post-accept reconciliation ("freeze at Accept" fix): once a field
//     has confirmed, a couple of stray contrary frames can't flip it —
//     only a genuinely stronger, sustained challenger can, and doing so
//     emits a FieldCorrection so the UI can show the swap instead of
//     silently changing the value under the user.
//
// Deliberately plain Dart (no Flutter import) so this is unit-testable with
// synthetic frame sequences, independent of any real camera or ML Kit call.

import 'cross_field_validator.dart';
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

/// Two-row DP Levenshtein (edit) distance between [a] and [b]. Local
/// implementation — no package dependency, ~15 lines is not worth a pub
/// import for.
int levenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  var prev = List<int>.generate(b.length + 1, (i) => i);
  var curr = List<int>.filled(b.length + 1, 0);

  for (var i = 1; i <= a.length; i++) {
    curr[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      final deletion = prev[j] + 1;
      final insertion = curr[j - 1] + 1;
      final substitution = prev[j - 1] + cost;
      curr[j] = deletion < insertion
          ? (deletion < substitution ? deletion : substitution)
          : (insertion < substitution ? insertion : substitution);
    }
    final tmp = prev;
    prev = curr;
    curr = tmp;
  }
  return prev[b.length];
}

/// Per-distinct-value tally within one field's window — the pre-clustering
/// step (identical to what a plain exact-match aggregator would compute).
class _ExactGroup {
  int votes = 0;
  double confidenceSum = 0;
  String raw = '';
  String? derivedFrom;
}

/// A group of distinct values whose canonical forms are all within edit
/// distance 1 of the cluster's anchor — the fuzzy-vote-clustering fix for
/// exact-string vote fragmentation (spec §A2.1). Votes and confidence pool
/// across every member; the *displayed* value is whichever member has the
/// highest individual cumulative confidence, not necessarily the plurality
/// vote-getter (a single very-high-confidence EXP-prefixed read should
/// still win display over several low-confidence bare-date reads even if
/// there happen to be more of the latter).
class _Cluster {
  _Cluster({required this.canonical});

  final String canonical;
  final List<String> memberValues = [];
  final Map<String, int> _votes = {};
  final Map<String, double> _confidenceSum = {};
  final Map<String, String> _raw = {};
  final Map<String, String?> _derivedFrom = {};

  void addMember(String value, _ExactGroup group) {
    memberValues.add(value);
    _votes[value] = group.votes;
    _confidenceSum[value] = group.confidenceSum;
    _raw[value] = group.raw;
    _derivedFrom[value] = group.derivedFrom;
  }

  int get votes => _votes.values.fold(0, (a, b) => a + b);
  double get confidenceSum => _confidenceSum.values.fold(0.0, (a, b) => a + b);

  String get representative {
    var best = memberValues.first;
    var bestScore = _confidenceSum[best] ?? 0;
    for (final value in memberValues) {
      final score = _confidenceSum[value] ?? 0;
      if (score > bestScore) {
        best = value;
        bestScore = score;
      }
    }
    return best;
  }

  String get representativeRaw => _raw[representative]!;
  String? get representativeDerivedFrom => _derivedFrom[representative];
}

class _ScoredCluster {
  _ScoredCluster(this.cluster, this.combined);
  final _Cluster cluster;
  final double combined;
}

class FrameConsensusAggregator {
  FrameConsensusAggregator({ConsensusConfig config = const ConsensusConfig()})
      : _config = config;

  final ConsensusConfig _config;

  /// Key: LabelField.name for scalar fields, "nutrition.NUTRIENT" for each
  /// nutrient — one generic windowing mechanism serves both.
  final Map<String, List<_Observation>> _windows = {};

  /// The value last returned as `confirmed: true` for each key — the
  /// "post-accept reconciliation" memory that keeps a confirmed field from
  /// flipping on a couple of stray contrary frames (spec §A2.3).
  final Map<String, String> _confirmedIncumbent = {};

  /// Corrections recorded since the last [takeCorrections] drain.
  final List<FieldCorrection> _pendingCorrections = [];

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

  /// Drains and returns every [FieldCorrection] recorded since the last
  /// call — a confirmed field's leading value got swapped for a stronger
  /// challenger (post-accept reconciliation) or demoted by a cross-field
  /// rule and re-elected to a different runner-up. Intentionally a simple
  /// synchronous drain (matching the aggregator's existing
  /// read-after-ingest style) rather than a `Stream` — the caller is
  /// expected to poll this once per frame alongside `fieldStatus`.
  List<FieldCorrection> takeCorrections() {
    final result = List<FieldCorrection>.of(_pendingCorrections);
    _pendingCorrections.clear();
    return result;
  }

  String _canonicalForClustering(LabelField field, String value) {
    if (field == LabelField.expiryDate || field == LabelField.mfgDate) {
      return value.replaceAll(RegExp(r'[^0-9]'), '');
    }
    return value.toUpperCase();
  }

  /// Groups the window's observations by exact value, then greedily
  /// clusters those distinct values by canonical-form edit distance ≤ 1
  /// (first-fit: a value joins the first existing cluster within range,
  /// else starts a new one). First-fit is order-dependent for a
  /// three-or-more-way chain, but for this use case — OCR noise around one
  /// real value — collisions are always tight variants of a single true
  /// reading, so a full clustering algorithm isn't warranted.
  List<_Cluster> _buildClusters(LabelField field, List<_Observation> window) {
    final exact = <String, _ExactGroup>{};
    for (final obs in window) {
      final group = exact.putIfAbsent(obs.value, _ExactGroup.new);
      group.votes++;
      group.confidenceSum += obs.confidence;
      group.raw = obs.raw;
      group.derivedFrom = obs.derivedFrom;
    }

    final clusters = <_Cluster>[];
    for (final entry in exact.entries) {
      final canonical = _canonicalForClustering(field, entry.key);
      _Cluster? target;
      for (final cluster in clusters) {
        if (levenshtein(canonical, cluster.canonical) <= 1) {
          target = cluster;
          break;
        }
      }
      target ??= _Cluster(canonical: canonical);
      if (!clusters.contains(target)) clusters.add(target);
      target.addMember(entry.key, entry.value);
    }
    return clusters;
  }

  double _score(_Cluster cluster) {
    if (cluster.votes == 0) return 0;
    final avgConfidence = cluster.confidenceSum / cluster.votes;
    final agreementRatio =
        (cluster.votes / _config.requiredAgreement).clamp(0.0, 1.0);
    return (avgConfidence * agreementRatio).clamp(0.0, 1.0);
  }

  _ScoredCluster? _findByValue(List<_ScoredCluster> scored, String value) {
    for (final s in scored) {
      if (s.cluster.memberValues.contains(value)) return s;
    }
    return null;
  }

  /// Builds this field's ranked cluster list and applies incumbent
  /// stickiness (spec §A2.3) to pick the leader — shared by
  /// [_consensusFor] (for the field itself) and, read-only, as the "other
  /// field's current value" input when cross-validating expiry against
  /// MFG (avoids recursing cross-field validation into itself). Returns
  /// both the ranked list and the chosen leader so callers that need to
  /// re-elect a runner-up (cross-field demotion) can exclude the exact
  /// same cluster object the leader came from.
  ({List<_ScoredCluster> scored, _ScoredCluster chosen})? _rankedFor(
    LabelField field,
    String key,
  ) {
    final window = _windows[key];
    if (window == null || window.isEmpty) return null;

    final clusters = _buildClusters(field, window);
    if (clusters.isEmpty) return null;
    final scored = clusters.map((c) => _ScoredCluster(c, _score(c))).toList()
      ..sort((a, b) => b.combined.compareTo(a.combined));

    var chosen = scored.first;
    final incumbentValue = _confirmedIncumbent[key];
    if (incumbentValue != null) {
      final incumbentScored = _findByValue(scored, incumbentValue);
      if (incumbentScored == null) {
        _confirmedIncumbent.remove(key);
      } else if (chosen.cluster.representative != incumbentValue) {
        final challenger = chosen;
        final strongEnough =
            challenger.combined >= incumbentScored.combined + 0.15 &&
                challenger.cluster.votes >= 5;
        if (strongEnough) {
          _pendingCorrections.add(FieldCorrection(
            field: field,
            oldValue: incumbentValue,
            newValue: challenger.cluster.representative,
            reason: 'outvoted',
            nutrientKey: field == LabelField.nutrition
                ? key.substring('nutrition.'.length)
                : null,
          ));
          _confirmedIncumbent[key] = challenger.cluster.representative;
        } else {
          chosen = incumbentScored;
        }
      } else {
        chosen = incumbentScored;
      }
    }
    return (scored: scored, chosen: chosen);
  }

  FieldConsensus _consensusFor(LabelField field, String key) {
    final ranked = _rankedFor(field, key);
    if (ranked == null) {
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
    final window = _windows[key]!;
    final scored = ranked.scored;
    final chosen = ranked.chosen;

    var leadingValue = chosen.cluster.representative;
    var leadingRaw = chosen.cluster.representativeRaw;
    var leadingDerivedFrom = chosen.cluster.representativeDerivedFrom;
    var agreementCount = chosen.cluster.votes;
    var combined = chosen.combined;
    var confirmed = agreementCount >= _config.requiredAgreement &&
        combined >= _config.confirmThreshold;

    if (confirmed) {
      _confirmedIncumbent[key] = leadingValue;
    }

    // Cross-field validation only applies to expiry/MFG — batch/SKU/
    // nutrition have no counterpart to validate against.
    if (confirmed &&
        (field == LabelField.expiryDate || field == LabelField.mfgDate)) {
      final otherField =
          field == LabelField.expiryDate ? LabelField.mfgDate : LabelField.expiryDate;
      final otherRanked = _rankedFor(otherField, otherField.name);
      final otherDate = otherRanked == null
          ? null
          : DateTime.tryParse(otherRanked.chosen.cluster.representative);
      final thisDate = DateTime.tryParse(leadingValue);

      final expiry = field == LabelField.expiryDate ? thisDate : otherDate;
      final mfg = field == LabelField.mfgDate ? thisDate : otherDate;
      final verdict = checkExpiryMfg(expiry: expiry, mfg: mfg);

      if (verdict != null && verdict.demoteField == field) {
        final demotedValue = leadingValue;
        combined = (combined * 0.5).clamp(0.0, 1.0);
        confirmed = agreementCount >= _config.requiredAgreement &&
            combined >= _config.confirmThreshold;

        if (!confirmed) {
          _ScoredCluster? runnerUp;
          for (final s in scored) {
            if (identical(s.cluster, chosen.cluster)) continue;
            if (s.cluster.votes >= _config.requiredAgreement &&
                s.combined >= _config.confirmThreshold) {
              runnerUp = s;
              break;
            }
          }
          if (runnerUp != null) {
            leadingValue = runnerUp.cluster.representative;
            leadingRaw = runnerUp.cluster.representativeRaw;
            leadingDerivedFrom = runnerUp.cluster.representativeDerivedFrom;
            agreementCount = runnerUp.cluster.votes;
            combined = runnerUp.combined;
            confirmed = true;
            _confirmedIncumbent[key] = leadingValue;
            _pendingCorrections.add(FieldCorrection(
              field: field,
              oldValue: demotedValue,
              newValue: leadingValue,
              reason: verdict.reason,
            ));
          } else {
            _confirmedIncumbent.remove(key);
          }
        }
      }
    }

    return FieldConsensus(
      field: field,
      leadingValue: leadingValue,
      leadingRaw: leadingRaw,
      agreementCount: agreementCount,
      windowSize: window.length,
      combinedConfidence: combined,
      confirmed: confirmed,
      derivedFrom: leadingDerivedFrom,
    );
  }

  /// Clears all accumulated state — used by the scanner's Rescan action so
  /// a fresh scan never carries over a stale consensus from a previous,
  /// possibly different, label.
  void reset() {
    _windows.clear();
    _confirmedIncumbent.clear();
    _pendingCorrections.clear();
    _framesProcessed = 0;
  }
}

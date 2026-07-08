// Cross-field date-plausibility rules for the live label scanner.
//
// Pure Dart, zero dependency on the extractor or aggregator — takes the
// current leading expiry/MFG dates in, returns a verdict out. This encodes
// the human rule founders' feedback called out explicitly: on an Indian
// pack, whichever date is EARLIER is the manufacturing date and whichever
// is LATER is the expiry date, even when the printed keywords are misread
// or missing. The aggregator (frame_consensus_aggregator.dart) is the one
// caller — it owns the mutable cluster state needed to actually demote and
// re-elect a field's leading value; this file only decides WHETHER a
// demotion should happen and WHY.

import 'label_field_models.dart';

/// A cross-field rule fired: which field should be demoted, and the reason
/// string surfaced verbatim in the live scanner's "corrected" badge.
class CrossFieldVerdict {
  const CrossFieldVerdict({required this.demoteField, required this.reason});

  final LabelField demoteField;
  final String reason;
}

/// Checks the current leading expiry/MFG dates against the plausibility
/// rules below. Returns `null` when no rule fires (including when either
/// date is absent — a rule that needs both present simply can't evaluate).
///
/// - **R1** `expiry > mfg` (when both present) — an expiry on or before its
///   own manufacturing date is never valid.
/// - **R2** `mfg <= today + 31 days` — a manufacturing date can't be more
///   than a month in the future (a small grace window absorbs clock skew
///   and pre-printed near-future batches without disallowing genuinely
///   recent OCR reads).
/// - **R3** `expiry in [today - 1y, today + 5y]` — outside this range the
///   read is almost certainly a misparsed digit rather than a real shelf
///   life (Indian packaged-food expiries essentially never exceed 5 years).
///
/// R4 (shelf-life-derived vs. explicit expiry tolerance) is intentionally
/// NOT implemented here — see `PLANS/phases/PHASE_06_feature_a_consensus.md`
/// §"Out of scope" for why it needs a different data shape than this
/// single-leading-value-per-field check can provide.
CrossFieldVerdict? checkExpiryMfg({
  DateTime? expiry,
  DateTime? mfg,
  DateTime? now,
}) {
  final today = now ?? DateTime.now();

  if (expiry != null && mfg != null && !expiry.isAfter(mfg)) {
    // Both fields are implicated; the aggregator decides which of the two
    // has the weaker current score to actually demote (see its doc
    // comment) — report against expiry here since that's the field this
    // violation is named for, and the aggregator re-checks both sides.
    return const CrossFieldVerdict(
      demoteField: LabelField.expiryDate,
      reason: 'cross-field: R1 expiry must be after MFG',
    );
  }

  if (mfg != null && mfg.isAfter(today.add(const Duration(days: 31)))) {
    return const CrossFieldVerdict(
      demoteField: LabelField.mfgDate,
      reason: 'cross-field: R2 MFG date too far in the future',
    );
  }

  if (expiry != null) {
    final earliest = today.subtract(const Duration(days: 365));
    final latest = today.add(const Duration(days: 365 * 5));
    if (expiry.isBefore(earliest) || expiry.isAfter(latest)) {
      return const CrossFieldVerdict(
        demoteField: LabelField.expiryDate,
        reason: 'cross-field: R3 expiry date implausibly far from today',
      );
    }
  }

  return null;
}

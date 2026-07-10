// Combines the cloud vision-native photo analysis (Gemini, reads the whole
// label image directly) with whatever the on-device live scan already
// found, per field. Pure Dart, no Flutter/network dependency — takes plain
// values in, returns a decision out — same testability discipline as
// label_field_extractor.dart / product_name_extractor.dart.
//
// Decision rule, per field:
//   - Live side has nothing confirmed yet -> cloud wins outright, no
//     disagreement to show (the common case: cloud typically finishes
//     while the user is still a step or two into the on-device scan).
//   - Both sides agree (exact for text within a small edit-distance
//     tolerance; within a small relative tolerance for numbers) -> agreed,
//     safe to auto-fill with high confidence.
//   - Both sides are confident and diverge beyond tolerance -> disagreement
//     — never silently pick one; the caller must show both and let the
//     user choose.
import 'dart:math' as math;

import 'frame_consensus_aggregator.dart' show levenshtein;

enum MergeStatus {
  /// Cloud produced a value, live had nothing confirmed to compare against.
  cloudOnly,

  /// Cloud and live agree (within tolerance).
  agreed,

  /// Both sides are confident but disagree — caller must let the user pick.
  disagreement,

  /// Neither side produced anything.
  none,
}

class MergeResult<T> {
  const MergeResult({required this.status, this.value, this.cloudValue, this.liveValue});

  final MergeStatus status;

  /// The value to use — populated for [MergeStatus.cloudOnly] and
  /// [MergeStatus.agreed]. Null for [MergeStatus.disagreement] (caller must
  /// resolve) and [MergeStatus.none].
  final T? value;

  /// Always populated when a disagreement is reported, so the UI can show
  /// both candidates.
  final T? cloudValue;
  final T? liveValue;
}

class LabelSourceMerger {
  LabelSourceMerger._();

  /// Text fields (product name, etc.) — fuzzy string comparison. Tolerance
  /// scales with length, same rule used for the live name-streak fuzzy
  /// match (contribute_product_screen.dart), so a trivial OCR-vs-vision
  /// spelling difference doesn't read as a real disagreement.
  static MergeResult<String> mergeText({
    required String? cloudValue,
    required String? liveValue,
    required bool liveConfirmed,
  }) {
    final cloud = _clean(cloudValue);
    final live = _clean(liveValue);

    if (cloud == null && live == null) {
      return const MergeResult(status: MergeStatus.none);
    }
    if (cloud != null && (!liveConfirmed || live == null)) {
      return MergeResult(status: MergeStatus.cloudOnly, value: cloud);
    }
    if (cloud == null) {
      // Cloud produced nothing but live has a confirmed value — treat the
      // live reading as already-settled; nothing new to merge in.
      return MergeResult(status: MergeStatus.agreed, value: live);
    }

    final tolerance = (cloud.length * 0.15).ceil().clamp(1, 6);
    if (levenshtein(cloud, live!) <= tolerance) {
      // Prefer the more complete reading, same "longer wins" rule used
      // elsewhere in this codebase for OCR truncation.
      final winner = cloud.length >= live.length ? cloud : live;
      return MergeResult(status: MergeStatus.agreed, value: winner);
    }
    return MergeResult(
      status: MergeStatus.disagreement,
      cloudValue: cloud,
      liveValue: live,
    );
  }

  /// Numeric fields (nutrition values) — relative-tolerance comparison so
  /// OCR/LLM rounding differences ("11.5" vs "11.4") don't read as a real
  /// disagreement.
  static MergeResult<double> mergeNumber({
    required double? cloudValue,
    required double? liveValue,
    required bool liveConfirmed,
    double toleranceRatio = 0.08,
  }) {
    if (cloudValue == null && liveValue == null) {
      return const MergeResult(status: MergeStatus.none);
    }
    if (cloudValue != null && (!liveConfirmed || liveValue == null)) {
      return MergeResult(status: MergeStatus.cloudOnly, value: cloudValue);
    }
    if (cloudValue == null) {
      return MergeResult(status: MergeStatus.agreed, value: liveValue);
    }

    final scale = math.max(cloudValue.abs(), liveValue!.abs());
    final diff = (cloudValue - liveValue).abs();
    final withinTolerance = scale == 0 ? diff == 0 : diff / scale <= toleranceRatio;
    if (withinTolerance) {
      return MergeResult(status: MergeStatus.agreed, value: cloudValue);
    }
    return MergeResult(
      status: MergeStatus.disagreement,
      cloudValue: cloudValue,
      liveValue: liveValue,
    );
  }

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}

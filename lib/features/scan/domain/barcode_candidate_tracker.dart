/// Multi-frame hysteresis tracker for the single-scan barcode path.
///
/// A checksum-valid single frame is not enough to trust — a barcode's own
/// check digit only catches ~90% of single-digit misreads and misses some
/// substitution patterns entirely (see `scan_screen.dart`'s
/// `_kRequiredAgreement` doc for the real production incident that proved
/// this). Several independent frames need to agree on the exact same
/// digits before a read is trusted.
///
/// The naive way to enforce that — reset the streak to 1 the instant a
/// differently-valued frame arrives — has a real failure mode: a single
/// stray misread (autofocus hunt, motion blur, glare) right before the
/// streak would have confirmed throws away all prior progress, and the
/// user watches the displayed number flip and the count restart from
/// scratch, often repeatedly. This tracker decays an in-progress candidate
/// by one step on a mismatch instead of discarding it outright, so one bad
/// frame can no longer erase two good ones. A candidate with no real
/// progress yet (streak of 1) is still replaced immediately, so pointing
/// at a genuinely different item is not sluggish to pick up.
///
/// Once [confirmed] is reached, the tracker freezes completely — every
/// further [addRead] is a no-op, matching or not — until [reset]. The
/// camera keeps running after confirmation while the user decides whether
/// to tap Proceed, and a phone that's shaken or bumped in that window will
/// throw a run of garbage frames at the tracker; without this freeze, the
/// decay above would still eventually erode a confirmed streak back below
/// [requiredAgreement] and let a stray misread take over an already-
/// trusted result — the exact regression a real scan session on I2217
/// hit (2026-08-21): confirmed on the correct code, then flipped to a
/// wrong one after a few seconds of handheld camera shake.
///
/// Deliberately plain Dart (no Flutter import) so this is unit-testable
/// with synthetic read sequences, independent of the camera/mobile_scanner.
class BarcodeCandidateTracker {
  BarcodeCandidateTracker({required this.requiredAgreement})
      : assert(requiredAgreement > 0);

  final int requiredAgreement;

  String? _code;
  int _streak = 0;

  /// The current leading candidate, or null if nothing has been read yet.
  String? get code => _code;

  /// How many frames of agreement the current candidate has accrued.
  int get streak => _streak;

  /// Whether [code] has accrued enough agreement to be trusted.
  bool get confirmed => _streak >= requiredAgreement;

  /// Feeds one frame's checksum-valid read. Returns true if [code] or
  /// [streak] changed as a result (i.e. the caller should re-render).
  bool addRead(String code) {
    // Frozen: a confirmed result is terminal until reset() (Proceed /
    // leaving the view) — no further frame, agreeing or not, may touch it.
    if (confirmed) return false;

    if (code == _code) {
      _streak++;
      return true;
    }

    // A different code than the current candidate. Protect real progress
    // (streak > 1) by decaying it one step rather than discarding it — only
    // take over once the incumbent has no progress left to protect.
    if (_code != null && _streak > 1) {
      _streak--;
      return true;
    }

    _code = code;
    _streak = 1;
    return true;
  }

  /// Clears all state — used when leaving the candidate view (Proceed,
  /// toggling batch mode) so a fresh scan never carries over a stale
  /// candidate.
  void reset() {
    _code = null;
    _streak = 0;
  }
}

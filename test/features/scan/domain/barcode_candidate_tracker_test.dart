import 'package:flutter_test/flutter_test.dart';
import 'package:radha_app/features/scan/domain/barcode_candidate_tracker.dart';

void main() {
  group('single-frame trust is refused', () {
    test('one read never confirms, no matter how confident', () {
      final tracker = BarcodeCandidateTracker(requiredAgreement: 3);
      tracker.addRead('7622202225512');

      expect(tracker.code, '7622202225512');
      expect(tracker.streak, 1);
      expect(tracker.confirmed, isFalse);
    });
  });

  group('clean agreement', () {
    test('confirms after requiredAgreement identical reads', () {
      final tracker = BarcodeCandidateTracker(requiredAgreement: 3);
      tracker.addRead('123');
      tracker.addRead('123');
      expect(tracker.confirmed, isFalse);
      tracker.addRead('123');
      expect(tracker.confirmed, isTrue);
      expect(tracker.streak, 3);
    });

    test('freezes once confirmed instead of over-counting', () {
      final tracker = BarcodeCandidateTracker(requiredAgreement: 3);
      for (var i = 0; i < 6; i++) {
        tracker.addRead('123');
      }
      expect(tracker.streak, 3);
      expect(tracker.confirmed, isTrue);
    });

    test(
        'a confirmed candidate is immune to mismatched reads afterward '
        '(I2217 field regression, 2026-08-21)', () {
      // Real device repro: confirmed on 8901764032912 ("Verified — ready to
      // proceed"), then the phone was shaken while still pointed roughly at
      // the pack before Proceed was tapped. The resulting run of blurry
      // frames must never un-confirm the result or hand it over to a
      // misread — once green, it stays green until reset().
      final tracker = BarcodeCandidateTracker(requiredAgreement: 3);
      tracker.addRead('8901764032912');
      tracker.addRead('8901764032912');
      tracker.addRead('8901764032912');
      expect(tracker.confirmed, isTrue);

      for (final stray in ['3948764032912', '8901764032911', '0000000000000']) {
        final changed = tracker.addRead(stray);
        expect(changed, isFalse, reason: 'confirmed tracker must ignore further reads');
      }

      expect(tracker.code, '8901764032912');
      expect(tracker.streak, 3);
      expect(tracker.confirmed, isTrue);
    });
  });

  group('a single stray misread does not wipe out real progress', () {
    test('two good reads survive one bad read in between', () {
      // This is the exact production complaint: the candidate was on its
      // way to confirming and a single bad frame reset it back to square
      // one, over and over. Two agreeing reads followed by one stray
      // followed by two more agreeing reads should still confirm — and
      // critically, the *displayed* candidate should never flip to the
      // stray value along the way.
      final tracker = BarcodeCandidateTracker(requiredAgreement: 3);

      tracker.addRead('7622202225512'); // streak 1
      tracker.addRead('7622202225512'); // streak 2
      tracker.addRead('1608062225578'); // stray misread — decays, not reset
      expect(tracker.code, '7622202225512', reason: 'must not flip on a single stray frame');
      expect(tracker.streak, 1);
      expect(tracker.confirmed, isFalse);

      tracker.addRead('7622202225512'); // streak 2 again
      tracker.addRead('7622202225512'); // streak 3 -> confirmed
      expect(tracker.code, '7622202225512');
      expect(tracker.confirmed, isTrue);
    });

    test('a stray read never itself confirms from a single occurrence', () {
      final tracker = BarcodeCandidateTracker(requiredAgreement: 3);
      tracker.addRead('123');
      tracker.addRead('123');
      tracker.addRead('999');
      expect(tracker.code, '123');
      expect(tracker.confirmed, isFalse);
    });
  });

  group('genuinely switching targets', () {
    test('a fresh candidate (streak 1) is replaced immediately', () {
      final tracker = BarcodeCandidateTracker(requiredAgreement: 3);
      tracker.addRead('123');
      expect(tracker.code, '123');
      tracker.addRead('456');
      expect(tracker.code, '456', reason: 'no progress to protect at streak 1');
      expect(tracker.streak, 1);
    });

    test('sustained reads of a new item eventually take over', () {
      final tracker = BarcodeCandidateTracker(requiredAgreement: 3);
      tracker.addRead('123');
      tracker.addRead('123'); // streak 2

      // New item held in front of the camera instead.
      tracker.addRead('456'); // decays old streak to 1
      tracker.addRead('456'); // old streak was 1 -> switches now
      expect(tracker.code, '456');
      tracker.addRead('456');
      tracker.addRead('456');
      expect(tracker.confirmed, isTrue);
    });
  });

  group('addRead return value', () {
    test('reports whether anything changed, for setState gating', () {
      final tracker = BarcodeCandidateTracker(requiredAgreement: 2);
      expect(tracker.addRead('123'), isTrue);
      expect(tracker.addRead('123'), isTrue); // streak 2 -> confirmed
      expect(tracker.addRead('123'), isFalse, reason: 'frozen once confirmed');
    });
  });

  group('reset', () {
    test('clears code, streak, and confirmed', () {
      final tracker = BarcodeCandidateTracker(requiredAgreement: 2);
      tracker.addRead('123');
      tracker.addRead('123');
      expect(tracker.confirmed, isTrue);

      tracker.reset();
      expect(tracker.code, isNull);
      expect(tracker.streak, 0);
      expect(tracker.confirmed, isFalse);
    });
  });
}

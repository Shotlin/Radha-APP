import 'package:flutter_test/flutter_test.dart';
import 'package:radha_app/features/scan/domain/frame_consensus_aggregator.dart';
import 'package:radha_app/features/scan/domain/label_field_models.dart';

LabelFieldCandidates _frame(
  LabelField field,
  String value, {
  double confidence = 0.9,
  String? raw,
}) {
  return LabelFieldCandidates(
    transcript: raw ?? value,
    byField: {
      field: FieldCandidate(
        field: field,
        value: value,
        raw: raw ?? value,
        confidence: confidence,
      ),
    },
  );
}

void main() {
  group('single-frame trust is refused', () {
    test('one single frame never confirms, no matter how confident', () {
      final agg = FrameConsensusAggregator();
      agg.addFrame(_frame(LabelField.expiryDate, '2026-03-15', confidence: 0.99));

      final status = agg.fieldStatus(LabelField.expiryDate);
      expect(status.confirmed, isFalse);
      expect(status.leadingValue, '2026-03-15');
      expect(status.hasAnyReading, isTrue);
    });

    test('a field with zero observations reports no reading, not a guess', () {
      final agg = FrameConsensusAggregator();
      agg.addFrame(_frame(LabelField.expiryDate, '2026-03-15'));

      final mfgStatus = agg.fieldStatus(LabelField.mfgDate);
      expect(mfgStatus.hasAnyReading, isFalse);
      expect(mfgStatus.confirmed, isFalse);
      expect(mfgStatus.leadingValue, isNull);
    });
  });

  group('agreement across frames confirms a field', () {
    test('confirms once required agreement + confidence threshold are met', () {
      final agg = FrameConsensusAggregator(
        config: const ConsensusConfig(
          windowSize: 8,
          requiredAgreement: 3,
          confirmThreshold: 0.6,
        ),
      );
      for (var i = 0; i < 3; i++) {
        agg.addFrame(
          _frame(LabelField.expiryDate, '2026-03-15', confidence: 0.9),
        );
      }
      final status = agg.fieldStatus(LabelField.expiryDate);
      expect(status.confirmed, isTrue);
      expect(status.agreementCount, 3);
      expect(status.combinedConfidence, greaterThanOrEqualTo(0.6));
    });

    test('does not confirm below the required agreement count', () {
      final agg = FrameConsensusAggregator(
        config: const ConsensusConfig(requiredAgreement: 3),
      );
      agg.addFrame(_frame(LabelField.expiryDate, '2026-03-15'));
      agg.addFrame(_frame(LabelField.expiryDate, '2026-03-15'));

      final status = agg.fieldStatus(LabelField.expiryDate);
      expect(status.confirmed, isFalse);
      expect(status.agreementCount, 2);
    });

    test('low pattern confidence keeps a field unconfirmed even with agreement',
        () {
      final agg = FrameConsensusAggregator(
        config: const ConsensusConfig(
          requiredAgreement: 3,
          confirmThreshold: 0.6,
        ),
      );
      // Confidence 0.3 repeated 3x -> combined well below the 0.6 threshold.
      for (var i = 0; i < 3; i++) {
        agg.addFrame(
          _frame(LabelField.expiryDate, '2026-03-15', confidence: 0.3),
        );
      }
      final status = agg.fieldStatus(LabelField.expiryDate);
      expect(status.confirmed, isFalse);
    });
  });

  group('conflicting frames never silently pick a winner without agreement',
      () {
    test('alternating values never reach the required agreement count', () {
      final agg = FrameConsensusAggregator(
        config: const ConsensusConfig(windowSize: 8, requiredAgreement: 3),
      );
      agg.addFrame(_frame(LabelField.expiryDate, '2026-03-15'));
      agg.addFrame(_frame(LabelField.expiryDate, '2026-04-20'));
      agg.addFrame(_frame(LabelField.expiryDate, '2026-05-01'));
      agg.addFrame(_frame(LabelField.expiryDate, '2026-06-11'));

      final status = agg.fieldStatus(LabelField.expiryDate);
      expect(status.confirmed, isFalse);
      expect(status.agreementCount, 1);
    });

    test('a late majority still confirms once enough frames agree', () {
      final agg = FrameConsensusAggregator(
        config: const ConsensusConfig(windowSize: 8, requiredAgreement: 3),
      );
      agg.addFrame(_frame(LabelField.expiryDate, '2026-01-01', confidence: 0.7));
      agg.addFrame(_frame(LabelField.expiryDate, '2026-03-15', confidence: 0.9));
      agg.addFrame(_frame(LabelField.expiryDate, '2026-03-15', confidence: 0.9));
      agg.addFrame(_frame(LabelField.expiryDate, '2026-03-15', confidence: 0.9));

      final status = agg.fieldStatus(LabelField.expiryDate);
      expect(status.confirmed, isTrue);
      expect(status.leadingValue, '2026-03-15');
    });
  });

  group('rolling window forgets stale readings', () {
    test('an old value falls out of the window and stops counting', () {
      final agg = FrameConsensusAggregator(
        config: const ConsensusConfig(windowSize: 3, requiredAgreement: 3),
      );
      agg.addFrame(_frame(LabelField.expiryDate, '2026-01-01'));
      agg.addFrame(_frame(LabelField.expiryDate, '2026-01-01'));
      // Pushes the two 2026-01-01 reads mostly out as new value dominates.
      agg.addFrame(_frame(LabelField.expiryDate, '2026-03-15'));
      agg.addFrame(_frame(LabelField.expiryDate, '2026-03-15'));
      agg.addFrame(_frame(LabelField.expiryDate, '2026-03-15'));

      final status = agg.fieldStatus(LabelField.expiryDate);
      expect(status.leadingValue, '2026-03-15');
      expect(status.confirmed, isTrue);
    });
  });

  group('reset clears state for a fresh rescan', () {
    test('after reset, no prior confirmation leaks into the next scan', () {
      final agg = FrameConsensusAggregator();
      for (var i = 0; i < 5; i++) {
        agg.addFrame(_frame(LabelField.expiryDate, '2026-03-15'));
      }
      expect(agg.fieldStatus(LabelField.expiryDate).confirmed, isTrue);

      agg.reset();

      final status = agg.fieldStatus(LabelField.expiryDate);
      expect(status.hasAnyReading, isFalse);
      expect(status.confirmed, isFalse);
      expect(agg.framesProcessed, 0);
    });
  });

  group('nutrition: independent per-nutrient consensus', () {
    LabelFieldCandidates nutritionFrame(String encoded) {
      return LabelFieldCandidates(
        transcript: encoded,
        byField: {
          LabelField.nutrition: FieldCandidate(
            field: LabelField.nutrition,
            value: encoded,
            raw: encoded,
            confidence: 0.75,
          ),
        },
      );
    }

    test('each nutrient confirms independently once it repeats enough', () {
      final agg = FrameConsensusAggregator(
        config: const ConsensusConfig(requiredAgreement: 3),
      );
      agg.addFrame(nutritionFrame('protein=8g;sodium=120mg'));
      agg.addFrame(nutritionFrame('protein=8g'));
      agg.addFrame(nutritionFrame('protein=8g'));

      final statuses = agg.nutritionStatus();
      expect(statuses['protein']!.confirmed, isTrue);
      expect(statuses['protein']!.leadingValue, '8g');
      // Sodium only appeared once -> not confirmed.
      expect(statuses['sodium']!.confirmed, isFalse);
    });

    test('a nutrient never observed does not appear in the status map', () {
      final agg = FrameConsensusAggregator();
      agg.addFrame(nutritionFrame('protein=8g'));
      final statuses = agg.nutritionStatus();
      expect(statuses.containsKey('potassium'), isFalse);
    });
  });

  group('fuzzy vote clustering (spec A2.1)', () {
    test('a jittered single-digit misread pools into one cluster instead of fragmenting', () {
      final agg = FrameConsensusAggregator(
        config: const ConsensusConfig(requiredAgreement: 3),
      );
      // Without clustering this would be two 1-2-vote exact-match groups,
      // neither reaching requiredAgreement=3, so the field would never
      // confirm even though every frame agrees to within one OCR-noisy
      // digit.
      agg.addFrame(_frame(LabelField.expiryDate, '2026-03-15', confidence: 0.85));
      agg.addFrame(_frame(LabelField.expiryDate, '2026-03-16', confidence: 0.85));
      agg.addFrame(_frame(LabelField.expiryDate, '2026-03-15', confidence: 0.85));

      final status = agg.fieldStatus(LabelField.expiryDate);
      expect(status.confirmed, isTrue);
      expect(status.agreementCount, 3);
      // Representative = the exact value with the highest cumulative
      // confidence -- '15' appeared twice, '16' once.
      expect(status.leadingValue, '2026-03-15');
    });

    test('non-date fields (batch/SKU) cluster on distance <=1 too', () {
      final agg = FrameConsensusAggregator(
        config: const ConsensusConfig(requiredAgreement: 3),
      );
      agg.addFrame(_frame(LabelField.batchNumber, 'BC2201', confidence: 0.85));
      agg.addFrame(_frame(LabelField.batchNumber, 'BC2201', confidence: 0.85));
      agg.addFrame(_frame(LabelField.batchNumber, 'BC22O1', confidence: 0.7));

      final status = agg.fieldStatus(LabelField.batchNumber);
      expect(status.confirmed, isTrue);
      expect(status.agreementCount, 3);
      expect(status.leadingValue, 'BC2201');
    });

    test('genuinely distant values never cluster together', () {
      final agg = FrameConsensusAggregator(
        config: const ConsensusConfig(requiredAgreement: 3),
      );
      agg.addFrame(_frame(LabelField.expiryDate, '2026-03-15'));
      agg.addFrame(_frame(LabelField.expiryDate, '2026-09-20'));
      agg.addFrame(_frame(LabelField.expiryDate, '2026-03-15'));

      final status = agg.fieldStatus(LabelField.expiryDate);
      // '2026-03-15' has 2 votes, '2026-09-20' has 1 -- neither reaches
      // requiredAgreement=3 since they're too far apart to pool.
      expect(status.confirmed, isFalse);
    });
  });

  group('cross-field validation (spec A2.2)', () {
    test('an expiry before its own MFG date is demoted and reverts to unconfirmed with no runner-up', () {
      final agg = FrameConsensusAggregator();
      for (var i = 0; i < 3; i++) {
        agg.addFrame(_frame(LabelField.mfgDate, '2026-06-01', confidence: 0.9));
      }
      for (var i = 0; i < 3; i++) {
        agg.addFrame(_frame(LabelField.expiryDate, '2026-01-01', confidence: 0.9));
      }

      final mfgStatus = agg.fieldStatus(LabelField.mfgDate);
      expect(mfgStatus.confirmed, isTrue);

      final expiryStatus = agg.fieldStatus(LabelField.expiryDate);
      expect(expiryStatus.confirmed, isFalse);
      expect(expiryStatus.combinedConfidence, lessThan(0.9));
    });

    test('cross-field violation demotes an implausible expiry and re-elects a valid runner-up', () {
      final agg = FrameConsensusAggregator();
      for (var i = 0; i < 3; i++) {
        agg.addFrame(_frame(LabelField.mfgDate, '2026-06-01', confidence: 0.9));
      }
      // BAD: read more often and more confidently, so it's the natural
      // leader before cross-field validation steps in.
      for (var i = 0; i < 4; i++) {
        agg.addFrame(_frame(LabelField.expiryDate, '2026-01-01', confidence: 0.9));
      }
      // GOOD: fewer votes, slightly lower confidence, but plausible
      // (after MFG) -- the correct runner-up.
      for (var i = 0; i < 3; i++) {
        agg.addFrame(_frame(LabelField.expiryDate, '2026-08-15', confidence: 0.85));
      }

      final mfgStatus = agg.fieldStatus(LabelField.mfgDate);
      expect(mfgStatus.confirmed, isTrue);
      expect(mfgStatus.leadingValue, '2026-06-01');

      final expiryStatus = agg.fieldStatus(LabelField.expiryDate);
      final corrections = agg.takeCorrections();

      expect(expiryStatus.confirmed, isTrue);
      expect(expiryStatus.leadingValue, '2026-08-15');
      expect(corrections, hasLength(1));
      expect(corrections.single.oldValue, '2026-01-01');
      expect(corrections.single.newValue, '2026-08-15');
      expect(corrections.single.reason, contains('R1'));
    });

    test('a plausible expiry/MFG pair triggers no cross-field correction', () {
      final agg = FrameConsensusAggregator();
      for (var i = 0; i < 3; i++) {
        agg.addFrame(_frame(LabelField.mfgDate, '2026-06-01', confidence: 0.9));
      }
      for (var i = 0; i < 3; i++) {
        agg.addFrame(_frame(LabelField.expiryDate, '2026-12-01', confidence: 0.9));
      }
      agg.fieldStatus(LabelField.mfgDate);
      final expiryStatus = agg.fieldStatus(LabelField.expiryDate);
      expect(expiryStatus.confirmed, isTrue);
      expect(expiryStatus.leadingValue, '2026-12-01');
      expect(agg.takeCorrections(), isEmpty);
    });
  });

  group('post-accept reconciliation (spec A2.3) -- scripted replay', () {
    test('a wrong value confirms first, then a stronger sustained run replaces it with exactly one FieldCorrection', () {
      final agg = FrameConsensusAggregator();
      final allCorrections = <FieldCorrection>[];

      // First ~5 frames: wrong value, confirms and becomes the incumbent
      // (as if already shown to the user in an accept sheet).
      for (var i = 0; i < 5; i++) {
        agg.addFrame(_frame(LabelField.expiryDate, '2026-01-15', confidence: 0.85));
      }
      final afterWrong = agg.fieldStatus(LabelField.expiryDate);
      allCorrections.addAll(agg.takeCorrections());
      expect(afterWrong.confirmed, isTrue);
      expect(afterWrong.leadingValue, '2026-01-15');

      // Scanning continues (accept sheet still open): 6 more frames read
      // the actually-correct value. Polled every frame, mirroring how the
      // live scanner screen would call fieldStatus per recognized frame.
      for (var i = 0; i < 6; i++) {
        agg.addFrame(_frame(LabelField.expiryDate, '2026-09-20', confidence: 0.9));
        agg.fieldStatus(LabelField.expiryDate);
        allCorrections.addAll(agg.takeCorrections());
      }

      final finalStatus = agg.fieldStatus(LabelField.expiryDate);
      allCorrections.addAll(agg.takeCorrections());

      expect(finalStatus.confirmed, isTrue);
      expect(finalStatus.leadingValue, '2026-09-20');
      expect(allCorrections, hasLength(1));
      expect(allCorrections.single.oldValue, '2026-01-15');
      expect(allCorrections.single.newValue, '2026-09-20');
      expect(allCorrections.single.reason, 'outvoted');
    });

    test('a couple of stray contrary frames do not flip an already-confirmed value', () {
      final agg = FrameConsensusAggregator();
      for (var i = 0; i < 5; i++) {
        agg.addFrame(_frame(LabelField.batchNumber, 'BC2201', confidence: 0.85));
      }
      final confirmed = agg.fieldStatus(LabelField.batchNumber);
      expect(confirmed.confirmed, isTrue);
      agg.takeCorrections();

      // Two stray misreads -- not enough votes or margin to be a genuine
      // challenger (spec requires >=5 votes AND a +0.15 combined margin).
      agg.addFrame(_frame(LabelField.batchNumber, 'ZZ9999', confidence: 0.9));
      agg.addFrame(_frame(LabelField.batchNumber, 'ZZ9999', confidence: 0.9));

      final status = agg.fieldStatus(LabelField.batchNumber);
      expect(status.leadingValue, 'BC2201');
      expect(agg.takeCorrections(), isEmpty);
    });
  });
}

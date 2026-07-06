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
}

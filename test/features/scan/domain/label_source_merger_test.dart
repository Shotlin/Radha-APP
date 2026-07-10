import 'package:flutter_test/flutter_test.dart';
import 'package:radha_app/features/scan/domain/label_source_merger.dart';

void main() {
  group('LabelSourceMerger.mergeText', () {
    test('cloud wins outright when live has nothing confirmed', () {
      final result = LabelSourceMerger.mergeText(
        cloudValue: 'Campa Lemon Flavoured',
        liveValue: null,
        liveConfirmed: false,
      );
      expect(result.status, MergeStatus.cloudOnly);
      expect(result.value, 'Campa Lemon Flavoured');
    });

    test('cloud wins when live has a value but is not confirmed', () {
      final result = LabelSourceMerger.mergeText(
        cloudValue: 'Campa Lemon Flavoured',
        liveValue: 'CAMP',
        liveConfirmed: false,
      );
      expect(result.status, MergeStatus.cloudOnly);
      expect(result.value, 'Campa Lemon Flavoured');
    });

    test('agrees on a near-identical read within tolerance, prefers the longer one', () {
      final result = LabelSourceMerger.mergeText(
        cloudValue: 'Campa Lemon Flavoured',
        liveValue: 'Campa Lemon Flavourd',
        liveConfirmed: true,
      );
      expect(result.status, MergeStatus.agreed);
      expect(result.value, 'Campa Lemon Flavoured');
    });

    test('flags a real disagreement between two confident sources', () {
      final result = LabelSourceMerger.mergeText(
        cloudValue: 'Campa Cola',
        liveValue: 'Thums Up',
        liveConfirmed: true,
      );
      expect(result.status, MergeStatus.disagreement);
      expect(result.cloudValue, 'Campa Cola');
      expect(result.liveValue, 'Thums Up');
      expect(result.value, isNull);
    });

    test('neither side has anything -> none', () {
      final result = LabelSourceMerger.mergeText(
        cloudValue: null,
        liveValue: null,
        liveConfirmed: false,
      );
      expect(result.status, MergeStatus.none);
    });

    test('blank/whitespace-only values are treated as absent', () {
      final result = LabelSourceMerger.mergeText(
        cloudValue: '   ',
        liveValue: null,
        liveConfirmed: false,
      );
      expect(result.status, MergeStatus.none);
    });
  });

  group('LabelSourceMerger.mergeNumber', () {
    test('cloud wins outright when live is unconfirmed', () {
      final result = LabelSourceMerger.mergeNumber(
        cloudValue: 11.5,
        liveValue: null,
        liveConfirmed: false,
      );
      expect(result.status, MergeStatus.cloudOnly);
      expect(result.value, 11.5);
    });

    test('small rounding differences count as agreement', () {
      final result = LabelSourceMerger.mergeNumber(
        cloudValue: 11.5,
        liveValue: 11.4,
        liveConfirmed: true,
      );
      expect(result.status, MergeStatus.agreed);
    });

    test('a real conflict (protein 0 vs 115) is flagged, not silently picked', () {
      // The exact live-device bug this architecture exists to catch:
      // scrambled OCR order once produced "115" for a value that should
      // have been "0".
      final result = LabelSourceMerger.mergeNumber(
        cloudValue: 0,
        liveValue: 115,
        liveConfirmed: true,
      );
      expect(result.status, MergeStatus.disagreement);
      expect(result.cloudValue, 0);
      expect(result.liveValue, 115);
    });

    test('both zero counts as agreement, not a division-by-zero crash', () {
      final result = LabelSourceMerger.mergeNumber(
        cloudValue: 0,
        liveValue: 0,
        liveConfirmed: true,
      );
      expect(result.status, MergeStatus.agreed);
      expect(result.value, 0);
    });

    test('neither side has anything -> none', () {
      final result = LabelSourceMerger.mergeNumber(
        cloudValue: null,
        liveValue: null,
        liveConfirmed: false,
      );
      expect(result.status, MergeStatus.none);
    });
  });
}

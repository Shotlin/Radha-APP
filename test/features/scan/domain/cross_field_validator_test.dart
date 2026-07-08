import 'package:flutter_test/flutter_test.dart';
import 'package:radha_app/features/scan/domain/cross_field_validator.dart';
import 'package:radha_app/features/scan/domain/label_field_models.dart';

void main() {
  final today = DateTime(2026, 7, 8);

  group('no violation', () {
    test('a plausible expiry after a plausible MFG passes cleanly', () {
      final verdict = checkExpiryMfg(
        expiry: DateTime(2026, 12, 1),
        mfg: DateTime(2026, 6, 1),
        now: today,
      );
      expect(verdict, isNull);
    });

    test('only expiry present (no MFG) with no other issue passes', () {
      final verdict = checkExpiryMfg(expiry: DateTime(2026, 12, 1), now: today);
      expect(verdict, isNull);
    });

    test('only MFG present (no expiry) with no other issue passes', () {
      final verdict = checkExpiryMfg(mfg: DateTime(2026, 6, 1), now: today);
      expect(verdict, isNull);
    });

    test('neither present -> nothing to validate', () {
      expect(checkExpiryMfg(now: today), isNull);
    });
  });

  group('R1: expiry must be after MFG', () {
    test('expiry before MFG is flagged', () {
      final verdict = checkExpiryMfg(
        expiry: DateTime(2026, 1, 1),
        mfg: DateTime(2026, 6, 1),
        now: today,
      );
      expect(verdict?.demoteField, LabelField.expiryDate);
      expect(verdict?.reason, contains('R1'));
    });

    test('expiry equal to MFG is flagged (must be strictly after)', () {
      final same = DateTime(2026, 6, 1);
      final verdict = checkExpiryMfg(expiry: same, mfg: same, now: today);
      expect(verdict?.reason, contains('R1'));
    });
  });

  group('R2: MFG cannot be far in the future', () {
    test('MFG more than 31 days ahead of today is flagged', () {
      final verdict = checkExpiryMfg(
        mfg: today.add(const Duration(days: 60)),
        now: today,
      );
      expect(verdict?.demoteField, LabelField.mfgDate);
      expect(verdict?.reason, contains('R2'));
    });

    test('MFG within the 31-day grace window passes', () {
      final verdict = checkExpiryMfg(
        mfg: today.add(const Duration(days: 20)),
        now: today,
      );
      expect(verdict, isNull);
    });
  });

  group('R3: expiry must be within a plausible range of today', () {
    test('expiry more than 1 year in the past is flagged', () {
      final verdict = checkExpiryMfg(
        expiry: today.subtract(const Duration(days: 400)),
        now: today,
      );
      expect(verdict?.demoteField, LabelField.expiryDate);
      expect(verdict?.reason, contains('R3'));
    });

    test('expiry more than 5 years in the future is flagged', () {
      final verdict = checkExpiryMfg(
        expiry: today.add(const Duration(days: 365 * 6)),
        now: today,
      );
      expect(verdict?.reason, contains('R3'));
    });

    test('expiry within the plausible window passes', () {
      final verdict = checkExpiryMfg(
        expiry: today.add(const Duration(days: 365 * 2)),
        now: today,
      );
      expect(verdict, isNull);
    });
  });

  group('rule precedence', () {
    test('R1 is checked before R2/R3 when multiple rules could fire', () {
      // MFG is both after EXP (R1) and far in the future (R2) -- R1 fires
      // first since it's the more specific, higher-signal violation.
      final verdict = checkExpiryMfg(
        expiry: DateTime(2026, 1, 1),
        mfg: today.add(const Duration(days: 60)),
        now: today,
      );
      expect(verdict?.reason, contains('R1'));
    });
  });
}

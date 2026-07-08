import 'package:flutter_test/flutter_test.dart';
import 'package:radha_app/features/scan/domain/label_field_extractor.dart';
import 'package:radha_app/features/scan/domain/label_field_models.dart';

void main() {
  group('expiry date formats', () {
    test('EXP-prefixed DD/MM/YYYY', () {
      final result = LabelFieldExtractor.extract('EXP 15/03/2026');
      final candidate = result.byField[LabelField.expiryDate];
      expect(candidate?.value, '2026-03-15');
      expect(candidate?.confidence, greaterThanOrEqualTo(0.9));
    });

    test('EXP-prefixed DD-MM-YYYY (dashes)', () {
      final result = LabelFieldExtractor.extract('EXPIRY: 15-03-2026');
      expect(result.byField[LabelField.expiryDate]?.value, '2026-03-15');
    });

    test('YYYY-MM-DD (ISO)', () {
      final result = LabelFieldExtractor.extract('Best Before 2026-03-15');
      expect(result.byField[LabelField.expiryDate]?.value, '2026-03-15');
    });

    test('MM/YYYY (no day, best-before convention -> month end)', () {
      final result = LabelFieldExtractor.extract('BEST BEFORE 03/2026');
      final candidate = result.byField[LabelField.expiryDate];
      expect(candidate?.value, '2026-03-31');
    });

    test('Month-name format "FEB 2026"', () {
      final result = LabelFieldExtractor.extract('BEST BEFORE FEB 2026');
      expect(result.byField[LabelField.expiryDate]?.value, '2026-02-01');
    });

    test('Month-name with day "15 JAN 2026"', () {
      final result = LabelFieldExtractor.extract('EXP 15 JAN 2026');
      expect(result.byField[LabelField.expiryDate]?.value, '2026-01-15');
    });

    test('USE BY phrase', () {
      final result = LabelFieldExtractor.extract('USE BY 20/12/2026');
      expect(result.byField[LabelField.expiryDate]?.value, '2026-12-20');
    });

    test('BB abbreviation', () {
      final result = LabelFieldExtractor.extract('BB 20/12/2026');
      expect(result.byField[LabelField.expiryDate]?.value, '2026-12-20');
    });
  });

  group('manufacturing date formats', () {
    test('MFG-prefixed date', () {
      final result = LabelFieldExtractor.extract('MFG 10/01/2026');
      expect(result.byField[LabelField.mfgDate]?.value, '2026-01-10');
    });

    test('MANUFACTURED word', () {
      final result = LabelFieldExtractor.extract('MANUFACTURED 10-01-2026');
      expect(result.byField[LabelField.mfgDate]?.value, '2026-01-10');
    });

    test('PACKED word', () {
      final result = LabelFieldExtractor.extract('PACKED: 10/01/2026');
      expect(result.byField[LabelField.mfgDate]?.value, '2026-01-10');
    });

    test('does not confuse MFG date with EXP date on the same transcript', () {
      final result = LabelFieldExtractor.extract(
        'MFG 10/01/2026\nEXP 10/07/2026',
      );
      expect(result.byField[LabelField.mfgDate]?.value, '2026-01-10');
      expect(result.byField[LabelField.expiryDate]?.value, '2026-07-10');
    });
  });

  group('shelf-life duration derivation', () {
    test('best before 6 months from MFG computes expiry', () {
      final result = LabelFieldExtractor.extract(
        'MFG 10/01/2026\nBEST BEFORE 6 MONTHS FROM MFG',
      );
      final expiry = result.byField[LabelField.expiryDate];
      expect(expiry?.value, '2026-07-10');
      expect(expiry?.derivedFrom, contains('MFG 2026-01-10'));
      expect(expiry?.derivedFrom, contains('6 months'));
    });

    test('use before 12 months from manufacture', () {
      final result = LabelFieldExtractor.extract(
        'MANUFACTURING DATE 05/02/2026\nUSE BEFORE 12 MONTHS FROM MANUFACTURE',
      );
      expect(result.byField[LabelField.expiryDate]?.value, '2027-02-05');
    });

    test('duration in days', () {
      final result = LabelFieldExtractor.extract(
        'MFG 01/01/2026\nBEST BEFORE 10 DAYS FROM MFG',
      );
      expect(result.byField[LabelField.expiryDate]?.value, '2026-01-11');
    });

    test('no MFG date present -> duration phrase alone yields nothing', () {
      final result = LabelFieldExtractor.extract(
        'BEST BEFORE 6 MONTHS FROM MFG',
      );
      expect(result.byField[LabelField.expiryDate], isNull);
    });

    test('explicit higher-confidence EXP date wins over a derived one', () {
      final result = LabelFieldExtractor.extract(
        'MFG 10/01/2026\nEXP 15/03/2026\nBEST BEFORE 6 MONTHS FROM MFG',
      );
      // Explicit EXP-prefixed match (0.92) beats the derived one (0.8).
      expect(result.byField[LabelField.expiryDate]?.value, '2026-03-15');
    });
  });

  group('two-digit year resolution (no fixed 50/50 pivot)', () {
    test('resolves to whichever century is closer to today', () {
      final nowYear = DateTime.now().year;
      final nearFutureTwoDigit = (nowYear + 1) % 100;
      final label =
          'EXP 15/06/${nearFutureTwoDigit.toString().padLeft(2, '0')}';
      final result = LabelFieldExtractor.extract(label);
      final parsed = DateTime.parse(result.byField[LabelField.expiryDate]!.value);
      // Must resolve to a year close to now, not a fixed century pivot.
      expect((parsed.year - nowYear).abs(), lessThanOrEqualTo(1));
    });
  });

  group('invalid / malformed dates are rejected, not hallucinated', () {
    test('Feb 30 is rejected', () {
      final result = LabelFieldExtractor.extract('EXP 30/02/2026');
      expect(result.byField[LabelField.expiryDate], isNull);
    });

    test('month 13 is rejected', () {
      final result = LabelFieldExtractor.extract('EXP 15/13/2026');
      expect(result.byField[LabelField.expiryDate], isNull);
    });

    test('garbled text with no date yields no candidate', () {
      final result = LabelFieldExtractor.extract(
        'INGREDIENTS: WHEAT FLOUR SUGAR SALT VEGETABLE OIL',
      );
      expect(result.byField[LabelField.expiryDate], isNull);
      expect(result.byField[LabelField.mfgDate], isNull);
    });

    test('empty transcript yields nothing', () {
      final result = LabelFieldExtractor.extract('');
      expect(result.isEmpty, isTrue);
    });
  });

  group('batch / lot / SKU extraction', () {
    test('BATCH NO', () {
      final result = LabelFieldExtractor.extract('BATCH NO: AB1234');
      expect(result.byField[LabelField.batchNumber]?.value, 'AB1234');
    });

    test('LOT NO', () {
      final result = LabelFieldExtractor.extract('LOT NO L-9987');
      expect(result.byField[LabelField.batchNumber]?.value, 'L-9987');
    });

    test('SKU', () {
      final result = LabelFieldExtractor.extract('SKU: RAD-00123');
      expect(result.byField[LabelField.skuOrProductId]?.value, 'RAD-00123');
    });

    test('PRODUCT ID', () {
      final result = LabelFieldExtractor.extract('PRODUCT ID PID789');
      expect(result.byField[LabelField.skuOrProductId]?.value, 'PID789');
    });
  });

  group('nutrition extraction', () {
    test('extracts multiple nutrients with units', () {
      final result = LabelFieldExtractor.extract(
        'ENERGY 350 KCAL\nPROTEIN 8G\nSODIUM 120MG\nSUGAR 12G',
      );
      final decoded = LabelFieldExtractor.decodeNutrition(
        result.byField[LabelField.nutrition]!.value,
      );
      expect(decoded['energy'], '350kcal');
      expect(decoded['protein'], '8g');
      expect(decoded['sodium'], '120mg');
      expect(decoded['sugar'], '12g');
    });

    test('no nutrition info present -> no candidate', () {
      final result = LabelFieldExtractor.extract('EXP 15/03/2026');
      expect(result.byField[LabelField.nutrition], isNull);
    });
  });

  group('unlabeled two-date inference (Indian pack convention)', () {
    test('two bare dates -> earlier is MFG, later is expiry', () {
      // Exactly the user-reported real-world case: the pack prints both
      // dates with no MFG/EXP keywords at all.
      final result = LabelFieldExtractor.extract(
        '25/04/2026\n21/10/2026',
      );
      expect(result.byField[LabelField.mfgDate]?.value, '2026-04-25');
      expect(result.byField[LabelField.expiryDate]?.value, '2026-10-21');
    });

    test('order on the label does not matter, only chronology', () {
      final result = LabelFieldExtractor.extract(
        '21/10/2026\n25/04/2026',
      );
      expect(result.byField[LabelField.mfgDate]?.value, '2026-04-25');
      expect(result.byField[LabelField.expiryDate]?.value, '2026-10-21');
    });

    test('single bare date still assumed to be expiry', () {
      final result = LabelFieldExtractor.extract('15/08/2026');
      expect(result.byField[LabelField.expiryDate]?.value, '2026-08-15');
      expect(result.byField[LabelField.mfgDate], isNull);
    });

    test('same bare date repeated counts as a single date', () {
      final result = LabelFieldExtractor.extract('15/08/2026\n15/08/2026');
      expect(result.byField[LabelField.expiryDate]?.value, '2026-08-15');
      expect(result.byField[LabelField.mfgDate], isNull);
    });

    test('explicit labels always beat the inference', () {
      // EXP is explicitly the EARLIER date here (weird but printed) — the
      // label must win over chronology-based guessing.
      final result = LabelFieldExtractor.extract(
        'EXP 25/04/2026\nMFG 21/10/2025\n01/01/2027',
      );
      expect(result.byField[LabelField.expiryDate]?.value, '2026-04-25');
      expect(result.byField[LabelField.mfgDate]?.value, '2025-10-21');
    });

    test('inferred candidates carry lower confidence than labelled ones', () {
      final inferred = LabelFieldExtractor.extract(
        '25/04/2026\n21/10/2026',
      );
      final labelled = LabelFieldExtractor.extract('EXP 21/10/2026');
      expect(
        inferred.byField[LabelField.expiryDate]!.confidence,
        lessThan(labelled.byField[LabelField.expiryDate]!.confidence),
      );
    });

    test('inference works with mixed formats (bare DMY + month name)', () {
      final result = LabelFieldExtractor.extract(
        '25/04/2026\n21 OCT 2026',
      );
      expect(result.byField[LabelField.mfgDate]?.value, '2026-04-25');
      expect(result.byField[LabelField.expiryDate]?.value, '2026-10-21');
    });
  });

  group('Indian-label keyword coverage', () {
    test('MEXP prefix', () {
      final result = LabelFieldExtractor.extract('MEXP 15/03/2026');
      expect(result.byField[LabelField.expiryDate]?.value, '2026-03-15');
      expect(result.byField[LabelField.expiryDate]?.confidence, 0.92);
    });

    test('EXP.DT prefix', () {
      final result = LabelFieldExtractor.extract('EXP.DT 15/03/2026');
      expect(result.byField[LabelField.expiryDate]?.value, '2026-03-15');
    });

    test('BBE (best-before-end abbreviation)', () {
      final result = LabelFieldExtractor.extract('BBE 15/03/2026');
      expect(result.byField[LabelField.expiryDate]?.value, '2026-03-15');
    });

    test('BEST BEFORE END (full phrase)', () {
      final result = LabelFieldExtractor.extract('BEST BEFORE END 15/03/2026');
      expect(result.byField[LabelField.expiryDate]?.value, '2026-03-15');
    });

    test('USE BEFORE', () {
      final result = LabelFieldExtractor.extract('USE BEFORE 15/03/2026');
      expect(result.byField[LabelField.expiryDate]?.value, '2026-03-15');
    });

    test('VALID UPTO (no space)', () {
      final result = LabelFieldExtractor.extract('VALID UPTO 15/03/2026');
      expect(result.byField[LabelField.expiryDate]?.value, '2026-03-15');
    });

    test('VALID UP TO (with space)', () {
      final result = LabelFieldExtractor.extract('VALID UP TO 15/03/2026');
      expect(result.byField[LabelField.expiryDate]?.value, '2026-03-15');
    });

    test('DOE (date of expiry)', () {
      final result = LabelFieldExtractor.extract('DOE 15/03/2026');
      expect(result.byField[LabelField.expiryDate]?.value, '2026-03-15');
    });

    test('MFG.DT prefix', () {
      final result = LabelFieldExtractor.extract('MFG.DT 10/01/2026');
      expect(result.byField[LabelField.mfgDate]?.value, '2026-01-10');
      expect(result.byField[LabelField.mfgDate]?.confidence, 0.9);
    });

    test('DOM (date of manufacture)', () {
      final result = LabelFieldExtractor.extract('DOM 10/01/2026');
      expect(result.byField[LabelField.mfgDate]?.value, '2026-01-10');
    });

    test('MFD.ON', () {
      final result = LabelFieldExtractor.extract('MFD.ON 10/01/2026');
      expect(result.byField[LabelField.mfgDate]?.value, '2026-01-10');
    });

    test('PKD.ON', () {
      final result = LabelFieldExtractor.extract('PKD.ON 10/01/2026');
      expect(result.byField[LabelField.mfgDate]?.value, '2026-01-10');
    });

    test('PACKED ON', () {
      final result = LabelFieldExtractor.extract('PACKED ON 10/01/2026');
      expect(result.byField[LabelField.mfgDate]?.value, '2026-01-10');
    });

    test('DATE OF PKG', () {
      final result = LabelFieldExtractor.extract('DATE OF PKG 10/01/2026');
      expect(result.byField[LabelField.mfgDate]?.value, '2026-01-10');
    });

    test('PKG DATE', () {
      final result = LabelFieldExtractor.extract('PKG DATE 10/01/2026');
      expect(result.byField[LabelField.mfgDate]?.value, '2026-01-10');
    });

    test('DT.OF.MFG', () {
      final result = LabelFieldExtractor.extract('DT.OF.MFG 10/01/2026');
      expect(result.byField[LabelField.mfgDate]?.value, '2026-01-10');
    });
  });

  group('OCR digit-noise recovery', () {
    test('normalizeOcrDigits substitutes O/S/I/l/B/Z and leaves clean input alone', () {
      expect(LabelFieldExtractor.normalizeOcrDigits('2O25'), '2025');
      expect(LabelFieldExtractor.normalizeOcrDigits('O5'), '05');
      expect(LabelFieldExtractor.normalizeOcrDigits('l5'), '15');
      expect(LabelFieldExtractor.normalizeOcrDigits('S5'), '55');
      // No confusable letters present -> nothing changed -> null.
      expect(LabelFieldExtractor.normalizeOcrDigits('2025'), isNull);
    });

    test('normalizeOcrDigits refuses to mangle non-digit-majority text', () {
      // "SEP" -> "5EP" is only 1/3 digits after substitution -> rejected,
      // so a month-name span can never accidentally get "corrected".
      expect(LabelFieldExtractor.normalizeOcrDigits('SEP'), isNull);
    });

    test('ISO date with OCR-confused digits recovers via EXP-line context', () {
      final result = LabelFieldExtractor.extract('EXP 2O25-O3-15');
      final candidate = result.byField[LabelField.expiryDate];
      expect(candidate?.value, '2025-03-15');
      expect(candidate?.confidence, closeTo(0.88 * 0.95, 0.001));
      expect(candidate?.derivedFrom, contains('ocr-normalized'));
    });

    test('EXP-prefixed DMY date with OCR-confused digits', () {
      final result = LabelFieldExtractor.extract('EXP: O5/O3/2O26');
      final candidate = result.byField[LabelField.expiryDate];
      expect(candidate?.value, '2026-03-05');
      expect(candidate?.confidence, closeTo(0.92 * 0.95, 0.001));
      expect(candidate?.derivedFrom, contains('ocr-normalized'));
    });

    test('MFG-prefixed date with OCR-confused digits', () {
      final result = LabelFieldExtractor.extract('MFG: l0/0l/2026');
      final candidate = result.byField[LabelField.mfgDate];
      expect(candidate?.value, '2026-01-10');
      expect(candidate?.confidence, closeTo(0.9 * 0.95, 0.001));
    });

    test('clean digits never pay the OCR-normalization penalty', () {
      final result = LabelFieldExtractor.extract('EXP 15/03/2026');
      final candidate = result.byField[LabelField.expiryDate];
      expect(candidate?.confidence, 0.92);
      expect(candidate?.derivedFrom, isNull);
    });

    test('month-name dates are never touched by digit normalization', () {
      // "SEP" contains no digits to confuse; confirms the month-name path
      // (which never calls normalizeOcrDigits) is unaffected by this phase.
      final result = LabelFieldExtractor.extract('EXP 15 SEP 2026');
      expect(result.byField[LabelField.expiryDate]?.value, '2026-09-15');
    });
  });

  group('exclusion guards', () {
    test('MRP/tax line with a bare date yields no candidate at all', () {
      final result = LabelFieldExtractor.extract(
        'MRP RS.450 INCL TAXES 12/01/2025',
      );
      expect(result.byField[LabelField.expiryDate], isNull);
      expect(result.byField[LabelField.mfgDate], isNull);
    });

    test('customer-care phone-number line with a bare date is excluded', () {
      final result = LabelFieldExtractor.extract(
        'Customer Care 9876543210 12/01/2025',
      );
      expect(result.byField[LabelField.expiryDate], isNull);
    });

    test('bare 10-digit Indian mobile number line is excluded even without wording', () {
      final result = LabelFieldExtractor.extract('Call us 9876543210 12/01/2025');
      expect(result.byField[LabelField.expiryDate], isNull);
    });

    test('FSSAI license line with a bare date is excluded', () {
      final result = LabelFieldExtractor.extract(
        'FSSAI LIC NO 12345678901234 12/01/2025',
      );
      expect(result.byField[LabelField.expiryDate], isNull);
    });

    test('PIN-code line with a bare date is excluded', () {
      final result = LabelFieldExtractor.extract(
        'Address Mumbai PIN 400001 12/01/2025',
      );
      expect(result.byField[LabelField.expiryDate], isNull);
    });

    test('a genuine EXP line still resolves when an excluded MRP line is elsewhere in the same transcript', () {
      final result = LabelFieldExtractor.extract('''
        MRP RS.450 INCL TAXES 12/01/2025
        EXP 15/03/2026
      ''');
      expect(result.byField[LabelField.expiryDate]?.value, '2026-03-15');
      expect(result.byField[LabelField.mfgDate], isNull);
    });
  });

  group('combined real-world label transcript', () {
    test('extracts every field from one realistic noisy transcript', () {
      const transcript = '''
        FoodBrand Cereal
        MFG 10/01/2026
        EXP 10/07/2026
        BATCH NO: BC2201
        ENERGY 350 KCAL
        PROTEIN 8G
        CARBOHYDRATE 70G
        SUGAR 15G
        SODIUM 200MG
      ''';
      final result = LabelFieldExtractor.extract(transcript);
      expect(result.byField[LabelField.mfgDate]?.value, '2026-01-10');
      expect(result.byField[LabelField.expiryDate]?.value, '2026-07-10');
      expect(result.byField[LabelField.batchNumber]?.value, 'BC2201');
      final nutrition = LabelFieldExtractor.decodeNutrition(
        result.byField[LabelField.nutrition]!.value,
      );
      expect(nutrition['protein'], '8g');
      expect(nutrition['carbohydrate'], '70g');
    });
  });
}

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

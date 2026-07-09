import 'package:flutter_test/flutter_test.dart';
import 'package:radha_app/features/scan/domain/product_name_extractor.dart';

void main() {
  group('ProductNameExtractor.bestCandidate', () {
    test('picks the sole plausible line when its block has just one', () {
      final result = ProductNameExtractor.bestCandidate([
        [('Amul Butter 500g', 40)],
        [('INGREDIENTS: Milk fat, salt', 18)],
        [('MRP Rs. 250.00', 16)],
      ]);
      expect(result, 'Amul Butter 500g');
    });

    test('combines every plausible line in the tallest-line\'s block, in order', () {
      // Live-device capture (Campa Lemon bottle, 2026-07-09): the brand
      // name and flavour are two stacked lines of very different sizes
      // that ML Kit groups into one block — picking only the isolated
      // tallest line ("CAMPA") silently dropped "LEMON FLAVOURED".
      final result = ProductNameExtractor.bestCandidate([
        [('CAMPA', 48), ('LEMON', 10), ('FLAVOURED', 8)],
      ]);
      expect(result, 'CAMPA LEMON FLAVOURED');
    });

    test('a non-plausible line inside the winning block is dropped, not blank-joined', () {
      final result = ProductNameExtractor.bestCandidate([
        [
          ('Britannia', 40.0),
          ('Good Day', 30.0),
          ('NET WT', 10.0),
        ],
      ]);
      expect(result, 'Britannia Good Day');
    });

    test('ignores a tall "NET QUANTITY" line (real device misread, 2026-07-09)', () {
      final result = ProductNameExtractor.bestCandidate([
        [('NET QUANTITY', 48)],
        [('CAMPA', 40)],
      ]);
      expect(result, 'CAMPA');
    });

    test('ignores boilerplate lines even if tall', () {
      final result = ProductNameExtractor.bestCandidate([
        [('NUTRITION FACTS', 50)],
        [('Britannia Good Day', 30)],
      ]);
      expect(result, 'Britannia Good Day');
    });

    test('ignores mostly-numeric/barcode lines', () {
      final result = ProductNameExtractor.bestCandidate([
        [('7622202225512', 45)],
        [('Oreo Original', 32)],
      ]);
      expect(result, 'Oreo Original');
    });

    test('ignores FSSAI / address / phone-style lines', () {
      final result = ProductNameExtractor.bestCandidate([
        [('FSSAI Lic No. 10014022002711', 38)],
        [('Customer care: 1800-123-4567', 22)],
        [('Maggi 2-Minute Noodles', 28)],
      ]);
      expect(result, 'Maggi 2-Minute Noodles');
    });

    test('rejects lines that are too short or too long', () {
      final result = ProductNameExtractor.bestCandidate([
        [('Hi', 60)],
        [('A' * 61, 55)],
        [('Parle-G Original', 25)],
      ]);
      expect(result, 'Parle-G Original');
    });

    test('no plausible line yields null', () {
      final result = ProductNameExtractor.bestCandidate([
        [('MRP Rs. 10.00', 20)],
        [('123456789012', 18)],
      ]);
      expect(result, isNull);
    });

    test('empty input yields null', () {
      expect(ProductNameExtractor.bestCandidate([]), isNull);
    });

    test('a taller boilerplate line does not shadow a shorter valid one', () {
      final result = ProductNameExtractor.bestCandidate([
        [('www.britannia.co.in', 70)],
        [('Britannia Marie Gold', 26)],
      ]);
      expect(result, 'Britannia Marie Gold');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:radha_app/features/scan/utils/ean_validator.dart';

void main() {
  group('getEanType', () {
    test('accepts a valid EAN-13', () {
      // Checksum-valid EAN-13 (verified independently, not just by this
      // code's own algorithm).
      expect(getEanType('5449000000996'), EanType.ean13);
    });

    test('accepts a valid EAN-8', () {
      expect(getEanType('40170725'), EanType.ean8);
    });

    test('accepts a valid UPC-A', () {
      expect(getEanType('012345000096'), EanType.upcA);
    });

    test('accepts a valid UPC-E and expands correctly', () {
      // UPC-E "01234596": number system 0, x1..x6 = 1,2,3,4,5,9 (x6 in
      // 5-9 branch), check digit 6. Expands to UPC-A "012345000096",
      // which is independently checksum-valid (verified by hand above
      // and cross-checked by the UPC-A test case using the same digits).
      expect(getEanType('01234596'), EanType.upcE);
    });

    test('rejects a UPC-E-length code with an invalid checksum', () {
      expect(getEanType('01234599'), isNull);
    });

    test('rejects a UPC-E-length code with a non-0/1 number-system digit as UPC-E but may still be a valid EAN-8', () {
      // Number system digit 5 isn't valid for UPC-E, so this must not be
      // reported as upcE -- it falls through to plain EAN-8 checksum
      // validation instead.
      final result = getEanType('54490009');
      expect(result, isNot(EanType.upcE));
    });

    test('rejects garbage input', () {
      expect(getEanType('not-a-barcode'), isNull);
      expect(getEanType(''), isNull);
      expect(getEanType('123'), isNull);
    });
  });

  group('isValidEan', () {
    test('true for valid codes, false for invalid', () {
      expect(isValidEan('012345000096'), isTrue);
      expect(isValidEan('01234596'), isTrue);
      // Checksum sum is 1 (not divisible by 10) whether validated as EAN-8
      // or expanded UPC-E -> UPC-A, so this is invalid under either path.
      expect(isValidEan('00000001'), isFalse);
    });
  });
}

/// EAN/UPC barcode format validation with checksum verification.
///
/// Supports EAN-8, EAN-13, UPC-A, and UPC-E formats using the standard
/// modulo-10 checksum algorithm.
library;

/// The type of barcode detected.
enum EanType { ean8, ean13, upcA, upcE }

/// Returns the [EanType] if [code] is a valid barcode, or `null` otherwise.
EanType? getEanType(String code) {
  if (!_isNumeric(code)) return null;
  switch (code.length) {
    case 8:
      // Ambiguous by length alone: could be EAN-8 or a full UPC-E read
      // (number-system digit + 6 compressed digits + check digit).
      // UPC-E's number-system digit is always 0 or 1 (GS1 spec) — a
      // scanner emitting BarcodeFormat.upcE will only ever produce codes
      // starting with one of those two digits, so try UPC-E expansion
      // first and fall back to plain EAN-8 checksum validation.
      final expanded = _expandUpcEToUpcA(code);
      if (expanded != null && _checksumValid(expanded)) return EanType.upcE;
      return _checksumValid(code) ? EanType.ean8 : null;
    case 12:
      return _checksumValid(code) ? EanType.upcA : null;
    case 13:
      return _checksumValid(code) ? EanType.ean13 : null;
    default:
      return null;
  }
}

/// Returns `true` if [code] is a valid EAN-8, EAN-13, UPC-A, or UPC-E
/// barcode.
bool isValidEan(String code) => getEanType(code) != null;

/// Standard GS1 modulo-10 checksum validation.
///
/// Works for EAN-8, EAN-13, and UPC-A — the algorithm is identical,
/// only the length changes.
bool _checksumValid(String code) {
  var sum = 0;
  for (var i = 0; i < code.length; i++) {
    final digit = code.codeUnitAt(i) - 48; // '0' == 48
    final weight = (code.length - 1 - i).isEven ? 1 : 3;
    sum += digit * weight;
  }
  return sum % 10 == 0;
}

/// Expands an 8-digit UPC-E read (number system + 6 compressed digits +
/// check digit) into the 12-digit UPC-A it represents, per the standard
/// GS1 suppression table. Returns `null` if the number-system digit isn't
/// 0 or 1 (UPC-E is only defined for those two) — the caller then falls
/// back to treating the code as a plain EAN-8 read.
///
/// The UPC-E check digit is defined as *the same value* the full
/// expanded UPC-A's check digit would be, so it's carried through
/// unchanged here; the caller validates the expanded 12-digit result
/// with the existing [_checksumValid], no separate checksum logic needed.
String? _expandUpcEToUpcA(String code) {
  if (code.length != 8) return null;
  final numberSystem = code[0];
  if (numberSystem != '0' && numberSystem != '1') return null;
  final x1 = code[1], x2 = code[2], x3 = code[3];
  final x4 = code[4], x5 = code[5], x6 = code[6];
  final checkDigit = code[7];

  String manufacturer;
  String product;
  switch (x6) {
    case '0':
    case '1':
    case '2':
      manufacturer = '$x1$x2$x6' '00';
      product = '00$x3$x4$x5';
    case '3':
      manufacturer = '$x1$x2$x3' '00';
      product = '000$x4$x5';
    case '4':
      manufacturer = '$x1$x2$x3$x4' '0';
      product = '0000$x5';
    default: // 5-9
      manufacturer = '$x1$x2$x3$x4$x5';
      product = '0000$x6';
  }
  return '$numberSystem$manufacturer$product$checkDigit';
}

bool _isNumeric(String s) {
  if (s.isEmpty) return false;
  for (var i = 0; i < s.length; i++) {
    final c = s.codeUnitAt(i);
    if (c < 48 || c > 57) return false; // not 0-9
  }
  return true;
}

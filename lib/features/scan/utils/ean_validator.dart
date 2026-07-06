/// EAN/UPC barcode format validation with checksum verification.
///
/// Supports EAN-8, EAN-13, and UPC-A formats using the standard
/// modulo-10 checksum algorithm.
library;

/// The type of barcode detected.
enum EanType { ean8, ean13, upcA }

/// Returns the [EanType] if [code] is a valid barcode, or `null` otherwise.
EanType? getEanType(String code) {
  if (!_isNumeric(code)) return null;
  switch (code.length) {
    case 8:
      return _checksumValid(code) ? EanType.ean8 : null;
    case 12:
      return _checksumValid(code) ? EanType.upcA : null;
    case 13:
      return _checksumValid(code) ? EanType.ean13 : null;
    default:
      return null;
  }
}

/// Returns `true` if [code] is a valid EAN-8, EAN-13, or UPC-A barcode.
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

bool _isNumeric(String s) {
  if (s.isEmpty) return false;
  for (var i = 0; i < s.length; i++) {
    final c = s.codeUnitAt(i);
    if (c < 48 || c > 57) return false; // not 0-9
  }
  return true;
}

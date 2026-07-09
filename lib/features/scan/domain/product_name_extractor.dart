// Product-name line heuristic.
//
// Pure Dart, no Flutter/ML-Kit dependency — same separation-of-concerns
// discipline as label_field_extractor.dart: this takes plain (text, height)
// pairs, GROUPED BY OCR BLOCK, for one frame and returns a best-guess
// product-name candidate, or null. The caller (contribute_product_screen.dart)
// is responsible for mapping ML Kit's RecognizedText.blocks/lines into that
// simple shape — this file stays testable without any camera/ML Kit
// dependency, exactly like the field extractor.
//
// Heuristic: on an Indian retail label the brand/product name is almost
// always the largest printed text on the pack, but it's frequently split
// across 2-3 stacked lines of different sizes — e.g. "CAMPA" in huge type
// with "LEMON FLAVOURED" in smaller type directly beneath it. Picking a
// single isolated "tallest line" throws that second line away. ML Kit's
// own block segmentation already groups spatially-clustered, related
// lines together (that's what a TextBlock IS), so instead of flattening
// every line into one pool, this picks the BLOCK containing the tallest
// plausible line, then joins every plausible line in THAT block, in
// reading order — trusting ML Kit's own grouping rather than
// re-deriving it from height alone.
class ProductNameExtractor {
  ProductNameExtractor._();

  static final RegExp _boilerplate = RegExp(
    r'INGREDIENTS?|NUTRITION|ENERGY|ALLERGEN|STORAGE|STORE\s*IN|MFD|MFG|EXP|'
    r'EXPIRY|BEST\s*BEFORE|USE\s*BY|BATCH|NET\s*(WT|WEIGHT|QTY|QUANTITY|'
    r'CONTENTS?)|BARCODE|FSSAI|CUSTOMER\s*CARE|MRP|RS\.?\s*\d|₹|'
    r'PER\s*100\s*G|MANUFACTURED|PACKED|MARKETED|ADDRESS|'
    r'PIN\s*[:\-]?\s*\d{6}|WWW\.|\.COM|VEG\b|NON[\s\-]?VEG\b',
    caseSensitive: false,
  );

  /// A line that's mostly digits/punctuation (prices, weights, barcodes,
  /// dates) is never part of a product name, however tall its bounding
  /// box is.
  static final RegExp _mostlyNonAlpha = RegExp(r'^[^A-Za-z]*$');

  static bool _isPlausible(String trimmed) {
    if (trimmed.length < 3 || trimmed.length > 60) return false;
    if (_mostlyNonAlpha.hasMatch(trimmed)) return false;
    if (_boilerplate.hasMatch(trimmed)) return false;
    return true;
  }

  /// [blocks]: one entry per ML Kit `TextBlock`, each a list of
  /// (line text, line bounding-box height) in that block's own reading
  /// order. Returns every plausible line from the block that contains the
  /// single tallest plausible line anywhere in the frame, joined with a
  /// space — or null if nothing plausible was found at all.
  static String? bestCandidate(List<List<(String text, double height)>> blocks) {
    List<(String, double)>? bestBlock;
    double bestHeight = 0;
    for (final block in blocks) {
      for (final (text, height) in block) {
        if (!_isPlausible(text.trim())) continue;
        if (height <= bestHeight) continue;
        bestHeight = height;
        bestBlock = block;
      }
    }
    if (bestBlock == null) return null;

    final parts = [
      for (final (text, _) in bestBlock)
        if (_isPlausible(text.trim())) text.trim(),
    ];
    if (parts.isEmpty) return null;
    final combined = parts.join(' ');
    return combined.length > 80 ? combined.substring(0, 80).trim() : combined;
  }
}

// Label field-extraction engine.
//
// Pure Dart, no Flutter/platform dependency — takes one frame's OCR
// transcript and returns whatever field candidates it can find, each tagged
// with a pattern-level confidence. This is deliberately just "read what's
// there, score how sure the format itself is" — it does NOT decide whether
// a value is trustworthy across time; that's the consensus aggregator's job
// (frame_consensus_aggregator.dart). Keeping the two concerns separate is
// what makes both independently testable and what stops a single garbled
// frame from ever reaching the UI as if it were fact.
//
// Fixes over the previous single-shot parser (ocr_date_helper.dart):
//   - Every match carries a confidence score (previously: none — a date was
//     either found or it wasn't, with no way to express "found but shaky").
//   - Two-digit years resolve to whichever century is closer to *today*,
//     not a fixed 50/50 pivot — a fixed pivot silently mis-resolves both
//     genuinely old manufacturing dates and any date near the pivot itself.
//   - Shelf-life phrases ("best before 6 months from MFG") are parsed and,
//     when a manufacturing date is also present in the same transcript,
//     combined into a derived expiry date — previously ignored entirely.
//   - Batch/lot/SKU/product-ID and common nutrition fields are extracted,
//     which the previous parser didn't attempt at all.

import 'label_field_models.dart';

class LabelFieldExtractor {
  LabelFieldExtractor._();

  /// Extracts every field this engine understands from one frame's
  /// transcript. Returns at most one candidate per field — when multiple
  /// patterns match, the highest-confidence one wins.
  static LabelFieldCandidates extract(String transcript) {
    final byField = <LabelField, FieldCandidate>{};

    final dateCandidates = _extractDateCandidates(transcript);
    _keepBest(byField, LabelField.expiryDate, dateCandidates.expiry);
    _keepBest(byField, LabelField.mfgDate, dateCandidates.mfg);

    final batch = _extractBatch(transcript);
    if (batch != null) byField[LabelField.batchNumber] = batch;

    final sku = _extractSku(transcript);
    if (sku != null) byField[LabelField.skuOrProductId] = sku;

    final nutrition = _extractNutrition(transcript);
    if (nutrition != null) byField[LabelField.nutrition] = nutrition;

    return LabelFieldCandidates(transcript: transcript, byField: byField);
  }

  static void _keepBest(
    Map<LabelField, FieldCandidate> byField,
    LabelField field,
    FieldCandidate? candidate,
  ) {
    if (candidate == null) return;
    final existing = byField[field];
    if (existing == null || candidate.confidence > existing.confidence) {
      byField[field] = candidate;
    }
  }

  // ─── Dates ──────────────────────────────────────────────────────────────

  static const Map<String, int> _monthAbbreviations = {
    'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
    'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
  };

  // Shared keyword alternations so the "does this line mention EXP/MFG"
  // indicator regexes and the "EXP: <date>" prefix regexes never drift
  // apart. DOM/DOE are 3-letter sequences that could otherwise appear in
  // ordinary English text; the `\b` boundaries plus (for the prefix
  // regexes) the mandatory trailing date triplet keep them safe.
  static const String _expKeywords =
      r'M\.?EXP\b|EXP\.?\s?DTE?\b|EXP\b|EXPIRY\s*DTE?|EXPIRY|'
      r'BEST\s*BEFORE\s*END|BEST\s*BEFORE|BBE\b|BB\b|'
      r'USE\s*BEFORE|USE\s*BY|VALID\s*UP\s*TO|DOE\b';
  static const String _mfgKeywords =
      r'MFG\.?\s?DTE?\b|MFG\b|MFD\.?\s?ON\b|MFD\b|'
      r'MANUFACTUR(?:ED|ING)|DT\.?\s?OF\.?\s?MFG\b|DOM\b|'
      r'PKD\.?\s?ON\b|PKD\b|PACKED\s*ON|PACKED|'
      r'DATE\s*OF\s*PKG|PKG\s*DATE';

  // Digit-position character class that also accepts the OCR confusions
  // `normalizeOcrDigits` knows how to fix — lets the "noisy" regex variants
  // below capture a date-shaped span even when digits were misread as
  // letters, so it can be normalized and re-parsed instead of silently
  // failing to match at all.
  static const String _noisyDigit = r'[0-9OoSsIl|BZ]';

  static final RegExp _expPrefixNumeric = RegExp(
    '(?:$_expKeywords)[\\s:.-]*'
    r'(\d{1,2})[\/\-.](\d{1,2})[\/\-.](\d{2,4})',
    caseSensitive: false,
  );
  static final RegExp _expPrefixNumericNoisy = RegExp(
    '(?:$_expKeywords)[\\s:.-]*'
    '($_noisyDigit{1,2})[\\/\\-.]($_noisyDigit{1,2})[\\/\\-.]($_noisyDigit{2,4})',
    caseSensitive: false,
  );
  static final RegExp _mfgPrefixNumeric = RegExp(
    '(?:$_mfgKeywords)[\\s:.-]*'
    r'(\d{1,2})[\/\-.](\d{1,2})[\/\-.](\d{2,4})',
    caseSensitive: false,
  );
  static final RegExp _mfgPrefixNumericNoisy = RegExp(
    '(?:$_mfgKeywords)[\\s:.-]*'
    '($_noisyDigit{1,2})[\\/\\-.]($_noisyDigit{1,2})[\\/\\-.]($_noisyDigit{2,4})',
    caseSensitive: false,
  );
  static final RegExp _isoDate = RegExp(r'\b(\d{4})[\/\-.](\d{1,2})[\/\-.](\d{1,2})\b');
  static final RegExp _isoDateNoisy = RegExp(
    '\\b($_noisyDigit{4})[\\/\\-.]($_noisyDigit{1,2})[\\/\\-.]($_noisyDigit{1,2})\\b',
    caseSensitive: false,
  );
  static final RegExp _bareDmy = RegExp(r'\b(\d{1,2})[\/\-.](\d{1,2})[\/\-.](\d{2,4})\b');
  static final RegExp _bareDmyNoisy = RegExp(
    '\\b($_noisyDigit{1,2})[\\/\\-.]($_noisyDigit{1,2})[\\/\\-.]($_noisyDigit{2,4})\\b',
    caseSensitive: false,
  );
  static final RegExp _monthYear = RegExp(r'\b(\d{1,2})[\/\-.](\d{2,4})\b');

  // Alternates over actual month names/abbreviations only — a generic
  // `[A-Za-z]{3,9}` here would greedily match label keywords like "EXP" or
  // "MFG" as a fake month, consuming the real day digit before the genuine
  // month-name match downstream ever gets a chance at it.
  static final RegExp _monthName = RegExp(
    r'(\d{1,2})?\s*[-/. ]?\s*'
    r'(jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|jun[e]?|'
    r'jul[y]?|aug(?:ust)?|sep(?:t|tember)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)'
    r'\.?\s*[-/. ,]?\s*(\d{2,4})',
    caseSensitive: false,
  );

  static final RegExp _expIndicator = RegExp(_expKeywords, caseSensitive: false);
  static final RegExp _mfgIndicator = RegExp(_mfgKeywords, caseSensitive: false);

  /// "Best before 6 months from MFG" / "Use before 12 months from manufacture"
  /// / "18 months from packing date" — a shelf-life duration rather than an
  /// explicit calendar date.
  static final RegExp _shelfLifeDuration = RegExp(
    r'(?:BEST\s*BEFORE|USE\s*(?:BEFORE|WITHIN))\s*(\d{1,3})\s*'
    r'(DAYS?|WEEKS?|MONTHS?|YEARS?)\s*FROM\s*'
    r'(?:MFG|MFD|MANUFACTURE|MANUFACTURING|PACKING|PACKAGING|PKD)',
    caseSensitive: false,
  );

  // ─── Exclusion guards ───────────────────────────────────────────────────
  //
  // Lines carrying pricing, contact, or regulatory boilerplate frequently
  // contain date-shaped digit runs (an MRP line's "12/25" tax code, a
  // customer-care phone number, a 6-digit PIN) that must never be read as
  // an expiry/MFG date. Checked once per line before any date regex runs.
  static final RegExp _excludedLinePattern = RegExp(
    r'₹|RS\.?\s|MRP|INCL(?:USIVE)?|TAXES?|'
    r'(?:\+91[-\s]?)?[6-9]\d{9}|'
    r'CUSTOMER\s*CARE|TOLL\s*FREE|LIC(?:ENSE)?\s*NO|FSSAI|'
    r'PIN[\s:-]*\d{6}',
    caseSensitive: false,
  );

  static bool _isExcludedLine(String line) => _excludedLinePattern.hasMatch(line);

  // ─── OCR digit-noise recovery ───────────────────────────────────────────

  static const Map<String, String> _ocrDigitConfusions = {
    'O': '0', 'o': '0',
    'S': '5', 's': '5',
    'I': '1', 'l': '1', '|': '1',
    'B': '8',
    'Z': '2',
  };

  /// Applies common OCR digit confusions (O→0, S→5, I/l/|→1, B→8, Z→2) to
  /// [span]. Only meant to run as a fallback AFTER a strict digit-only parse
  /// has already failed — callers must not apply this to month-name spans,
  /// where those letters are semantically load-bearing (e.g. "JAN" must
  /// never become "1AN"). Returns `null` when substitution didn't change
  /// anything, or when fewer than half the non-whitespace characters are
  /// digits after substitution (guards against mangling non-date text that
  /// merely happens to contain one of these letters).
  static String? normalizeOcrDigits(String span) {
    final buffer = StringBuffer();
    for (final ch in span.split('')) {
      buffer.write(_ocrDigitConfusions[ch] ?? ch);
    }
    final normalized = buffer.toString();
    if (normalized == span) return null;

    final nonSpace = normalized.replaceAll(RegExp(r'\s'), '');
    if (nonSpace.isEmpty) return null;
    final digitCount =
        nonSpace.split('').where((c) => RegExp(r'\d').hasMatch(c)).length;
    if (digitCount / nonSpace.length < 0.5) return null;

    return normalized;
  }

  /// Parses a D/M/Y triplet that may contain OCR-confused digits: tries the
  /// strict parse first (cheap, no false "corrected" provenance on already-
  /// clean input), and only falls back to per-component normalization when
  /// the strict parse fails AND normalization actually changed something.
  static ({DateTime date, bool wasNormalized})? _numericDmyOcrAware(
    String d,
    String m,
    String y,
  ) {
    final direct = _numericDmy(d, m, y);
    if (direct != null) return (date: direct, wasNormalized: false);

    final nd = normalizeOcrDigits(d) ?? d;
    final nm = normalizeOcrDigits(m) ?? m;
    final ny = normalizeOcrDigits(y) ?? y;
    if (nd == d && nm == m && ny == y) return null;

    final normalizedDate = _numericDmy(nd, nm, ny);
    if (normalizedDate == null) return null;
    return (date: normalizedDate, wasNormalized: true);
  }

  /// ISO (Y/M/D) counterpart of [_numericDmyOcrAware].
  static ({DateTime date, bool wasNormalized})? _isoYmdOcrAware(
    String y,
    String m,
    String d,
  ) {
    final direct = _isoYmd(y, m, d);
    if (direct != null) return (date: direct, wasNormalized: false);

    final ny = normalizeOcrDigits(y) ?? y;
    final nm = normalizeOcrDigits(m) ?? m;
    final nd = normalizeOcrDigits(d) ?? d;
    if (ny == y && nm == m && nd == d) return null;

    final normalizedDate = _isoYmd(ny, nm, nd);
    if (normalizedDate == null) return null;
    return (date: normalizedDate, wasNormalized: true);
  }

  static ({FieldCandidate? expiry, FieldCandidate? mfg}) _extractDateCandidates(
    String text,
  ) {
    FieldCandidate? expiry;
    FieldCandidate? mfg;
    DateTime? mfgDateForDerivation;

    // Dates found on lines with NO exp/mfg keyword anywhere near them.
    // Indian packs frequently print two bare dates ("25/04/2026" over
    // "21/10/2026") and rely on the reader to know earlier = made,
    // later = expires — resolved after the line scan, mirroring that
    // human inference, instead of blindly calling every bare date an
    // expiry (which could surface the MFG date as the expiry).
    final unlabeled = <({DateTime date, String raw, double confidence})>[];

    // Highest-confidence, explicitly-prefixed matches first.
    for (final m in _expPrefixNumeric.allMatches(text)) {
      final date = _numericDmy(m.group(1)!, m.group(2)!, m.group(3)!);
      if (date != null) {
        expiry = _preferHigher(expiry, FieldCandidate(
          field: LabelField.expiryDate,
          value: _iso(date),
          raw: m.group(0)!.trim(),
          confidence: 0.92,
        ));
      }
    }
    for (final m in _mfgPrefixNumeric.allMatches(text)) {
      final date = _numericDmy(m.group(1)!, m.group(2)!, m.group(3)!);
      if (date != null) {
        mfg = _preferHigher(mfg, FieldCandidate(
          field: LabelField.mfgDate,
          value: _iso(date),
          raw: m.group(0)!.trim(),
          confidence: 0.9,
        ));
        mfgDateForDerivation ??= date;
      }
    }

    // OCR-noise fallback for the two prefixed patterns above: only fires
    // when the strict digit-only regex didn't already match/parse a date
    // AND normalization actually changed something, so clean input never
    // pays the confidence penalty or gets a spurious "corrected" label.
    for (final m in _expPrefixNumericNoisy.allMatches(text)) {
      final result = _numericDmyOcrAware(m.group(1)!, m.group(2)!, m.group(3)!);
      if (result != null && result.wasNormalized) {
        expiry = _preferHigher(expiry, FieldCandidate(
          field: LabelField.expiryDate,
          value: _iso(result.date),
          raw: m.group(0)!.trim(),
          confidence: 0.92 * 0.95,
          derivedFrom: 'ocr-normalized: ${m.group(0)!.trim()}',
        ));
      }
    }
    for (final m in _mfgPrefixNumericNoisy.allMatches(text)) {
      final result = _numericDmyOcrAware(m.group(1)!, m.group(2)!, m.group(3)!);
      if (result != null && result.wasNormalized) {
        mfg = _preferHigher(mfg, FieldCandidate(
          field: LabelField.mfgDate,
          value: _iso(result.date),
          raw: m.group(0)!.trim(),
          confidence: 0.9 * 0.95,
          derivedFrom: 'ocr-normalized: ${m.group(0)!.trim()}',
        ));
        mfgDateForDerivation ??= result.date;
      }
    }

    // Line-scoped fallbacks: a date on a line containing an EXP/MFG keyword
    // but not immediately prefixing it (e.g. "Best Before: see cap — 15 JAN
    // 2026"), then unprefixed dates as a last resort (assumed expiry, since
    // that's the field users scan for far more often than MFG).
    for (final line in text.split('\n')) {
      // Pricing/contact/regulatory boilerplate can contain date-shaped
      // digit runs (an MRP tax code, a phone number, a PIN) — never let
      // those reach the date regexes below.
      if (_isExcludedLine(line)) continue;

      final hasExpWord = _expIndicator.hasMatch(line);
      final hasMfgWord = _mfgIndicator.hasMatch(line);

      final iso = _isoDate.firstMatch(line);
      DateTime? isoDate;
      String? isoRaw;
      String? isoDerivedFrom;
      double isoConfidence = 0.88;
      if (iso != null) {
        isoDate = _isoYmd(iso.group(1)!, iso.group(2)!, iso.group(3)!);
        isoRaw = iso.group(0)!.trim();
      } else {
        final isoNoisy = _isoDateNoisy.firstMatch(line);
        if (isoNoisy != null) {
          final result = _isoYmdOcrAware(
            isoNoisy.group(1)!,
            isoNoisy.group(2)!,
            isoNoisy.group(3)!,
          );
          if (result != null && result.wasNormalized) {
            isoDate = result.date;
            isoRaw = isoNoisy.group(0)!.trim();
            isoDerivedFrom = 'ocr-normalized: $isoRaw';
            isoConfidence = 0.88 * 0.95;
          }
        }
      }
      if (isoDate != null) {
        final date = isoDate;
        if (hasMfgWord) {
          mfg = _preferHigher(mfg, FieldCandidate(
            field: LabelField.mfgDate,
            value: _iso(date),
            raw: isoRaw!,
            confidence: isoConfidence,
            derivedFrom: isoDerivedFrom,
          ));
          mfgDateForDerivation ??= date;
        } else if (hasExpWord) {
          expiry = _preferHigher(expiry, FieldCandidate(
            field: LabelField.expiryDate,
            value: _iso(date),
            raw: isoRaw!,
            confidence: isoConfidence,
            derivedFrom: isoDerivedFrom,
          ));
        } else {
          unlabeled.add((
            date: date,
            raw: isoRaw!,
            confidence: isoConfidence,
          ));
        }
      }

      // Try every candidate match on the line, not just the first — a
      // leading keyword like "EXP"/"MFG" is itself 3 letters and can
      // otherwise get greedily consumed as a fake month name, silently
      // hiding the real month-name date later in the same line.
      for (final monthNameMatch in _monthName.allMatches(line)) {
        final date = _monthNameDate(monthNameMatch);
        if (date != null) {
          if (!hasExpWord && !hasMfgWord) {
            unlabeled.add((
              date: date,
              raw: monthNameMatch.group(0)!.trim(),
              confidence: 0.75,
            ));
            continue;
          }
          final candidate = FieldCandidate(
            field: hasMfgWord && !hasExpWord
                ? LabelField.mfgDate
                : LabelField.expiryDate,
            value: _iso(date),
            raw: monthNameMatch.group(0)!.trim(),
            confidence: 0.85,
          );
          if (hasMfgWord && !hasExpWord) {
            mfg = _preferHigher(mfg, candidate);
            mfgDateForDerivation ??= date;
          } else {
            expiry = _preferHigher(expiry, candidate);
          }
        }
      }

      final bareDmy = _bareDmy.firstMatch(line);
      DateTime? bareDmyDate;
      String? bareDmyRaw;
      String? bareDmyDerivedFrom;
      double bareDmyConfidence = 0.8;
      double bareDmyUnlabeledConfidence = 0.65;
      if (bareDmy != null) {
        bareDmyDate = _numericDmy(
          bareDmy.group(1)!,
          bareDmy.group(2)!,
          bareDmy.group(3)!,
        );
        bareDmyRaw = bareDmy.group(0)!.trim();
      } else {
        final bareDmyNoisy = _bareDmyNoisy.firstMatch(line);
        if (bareDmyNoisy != null) {
          final result = _numericDmyOcrAware(
            bareDmyNoisy.group(1)!,
            bareDmyNoisy.group(2)!,
            bareDmyNoisy.group(3)!,
          );
          if (result != null && result.wasNormalized) {
            bareDmyDate = result.date;
            bareDmyRaw = bareDmyNoisy.group(0)!.trim();
            bareDmyDerivedFrom = 'ocr-normalized: $bareDmyRaw';
            bareDmyConfidence = 0.8 * 0.95;
            bareDmyUnlabeledConfidence = 0.65 * 0.95;
          }
        }
      }
      if (bareDmyDate != null) {
        final date = bareDmyDate;
        if (!hasExpWord && !hasMfgWord) {
          unlabeled.add((
            date: date,
            raw: bareDmyRaw!,
            confidence: bareDmyUnlabeledConfidence,
          ));
        } else {
          final candidate = FieldCandidate(
            field: hasMfgWord && !hasExpWord
                ? LabelField.mfgDate
                : LabelField.expiryDate,
            value: _iso(date),
            raw: bareDmyRaw!,
            confidence: bareDmyConfidence,
            derivedFrom: bareDmyDerivedFrom,
          );
          if (hasMfgWord && !hasExpWord) {
            mfg = _preferHigher(mfg, candidate);
            mfgDateForDerivation ??= date;
          } else {
            expiry = _preferHigher(expiry, candidate);
          }
        }
      }

      final monthYear = _monthYear.firstMatch(line);
      if (monthYear != null && bareDmy == null) {
        final date = _monthYearEnd(monthYear.group(1)!, monthYear.group(2)!);
        if (date != null) {
          if (!hasExpWord && !hasMfgWord) {
            unlabeled.add((
              date: date,
              raw: monthYear.group(0)!.trim(),
              confidence: 0.7,
            ));
          } else {
            final candidate = FieldCandidate(
              field: hasMfgWord && !hasExpWord
                  ? LabelField.mfgDate
                  : LabelField.expiryDate,
              value: _iso(date),
              raw: monthYear.group(0)!.trim(),
              confidence: 0.7,
            );
            if (hasMfgWord && !hasExpWord) {
              mfg = _preferHigher(mfg, candidate);
            } else {
              expiry = _preferHigher(expiry, candidate);
            }
          }
        }
      }
    }

    // Resolve the unlabeled pool. Two or more distinct bare dates → infer
    // earliest = manufacturing, latest = expiry (how a human reads an
    // Indian pack that prints both without keywords). Deliberately lower
    // confidence than any keyword-labelled match so explicit labels always
    // win; high enough (>0.6 with frame agreement) to surface in the UI.
    // A single bare date keeps the long-standing "assume expiry" behavior —
    // that's the field users scan for far more often than MFG.
    if (unlabeled.isNotEmpty) {
      unlabeled.sort((a, b) => a.date.compareTo(b.date));
      final earliest = unlabeled.first;
      final latest = unlabeled.last;
      final distinct = !_sameDay(earliest.date, latest.date);

      if (distinct) {
        mfg = _preferHigher(mfg, FieldCandidate(
          field: LabelField.mfgDate,
          value: _iso(earliest.date),
          raw: earliest.raw,
          confidence: 0.68,
          derivedFrom: 'inferred: earlier of ${unlabeled.length} '
              'unlabeled dates',
        ));
        mfgDateForDerivation ??= earliest.date;
        expiry = _preferHigher(expiry, FieldCandidate(
          field: LabelField.expiryDate,
          value: _iso(latest.date),
          raw: latest.raw,
          confidence: 0.72,
          derivedFrom: 'inferred: later of ${unlabeled.length} '
              'unlabeled dates',
        ));
      } else {
        expiry = _preferHigher(expiry, FieldCandidate(
          field: LabelField.expiryDate,
          value: _iso(latest.date),
          raw: latest.raw,
          confidence: latest.confidence,
        ));
      }
    }

    // Shelf-life duration ("best before 6 months from MFG") combined with a
    // manufacturing date found in the same transcript — only synthesize a
    // derived expiry if no direct expiry match already won on confidence.
    final durationMatch = _shelfLifeDuration.firstMatch(text);
    if (durationMatch != null && mfgDateForDerivation != null) {
      final quantity = int.tryParse(durationMatch.group(1)!);
      final unit = durationMatch.group(2)!.toLowerCase();
      if (quantity != null) {
        final derived = _addDuration(mfgDateForDerivation, quantity, unit);
        if (derived != null) {
          final candidate = FieldCandidate(
            field: LabelField.expiryDate,
            value: _iso(derived),
            raw: durationMatch.group(0)!.trim(),
            confidence: 0.8,
            derivedFrom:
                'MFG ${_iso(mfgDateForDerivation)} + $quantity $unit',
          );
          expiry = _preferHigher(expiry, candidate);
        }
      }
    }

    return (expiry: expiry, mfg: mfg);
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static FieldCandidate? _preferHigher(
    FieldCandidate? current,
    FieldCandidate candidate,
  ) {
    if (current == null || candidate.confidence > current.confidence) {
      return candidate;
    }
    return current;
  }

  static DateTime? _addDuration(DateTime from, int quantity, String unit) {
    if (unit.startsWith('day')) return from.add(Duration(days: quantity));
    if (unit.startsWith('week')) return from.add(Duration(days: quantity * 7));
    if (unit.startsWith('month')) {
      final totalMonths = from.month - 1 + quantity;
      final year = from.year + totalMonths ~/ 12;
      final month = totalMonths % 12 + 1;
      final lastDay = DateTime(year, month + 1, 0).day;
      return DateTime(year, month, from.day > lastDay ? lastDay : from.day);
    }
    if (unit.startsWith('year')) {
      return DateTime(from.year + quantity, from.month, from.day);
    }
    return null;
  }

  /// Resolves a possibly-2-digit year to whichever century puts it closest
  /// to today. A fixed pivot (e.g. "<50 => 2000s") silently mis-resolves any
  /// date near the pivot and any genuinely old manufacturing year; anchoring
  /// to "now" instead means the interpretation is always the most plausible
  /// one for a product being scanned today.
  static int _resolveYear(int rawYear) {
    if (rawYear >= 100) return rawYear;
    final nowYear = DateTime.now().year;
    final candidate1900 = 1900 + rawYear;
    final candidate2000 = 2000 + rawYear;
    final d1900 = (nowYear - candidate1900).abs();
    final d2000 = (nowYear - candidate2000).abs();
    return d2000 <= d1900 ? candidate2000 : candidate1900;
  }

  static DateTime? _numericDmy(String d, String m, String y) {
    try {
      final day = int.parse(d);
      final month = int.parse(m);
      final year = _resolveYear(int.parse(y));
      if (month < 1 || month > 12 || day < 1 || day > 31) return null;
      final date = DateTime(year, month, day);
      // DateTime silently rolls over invalid days (e.g. Feb 30 -> Mar 2) —
      // reject anything that didn't round-trip to the values we parsed.
      if (date.year != year || date.month != month || date.day != day) {
        return null;
      }
      return date;
    } catch (_) {
      return null;
    }
  }

  static DateTime? _isoYmd(String y, String m, String d) {
    try {
      final year = int.parse(y);
      final month = int.parse(m);
      final day = int.parse(d);
      if (month < 1 || month > 12 || day < 1 || day > 31) return null;
      final date = DateTime(year, month, day);
      if (date.year != year || date.month != month || date.day != day) {
        return null;
      }
      return date;
    } catch (_) {
      return null;
    }
  }

  static DateTime? _monthNameDate(RegExpMatch match) {
    final monthToken = match.group(2);
    if (monthToken == null || monthToken.length < 3) return null;
    final month = _monthAbbreviations[monthToken.toLowerCase().substring(0, 3)];
    if (month == null) return null;

    final dayGroup = match.group(1);
    final day = dayGroup != null ? int.tryParse(dayGroup) : null;
    if (day != null && (day < 1 || day > 31)) return null;

    final rawYear = int.tryParse(match.group(3) ?? '');
    if (rawYear == null) return null;
    final year = _resolveYear(rawYear);

    try {
      return DateTime(year, month, day ?? 1);
    } catch (_) {
      return null;
    }
  }

  static DateTime? _monthYearEnd(String m, String y) {
    try {
      final month = int.parse(m);
      final year = _resolveYear(int.parse(y));
      if (month < 1 || month > 12) return null;
      // Bare "MM/YYYY" has no day — treat as valid through month-end, the
      // standard "best before" convention for month-year-only dates.
      return DateTime(year, month + 1, 0);
    } catch (_) {
      return null;
    }
  }

  static String _iso(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  // ─── Batch / lot / SKU ──────────────────────────────────────────────────

  static final RegExp _batchPattern = RegExp(
    r'(?:BATCH|LOT)\s*(?:NO\.?|NUMBER|#)?[:\s]+([A-Z0-9][A-Z0-9\-\/]{2,19})',
    caseSensitive: false,
  );
  static final RegExp _skuPattern = RegExp(
    r'(?:SKU|PRODUCT\s*ID|ITEM\s*(?:NO\.?|CODE))[:\s]+([A-Z0-9][A-Z0-9\-\/]{2,19})',
    caseSensitive: false,
  );

  static FieldCandidate? _extractBatch(String text) {
    final m = _batchPattern.firstMatch(text);
    if (m == null) return null;
    final code = m.group(1)!.toUpperCase();
    return FieldCandidate(
      field: LabelField.batchNumber,
      value: code,
      raw: m.group(0)!.trim(),
      confidence: 0.85,
    );
  }

  static FieldCandidate? _extractSku(String text) {
    final m = _skuPattern.firstMatch(text);
    if (m == null) return null;
    final code = m.group(1)!.toUpperCase();
    return FieldCandidate(
      field: LabelField.skuOrProductId,
      value: code,
      raw: m.group(0)!.trim(),
      confidence: 0.85,
    );
  }

  // ─── Nutrition ──────────────────────────────────────────────────────────

  static final Map<String, RegExp> _nutrientPatterns = {
    'energy': RegExp(
      r'(?:ENERGY|CALORIES)[:\s]+(\d+(?:\.\d+)?)\s*(K?CAL)?',
      caseSensitive: false,
    ),
    'protein': RegExp(r'PROTEINS?[:\s]+(\d+(?:\.\d+)?)\s*(G|MG)?', caseSensitive: false),
    'fat': RegExp(
      r'(?:TOTAL\s*FAT|FAT)[:\s]+(\d+(?:\.\d+)?)\s*(G|MG)?',
      caseSensitive: false,
    ),
    'carbohydrate': RegExp(
      r'CARBOHYDRATES?[:\s]+(\d+(?:\.\d+)?)\s*(G|MG)?',
      caseSensitive: false,
    ),
    'sugar': RegExp(r'SUGARS?[:\s]+(\d+(?:\.\d+)?)\s*(G|MG)?', caseSensitive: false),
    'sodium': RegExp(r'SODIUM[:\s]+(\d+(?:\.\d+)?)\s*(MG|G)?', caseSensitive: false),
    'potassium': RegExp(r'POTASSIUM[:\s]+(\d+(?:\.\d+)?)\s*(MG|G)?', caseSensitive: false),
  };

  static FieldCandidate? _extractNutrition(String text) {
    final found = <String, String>{};
    for (final entry in _nutrientPatterns.entries) {
      final m = entry.value.firstMatch(text);
      if (m == null) continue;
      final value = m.group(1)!;
      final unit = (m.groupCount >= 2 ? m.group(2) : null)?.toLowerCase() ??
          (entry.key == 'energy' ? 'kcal' : 'g');
      found[entry.key] = '$value$unit';
    }
    if (found.isEmpty) return null;
    // Encode as "key=value;key=value" so it fits the single-string
    // FieldCandidate.value contract the consensus aggregator compares on —
    // the scanner screen decodes this back into a map for display/accept.
    final encoded = (found.entries.toList()..sort((a, b) => a.key.compareTo(b.key)))
        .map((e) => '${e.key}=${e.value}')
        .join(';');
    return FieldCandidate(
      field: LabelField.nutrition,
      value: encoded,
      raw: found.entries.map((e) => '${e.key}: ${e.value}').join(', '),
      confidence: 0.75,
    );
  }

  /// Decodes the encoded nutrition value back into a nutrient→display map.
  static Map<String, String> decodeNutrition(String encoded) {
    if (encoded.isEmpty) return const {};
    final result = <String, String>{};
    for (final pair in encoded.split(';')) {
      final idx = pair.indexOf('=');
      if (idx < 0) continue;
      result[pair.substring(0, idx)] = pair.substring(idx + 1);
    }
    return result;
  }
}

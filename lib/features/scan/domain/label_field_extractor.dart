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

  // Unit alternatives are ordered longest-first within each alternation
  // (MILLIGRAMS before MG before G, etc.) so the regex engine can't lock
  // onto a short prefix of a longer spelled-out word.
  static const String _massUnit =
      r'MILLIGRAMS?|MILLILIT(?:RE|ER)S?|MG|ML|GRAMS?|G';
  static const String _energyUnit = r'KILOCALORIES?|CALORIES?|KCAL|K?CAL';

  // Value span accepts the OCR-confusable letters (O→0, S→5, I/l/|→1,
  // B→8, Z→2) in place of digits, then [normalizeOcrDigits] repairs them
  // before parsing — the same recovery the DATE extractor already relies on.
  // Without this, a curved-bottle read of "PROTEIN 0 g" as "PROTEIN O g"
  // (or "11.5" as "11.S") silently failed `tryParse` and dropped the whole
  // nutrient, which is exactly why the auto nutrition table came up empty.
  // Value span: MUST start with an actual digit [0-9] to prevent trailing
  // letters in keyword matches (FAT**S**, SUGAR**S**) from being parsed as
  // numbers (S→5).  Subsequent characters may be OCR-confused letters so
  // that "4S"→45 and "11.S"→11.5 still work after [normalizeOcrDigits].
  static const String _nutrientValueClass = r'[0-9][0-9OoSsIl|BZ]*(?:\.[0-9OoSsIl|BZ]+)?';

  static final Map<String, RegExp> _nutrientPatterns = {
    'energy': RegExp(
      r'(?:ENER\s*GY|CAL\s*ORIES)[:\s]*('
          '$_nutrientValueClass' r')\s*(' '$_energyUnit' r')?',
      caseSensitive: false,
    ),
    'protein': RegExp(
      r'PROTEINS?[:\s]*(' '$_nutrientValueClass' r')\s*(' '$_massUnit' r')?',
      caseSensitive: false,
    ),
    'fat': RegExp(
      r'(?:TOTAL\s*FAT|FAT)[:\s]*(' '$_nutrientValueClass' r')\s*('
          '$_massUnit' r')?',
      caseSensitive: false,
    ),
    'carbohydrate': RegExp(
      r'CARBOHYDRATES?[:\s]*(' '$_nutrientValueClass' r')\s*('
          '$_massUnit' r')?',
      caseSensitive: false,
    ),
    'sugar': RegExp(
      r'(?:ADDED\s*)?SUGARS?[:\s]*(' '$_nutrientValueClass' r')\s*('
          '$_massUnit' r')?',
      caseSensitive: false,
    ),
    'sodium': RegExp(
      r'(?:SO\s*[OD]IUM|SOO[ID]IUM|SODIUM)[:\s]*(' '$_nutrientValueClass'
          r')\s*(' '$_massUnit' r')?',
      caseSensitive: false,
    ),
    'potassium': RegExp(
      r'POTASSIUM[:\s]*(' '$_nutrientValueClass' r')\s*(' '$_massUnit'
          r')?',
      caseSensitive: false,
    ),
  };

  /// Normalizes any recognized spelling ("gram", "Grams", "MILLILITRE",
  /// "Kcal", "calories", …) down to the short canonical unit everything
  /// downstream (bounds checking, display, payload building) expects.
  static String _normalizeUnit(String? raw, String key) {
    if (raw == null || raw.isEmpty) return key == 'energy' ? 'kcal' : 'g';
    final u = raw.toUpperCase();
    if (u.startsWith('KCAL') || u.startsWith('KILOCAL') || u.contains('CAL')) {
      return 'kcal';
    }
    if (u.startsWith('MG') || u.startsWith('MILLIGRAM')) return 'mg';
    if (u.startsWith('ML') || u.startsWith('MILLILIT')) return 'ml';
    return 'g';
  }

  /// A real nutrition PANEL is a multi-column table (nutrient name | per
  /// 100g/ml | %RDA); OCR frequently doesn't preserve strict row order
  /// when it flattens that table to text (columns can come out grouped
  /// together rather than row-by-row). Matching a nutrient's regex
  /// against the WHOLE flattened transcript let a pattern's "next number
  /// after the keyword" skip across a row boundary and grab a completely
  /// different nutrient's value — confirmed live: "TOTAL FAT" matched
  /// Sodium's "5mg" because Fat's own "0g" wasn't the next digit run in
  /// the flattened order. Restricting each match to a single OCR LINE
  /// (still `\n`-joined per ML Kit's own line segmentation) means a
  /// nutrient can only match its OWN row's value, never a neighbour's.
  static bool _isPlausibleNutrientValue(String key, double value, String unit) {
    if (key == 'energy') return value >= 0 && value <= 900;
    // Every other tracked nutrient is reported per 100g/100ml — its own
    // gram-equivalent value can never reach 100 (that's the basis itself,
    // not a nutrient amount).  Using < 100 (not <=) also excludes the
    // "PER 100 G/ML" header line that OCR frequently picks up as a
    // standalone "100" number.
    final asGrams = unit == 'mg' ? value / 1000 : value;
    return asGrams >= 0 && asGrams < 100;
  }

  /// Standard nutrient ordering on Indian FSSAI labels. Used for positional
  /// inference when OCR garbles a keyword beyond regex recognition but the
  /// value (number) is still readable on an adjacent line.
  static const List<String> _standardNutrientOrder = [
    'energy', 'protein', 'carbohydrate', 'sugar', 'fat', 'sodium',
  ];

  /// Maps OCR-corrupted keyword fragments back to canonical nutrient keys.
  /// Keys are uppercased, spaces stripped — applied AFTER the same
  /// compaction the line-scoped pass uses.
  static final Map<RegExp, String> _fuzzyKeywordPatterns = {
    // ENERGY: OCR often reads C for G → ENERCY
    RegExp(r'ENERC[GY]'): 'energy',
    RegExp(r'CALOR[IE]S'): 'energy',
    RegExp(r'K?CAL'): 'energy',
    // PROTEIN
    RegExp(r'PROTEI[N]'): 'protein',
    RegExp(r'PROT[EI]N'): 'protein',
    // CARBOHYDRATE: OCR reads G for B → CARGOHYDRATE
    RegExp(r'CARBOH[YE]D[RA]TE'): 'carbohydrate',
    RegExp(r'CARB[O0]H[YE]DR[AT]E'): 'carbohydrate',
    RegExp(r'CAR[GB][OH]H[YE]DR[AT]E'): 'carbohydrate',
    // SUGAR / TOTAL SUGARS / ADDED SUGARS
    RegExp(r'SUGA[RS]'): 'sugar',
    RegExp(r'SU[KG]AR[RS]'): 'sugar',
    // FAT
    RegExp(r'TOTAL\s*FA[KT]'): 'fat',
    RegExp(r'FA[KT]'): 'fat',
    // SODIUM: severely corrupted readings (SMJM, SODIUM, SOOIUM, etc.)
    RegExp(r'S[O0D][I1L][U]?[M]'): 'sodium',
    RegExp(r'SM[JM]M'): 'sodium',
    RegExp(r'S[O0]DIU[M]'): 'sodium',
  };

  /// Tries to match [text] (already uppercased, spaces stripped) against
  /// the fuzzy keyword patterns.  Returns the canonical nutrient key or
  /// null.
  static String? _fuzzyNutrientKey(String compact) {
    for (final entry in _fuzzyKeywordPatterns.entries) {
      if (entry.key.hasMatch(compact)) return entry.value;
    }
    return null;
  }

  /// Minimal Levenshtein distance — used only as a last-resort keyword
  /// check when fuzzy regex patterns don't fire.
  static int _levenshtein(String a, String b) {
    final m = a.length, n = b.length;
    final dp = List.generate(m + 1, (i) => List<int>.filled(n + 1, 0));
    for (var i = 0; i <= m; i++) dp[i][0] = i;
    for (var j = 0; j <= n; j++) dp[0][j] = j;
    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1,
          dp[i][j - 1] + 1,
          dp[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    return dp[m][n];
  }

  /// Known nutrient keywords for Levenshtein fallback.
  static final Map<String, String> _canonicalKeywords = {
    'energy': 'ENERGY',
    'protein': 'PROTEIN',
    'carbohydrate': 'CARBOHYDRATE',
    'sugar': 'SUGAR',
    'fat': 'FAT',
    'sodium': 'SODIUM',
  };

  /// Extracts the leading numeric portion from [text], applying OCR-digit
  /// recovery.  Returns `(value, unit)` or null.
  /// The match MUST start with an actual digit `[0-9]` — not an
  /// OCR-confused letter (O, S, I, l, B, Z).  This prevents single
  /// letters inside words from being parsed as numbers (e.g. "O" in
  /// "CARGOHYDRATE" → 0, "S" in "SMJM" → 5, "IO" in "IONAL" → 10),
  /// which was the dominant source of wrong nutrition values on
  /// curved-bottle labels.  The trailing OCR-confused characters ARE
  /// accepted so that "4S" → 45, "11.S" → 11.5 still work.
  static ({double value, String unit})? _parseNumber(String text, String nutrientKey) {
    final m = RegExp(r'(?:^|[^A-Z])([0-9][0-9OoSsIl|BZ]*(?:\.[0-9OoSsIl|BZ]+)?)'
            r'\s*(MG|G|ML|KCAL|KILOCALORIES?|CALORIES?)?')
        .firstMatch(text);
    if (m == null) return null;
    final repaired = normalizeOcrDigits(m.group(1)!) ?? m.group(1)!;
    final value = double.tryParse(repaired);
    if (value == null) return null;
    final unit = _normalizeUnit(m.group(2), nutrientKey);
    if (!_isPlausibleNutrientValue(nutrientKey, value, unit)) return null;
    return (value: value, unit: unit);
  }

  static FieldCandidate? _extractNutrition(String text) {
    final lines = text.split('\n');
    final found = <String, String>{};

    // ── Pass 1: Line-scoped exact matching (fast, handles clean OCR) ──
    for (final entry in _nutrientPatterns.entries) {
      for (final line in lines) {
        final compact = line.replaceAll(RegExp(r'\s+'), '').toUpperCase();
        final m = entry.value.firstMatch(compact);
        if (m == null) continue;
        final rawValue = m.group(1)!;
        final repaired = normalizeOcrDigits(rawValue) ?? rawValue;
        final value = double.tryParse(repaired);
        if (value == null) continue;
        final unit =
            _normalizeUnit(m.groupCount >= 2 ? m.group(2) : null, entry.key);
        if (!_isPlausibleNutrientValue(entry.key, value, unit)) continue;
        final display = value.truncateToDouble() == value
            ? value.toInt().toString()
            : value.toString();
        found[entry.key] = '$display$unit';
        break;
      }
    }

    // If Pass 1 found ≥ 4 nutrients the table is probably readable; skip
    // the expensive fuzzy / cross-line passes.
    if (found.length >= 4) {
      return _encodeNutrition(found);
    }

    // ── Pass 2: Fuzzy keyword matching per line ────────────────────────
    // Builds a map of nutrient-key → (line-index, line-text) for every
    // line where a fuzzy keyword was recognised, even if no value was on
    // the same line.
    final Map<String, ({int index, String line})> fuzzyKeywords = {};
    final Map<int, ({double value, String unit})?> orphanNumbers = {};

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final compact = line.replaceAll(RegExp(r'\s+'), '').toUpperCase();
      if (compact.isEmpty) continue;

      final nutrientKey = _fuzzyNutrientKey(compact);

      // Also try Levenshtein ≤ 2 against canonical keywords as a
      // last resort for very severely garbled readings (SMJM, etc.).
      String? matchedKey = nutrientKey;
      if (matchedKey == null && compact.length >= 3) {
        for (final entry in _canonicalKeywords.entries) {
          if (_levenshtein(compact, entry.value) <= 2) {
            matchedKey = entry.key;
            break;
          }
        }
      }

      if (matchedKey != null && !found.containsKey(matchedKey)) {
        // Check if there's a value on THIS line (same-line match)
        final parsed = _parseNumber(line, matchedKey);
        if (parsed != null) {
          final display = parsed.value.truncateToDouble() == parsed.value
              ? parsed.value.toInt().toString()
              : parsed.value.toString();
          found[matchedKey] = '$display${parsed.unit}';
        } else {
          fuzzyKeywords[matchedKey] = (index: i, line: line);
        }
      } else if (nutrientKey == null) {
        // Line has no keyword — check if it's a standalone number
        final parsed = _parseNumber(line, '');
        if (parsed != null) {
          orphanNumbers[i] = parsed;
        }
      }
    }

    // ── Pass 3: Cross-line value association ───────────────────────────
    // Keywords and values are on SEPARATE lines (confirmed on I2217:
    // "ENERCY" on one line, "46 kca" on the line above). Match them
    // using the STANDARD TABLE ORDER rather than line proximity, because
    // OCR on a curved bottle fragments the table so badly that numbers
    // cluster together while keywords scatter — proximity matching picks
    // the wrong number every time.
    if (fuzzyKeywords.isNotEmpty && orphanNumbers.isNotEmpty) {
      // Collect orphan numbers in line order
      final sortedOrphans = orphanNumbers.entries
          .where((e) => e.value != null)
          .toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      final orphanValues =
          sortedOrphans.map((e) => e.value!).toList();

      // Assign orphan numbers to fuzzy keywords in standard table order.
      // First orphan number → first nutrient in table order, etc.
      var orphanIdx = 0;
      for (final nutrientKey in _standardNutrientOrder) {
        if (found.containsKey(nutrientKey)) continue;
        if (!fuzzyKeywords.containsKey(nutrientKey)) continue;
        if (orphanIdx >= orphanValues.length) break;
        final parsed = orphanValues[orphanIdx++];
        final display = parsed.value.truncateToDouble() == parsed.value
            ? parsed.value.toInt().toString()
            : parsed.value.toString();
        found[nutrientKey] = '$display${parsed.unit}';
      }
    }

    // ── Pass 4: Positional inference ───────────────────────────────────
    // If we have at least 2 confirmed nutrients and orphan numbers
    // remain, use the standard Indian FSSAI table order to assign them.
    if (found.length >= 2) {
      final unmatchedKeys = _standardNutrientOrder
          .where((k) => !found.containsKey(k))
          .toList();
      final remainingNumbers = orphanNumbers.entries
          .where((e) => e.value != null)
          .toList()
        ..sort((a, b) => a.key.compareTo(b.key)); // by line index

      for (var ni = 0;
          ni < unmatchedKeys.length && ni < remainingNumbers.length;
          ni++) {
        final parsed = remainingNumbers[ni].value!;
        final display = parsed.value.truncateToDouble() == parsed.value
            ? parsed.value.toInt().toString()
            : parsed.value.toString();
        found[unmatchedKeys[ni]] = '$display${parsed.unit}';
      }
    }

    if (found.isEmpty) return null;
    return _encodeNutrition(found);
  }

  static FieldCandidate _encodeNutrition(Map<String, String> found) {
    final encoded = (found.entries.toList()
              ..sort((a, b) => a.key.compareTo(b.key)))
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

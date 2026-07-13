import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';

import 'expiry_csv_row.dart';

/// File-level problem that prevents parsing from proceeding at all —
/// as opposed to a row-level problem, which becomes an
/// [ExpiryCsvRowStatus.invalid] row instead of throwing.
class ExpiryCsvParseException implements Exception {
  const ExpiryCsvParseException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Parses a bulk expiry-import CSV into [ExpiryCsvRow]s.
///
/// Validation mirrors the backend's `CreateProductSchema` (ean, name) and
/// `CreateExpiryRecordSchema` (dates, batch, quantity, location) constraints
/// so a row that passes here won't fail server-side during save — see
/// `expiry_csv_review_screen.dart`'s `_save()`.
class ExpiryCsvParser {
  ExpiryCsvParser._();

  /// Hard cap on data rows (header excluded) — keeps the sequential
  /// per-row save loop's wall-clock time reasonable.
  static const int maxRows = 500;

  /// Canonical header name -> accepted synonyms (all matched
  /// case/whitespace-normalized). A CSV must supply exactly one column
  /// matching each key in [_requiredHeaders] under any of its aliases.
  static const Map<String, List<String>> _headerAliases = {
    'ean': ['ean', 'barcode', 'ean_barcode'],
    'product_name': ['product_name', 'name', 'product'],
    'manufacture_date': ['manufacture_date', 'mfg_date', 'manufactured_date'],
    'expiry_date': ['expiry_date', 'exp_date', 'expiration_date'],
    'batch_number': ['batch_number', 'batch', 'batch_no'],
    'quantity': ['quantity', 'qty'],
    'location': ['location', 'shelf_location', 'area'],
  };

  static const List<String> _requiredHeaders = [
    'ean',
    'product_name',
    'expiry_date',
  ];

  static final RegExp _isoDate = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  /// Throws [ExpiryCsvParseException] for file-level problems (empty file,
  /// a required column entirely missing, more than [maxRows] data rows).
  /// Row-level problems are captured as `status: invalid` entries with a
  /// specific [ExpiryCsvRow.errorReason] — never thrown.
  static List<ExpiryCsvRow> parse(Uint8List bytes) {
    final String text;
    try {
      text = utf8.decode(bytes, allowMalformed: true);
    } catch (_) {
      throw const ExpiryCsvParseException('Could not read this file as text.');
    }
    if (text.trim().isEmpty) {
      throw const ExpiryCsvParseException('The file is empty.');
    }

    final csv = Csv(parseHeaders: true);
    final List<CsvRow> csvRows;
    try {
      csvRows = csv.decodeWithHeaders(text);
    } catch (_) {
      throw const ExpiryCsvParseException(
        'Could not parse this file as CSV — check it is a valid .csv export.',
      );
    }
    if (csvRows.isEmpty) {
      throw const ExpiryCsvParseException(
        'No data rows found below the header.',
      );
    }

    // Map each canonical field name to the actual column index present in
    // this file's header row (matched case/whitespace-insensitively against
    // the alias list above).
    final rawHeaders = csvRows.first.headerMap.keys.toList();
    final normalisedToRaw = <String, String>{
      for (final h in rawHeaders) _normaliseHeader(h): h,
    };
    final canonicalToRaw = <String, String>{};
    for (final entry in _headerAliases.entries) {
      for (final alias in entry.value) {
        final raw = normalisedToRaw[alias];
        if (raw != null) {
          canonicalToRaw[entry.key] = raw;
          break;
        }
      }
    }

    final missing = _requiredHeaders
        .where((h) => !canonicalToRaw.containsKey(h))
        .toList();
    if (missing.isNotEmpty) {
      throw ExpiryCsvParseException(
        'Missing required column(s): ${missing.join(', ')}. '
        'Use the template file for the expected format.',
      );
    }

    // Drop fully-blank trailing rows (common Excel export artifact).
    final dataRows = csvRows.where((row) {
      final map = row.toMap();
      return map.values.any((v) => v != null && v.toString().trim().isNotEmpty);
    }).toList();

    if (dataRows.length > maxRows) {
      throw ExpiryCsvParseException(
        'This file has ${dataRows.length} rows — the maximum supported in '
        'one import is $maxRows. Split it into smaller files.',
      );
    }

    return [
      for (var i = 0; i < dataRows.length; i++)
        _parseRow(dataRows[i], canonicalToRaw, rowNumber: i + 1),
    ];
  }

  static String _normaliseHeader(String raw) =>
      raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');

  static String? _field(CsvRow row, Map<String, String> canonicalToRaw, String canonical) {
    final raw = canonicalToRaw[canonical];
    if (raw == null) return null;
    final value = row[raw];
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  static ExpiryCsvRow _parseRow(
    CsvRow row,
    Map<String, String> canonicalToRaw, {
    required int rowNumber,
  }) {
    final ean = _field(row, canonicalToRaw, 'ean');
    final productName = _field(row, canonicalToRaw, 'product_name');
    final expiryRaw = _field(row, canonicalToRaw, 'expiry_date');
    final mfgRaw = _field(row, canonicalToRaw, 'manufacture_date');
    final batchRaw = _field(row, canonicalToRaw, 'batch_number');
    final qtyRaw = _field(row, canonicalToRaw, 'quantity');
    final locationRaw = _field(row, canonicalToRaw, 'location');

    String? error;

    if (ean == null || ean.length < 6 || ean.length > 20) {
      error ??= ean == null ? 'Missing EAN' : 'Invalid EAN format (must be 6-20 characters)';
    }
    if (productName == null) {
      error ??= 'Missing product name';
    } else if (productName.length > 200) {
      error ??= 'Product name too long (max 200 characters)';
    }

    DateTime? expiryDate;
    if (expiryRaw == null) {
      error ??= 'Missing expiry date';
    } else if (!_isoDate.hasMatch(expiryRaw)) {
      error ??= 'Invalid expiry date "$expiryRaw" (use YYYY-MM-DD)';
    } else {
      expiryDate = DateTime.tryParse(expiryRaw);
      if (expiryDate == null) {
        error ??= 'Invalid expiry date "$expiryRaw"';
      }
    }

    DateTime? mfgDate;
    if (mfgRaw != null) {
      if (!_isoDate.hasMatch(mfgRaw)) {
        error ??= 'Invalid manufacture date "$mfgRaw" (use YYYY-MM-DD)';
      } else {
        mfgDate = DateTime.tryParse(mfgRaw);
        if (mfgDate == null) {
          error ??= 'Invalid manufacture date "$mfgRaw"';
        } else if (expiryDate != null && !expiryDate.isAfter(mfgDate)) {
          error ??= 'Manufacture date must be before expiry date';
        }
      }
    }

    if (batchRaw != null && batchRaw.length > 100) {
      error ??= 'Batch number too long (max 100 characters)';
    }

    int? quantity;
    if (qtyRaw != null) {
      quantity = int.tryParse(qtyRaw);
      if (quantity == null || quantity < 1 || quantity > 100000) {
        error ??= 'Quantity must be a whole number between 1 and 100000';
      }
    }

    if (locationRaw != null && locationRaw.length > 100) {
      error ??= 'Location too long (max 100 characters)';
    }

    return ExpiryCsvRow(
      rowNumber: rowNumber,
      status: error == null ? ExpiryCsvRowStatus.valid : ExpiryCsvRowStatus.invalid,
      ean: ean ?? '',
      productName: productName ?? '',
      expiryDate: expiryDate,
      manufactureDate: mfgDate,
      batchNumber: batchRaw,
      quantity: quantity,
      shelfLocation: locationRaw,
      errorReason: error,
    );
  }
}

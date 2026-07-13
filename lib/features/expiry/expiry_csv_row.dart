/// One parsed row from a bulk expiry-import CSV file.
///
/// [status] is derived at parse time by [ExpiryCsvParser] — this model is
/// otherwise a plain data holder with no validation logic of its own.
enum ExpiryCsvRowStatus { valid, invalid }

class ExpiryCsvRow {
  const ExpiryCsvRow({
    required this.rowNumber,
    required this.status,
    required this.ean,
    required this.productName,
    required this.expiryDate,
    this.manufactureDate,
    this.batchNumber,
    this.quantity,
    this.shelfLocation,
    this.errorReason,
  });

  /// 1-based data-row index (header row excluded) — used for error display.
  final int rowNumber;

  final ExpiryCsvRowStatus status;

  final String ean;
  final String productName;

  /// Null when the expiry date was missing or unparseable — always paired
  /// with [status] == invalid in that case.
  final DateTime? expiryDate;
  final DateTime? manufactureDate;
  final String? batchNumber;
  final int? quantity;
  final String? shelfLocation;

  /// Human-readable reason this row was rejected. Non-null iff
  /// [status] == [ExpiryCsvRowStatus.invalid].
  final String? errorReason;

  bool get isValid => status == ExpiryCsvRowStatus.valid;
}

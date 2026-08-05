// One in-memory Quick Audit session: every product scanned + saved
// during a single camera session, kept in order, until the user taps
// "Finish" and is routed to [AuditSummaryScreen].
//
// Deliberately not persisted/offline-synced on its own — each entry
// mirrors a write that already went through the normal offline outbox
// (`SyncService.enqueue`) when it was saved from the camera sheet. This
// list only exists to build the on-screen running count and the final
// summary/export; losing it (e.g. app killed mid-session) never loses
// data, just the session's own recap.

import 'package:flutter/foundation.dart';

/// One row of the Quick Audit session — snapshot of a product at the
/// moment it was saved, not a live reference to the expiry record (so
/// later edits elsewhere in the app never retroactively change what the
/// session log says was scanned).
@immutable
class AuditSessionEntry {
  const AuditSessionEntry({
    required this.expiryRecordId,
    required this.productName,
    required this.ean,
    required this.expiryDate,
    required this.status,
    required this.quantity,
    required this.previousQuantity,
    required this.scannedAt,
    this.batchNumber,
    this.category,
  });

  final String expiryRecordId;
  final String productName;
  final String? ean;
  final String? expiryDate;

  /// Server status at save time — `green` | `yellow` | `red` | `expired`
  /// | `unknown`. Drives the traffic-light coloring on the summary list
  /// and the Excel export's conditional row highlighting.
  final String? status;

  /// Quantity saved this scan (the new `remainingQuantity`).
  final int quantity;

  /// Quantity before this scan's edit — lets the summary show "12 → 15"
  /// when the user adjusted stock during the audit, or just "12" when
  /// unchanged.
  final int previousQuantity;

  final DateTime scannedAt;
  final String? batchNumber;
  final String? category;

  bool get quantityChanged => quantity != previousQuantity;

  int? get daysLeft {
    final d = expiryDate == null ? null : DateTime.tryParse(expiryDate!);
    if (d == null) return null;
    final today = DateTime.now();
    final dateOnly = DateTime(d.year, d.month, d.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    return dateOnly.difference(todayOnly).inDays;
  }
}

/// Simple in-memory session list — a `ValueNotifier` rather than a
/// Riverpod provider since its lifetime is scoped to one Quick Audit
/// camera session (created when the screen opens, discarded when it
/// closes) and never needs to be watched from outside that screen's
/// widget subtree.
class AuditSessionController extends ValueNotifier<List<AuditSessionEntry>> {
  AuditSessionController() : super(const []);

  void add(AuditSessionEntry entry) {
    value = [...value, entry];
  }

  void clear() {
    value = const [];
  }

  int get count => value.length;
}

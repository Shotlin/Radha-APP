import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../scan/domain/label_field_models.dart';
import '../scan/live_label_scanner_screen.dart';

/// Result of OCR date extraction — may contain one or both dates, plus
/// whatever else the live scanner confirmed on the same label.
///
/// `confidence` mirrors the scanner's combined (pattern × frame-agreement)
/// score at the moment the user accepted — kept so the destination form
/// could, if it wants to, still flag "accepted at N% confidence" even
/// though the scanner screen is gone. Currently only expiry/mfg dates are
/// wired into the expiry-record form; batch number is also carried through
/// since the form already has a field for it.
class OcrDateResult {
  const OcrDateResult({
    this.mfgDate,
    this.expiryDate,
    this.batchNumber,
    this.fieldConfidence = const {},
  });

  final DateTime? mfgDate;
  final DateTime? expiryDate;
  final String? batchNumber;
  final Map<LabelField, double> fieldConfidence;
}

/// Launches the live label scanner and maps its result into the shape the
/// expiry-record form expects.
///
/// Previously this ran a single native-camera photo through one-shot ML Kit
/// OCR with no confidence signal at all — whatever the regex matched was
/// handed straight to the form. The live scanner instead keeps scanning
/// until several independent frames agree (or the user backs out to manual
/// entry), so a wrong single-frame read can no longer reach the form
/// silently — see live_label_scanner_screen.dart for the multi-frame
/// consensus mechanics.
class OcrDateHelper {
  OcrDateHelper._();

  /// Returns `null` if the user cancels without accepting anything.
  static Future<OcrDateResult?> extractDates(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await Navigator.of(context).push<LiveScanResult>(
      MaterialPageRoute(builder: (_) => const LiveLabelScannerScreen()),
    );
    if (result == null) return null;
    if (result.expiryDate == null &&
        result.mfgDate == null &&
        result.batchNumber == null) {
      return null;
    }
    return OcrDateResult(
      mfgDate: result.mfgDate,
      expiryDate: result.expiryDate,
      batchNumber: result.batchNumber,
      fieldConfidence: result.fieldConfidence,
    );
  }
}

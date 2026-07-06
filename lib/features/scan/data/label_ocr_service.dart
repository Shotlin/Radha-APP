import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../utils/ean_validator.dart';

/// Result of running on-device OCR over a captured/picked label photo.
class LabelOcrResult {
  const LabelOcrResult({required this.transcript, required this.candidateEans});

  /// Full recognized text — sent to the backend for Gemini analysis.
  final String transcript;

  /// Valid EAN/UPC numbers found printed in the text (the human-readable digits
  /// beneath a barcode). Lets a damaged/unscannable barcode still resolve via a
  /// normal product lookup.
  final List<String> candidateEans;

  bool get hasText => transcript.trim().isNotEmpty;
}

/// Wraps Google ML Kit text recognition. On-device, free, offline-capable —
/// the first layer of the OCR fallback before any paid AI call.
///
/// Latin-only on-device: the Android build deliberately does not bundle the
/// optional per-script ML Kit models (Devanagari/Chinese/Japanese/Korean —
/// see `android/app/proguard-rules.pro`) to keep APK size down. Calling
/// `TextRecognizer(script: ...)` for an unbundled script throws a native
/// `NoClassDefFoundError` that crashes the whole app before Dart ever sees
/// it — a `try`/`catch` here cannot save it, since the crash happens inside
/// the platform-channel handler on the Android side. So Devanagari (Hindi /
/// Marathi), like Tamil/Telugu/Bengali, relies on the backend Gemini path
/// instead. We never claim a script we can't actually read.
class LabelOcrService {
  static const List<TextRecognitionScript> _scripts = [
    TextRecognitionScript.latin,
  ];

  /// Recognize text from an image file (camera capture or gallery pick).
  Future<LabelOcrResult> recognizeFile(String path) async {
    final input = InputImage.fromFilePath(path);
    final transcripts = <String>[];

    for (final script in _scripts) {
      final recognizer = TextRecognizer(script: script);
      try {
        final recognized = await recognizer.processImage(input);
        if (recognized.text.trim().isNotEmpty) transcripts.add(recognized.text);
      } catch (_) {
        // A failed script pass must not abort the others — the remaining
        // recognizer(s) still contribute their lines.
      } finally {
        await recognizer.close();
      }
    }

    final transcript = _mergeTranscripts(transcripts);
    return LabelOcrResult(
      transcript: transcript,
      candidateEans: extractCandidateEans(transcript),
    );
  }

  /// Merge multiple recognizer passes, de-duplicating identical lines while
  /// preserving order. Currently a single Latin pass, but kept list-shaped
  /// in case another on-device script gets bundled later.
  String _mergeTranscripts(List<String> transcripts) {
    final seen = <String>{};
    final lines = <String>[];
    for (final t in transcripts) {
      for (final raw in t.split('\n')) {
        final line = raw.trim();
        if (line.isEmpty) continue;
        if (seen.add(line.toLowerCase())) lines.add(line);
      }
    }
    return lines.join('\n');
  }
}

/// Extract valid EAN-8 / UPC-A / EAN-13 numbers from OCR'd text.
///
/// Looks at both the raw text (contiguous digit runs) and a de-spaced variant
/// (ML Kit sometimes splits the printed digits with spaces), validates each
/// candidate with the GS1 checksum, and returns the unique valid codes.
List<String> extractCandidateEans(String text) {
  final found = <String>{};
  final runRe = RegExp(r'\d{8,14}');

  void scan(String source) {
    for (final m in runRe.allMatches(source)) {
      final run = m.group(0)!;
      // A 14-digit run may be an ITF-14 carton code wrapping an EAN-13.
      for (final len in const [13, 12, 8]) {
        if (run.length >= len) {
          final candidate = run.substring(0, len);
          if (isValidEan(candidate)) found.add(candidate);
          final tail = run.substring(run.length - len);
          if (isValidEan(tail)) found.add(tail);
        }
      }
    }
  }

  scan(text);
  scan(text.replaceAll(RegExp(r'[\s-]'), ''));
  return found.toList(growable: false);
}

final labelOcrServiceProvider = Provider<LabelOcrService>(
  (ref) => LabelOcrService(),
);

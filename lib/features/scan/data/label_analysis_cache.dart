import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:radha_app/core/network/dto/ai_dto.dart';

/// In-memory LRU cache of label analyses, keyed by a normalised transcript.
///
/// Re-scanning the same product within the app's lifetime returns instantly and
/// **without another Gemini call** — the single biggest lever on per-user
/// latency and AI cost. The key normalises OCR noise (lowercased, punctuation
/// stripped, unique sorted tokens) so two slightly different photos of the same
/// label collide on the same entry.
///
/// Scope: session/app-lifetime (kept alive, not auto-disposed). Cross-session
/// persistence and a shared server-side cache are natural follow-ups; this
/// layer already removes the common "scanned it twice" cost.
class LabelAnalysisCache {
  LabelAnalysisCache({this.maxEntries = 200, this.ttl = const Duration(days: 7)});

  final int maxEntries;
  final Duration ttl;

  final LinkedHashMap<String, _CacheEntry> _entries =
      LinkedHashMap<String, _CacheEntry>();

  /// Returns a cached analysis for [transcript], or null on miss/expiry.
  LabelTextAnalysis? get(String transcript) {
    final key = _key(transcript);
    if (key.isEmpty) return null;
    final entry = _entries.remove(key);
    if (entry == null) return null;
    if (DateTime.now().difference(entry.storedAt) > ttl) return null;
    // Re-insert to mark most-recently-used.
    _entries[key] = entry;
    return entry.value;
  }

  /// Stores [analysis] for [transcript]. Only worth caching real content.
  void put(String transcript, LabelTextAnalysis analysis) {
    if (!analysis.hasContent) return;
    final key = _key(transcript);
    if (key.isEmpty) return;
    _entries.remove(key);
    _entries[key] = _CacheEntry(analysis, DateTime.now());
    while (_entries.length > maxEntries) {
      _entries.remove(_entries.keys.first); // evict least-recently-used
    }
  }

  void clear() => _entries.clear();

  /// Normalise a transcript to a stable, noise-tolerant key.
  String _key(String transcript) {
    final tokens = transcript
        .toLowerCase()
        // Keep Latin alphanumerics + the Devanagari block; collapse the rest.
        .replaceAll(RegExp(r'[^a-z0-9ऀ-ॿ]+'), ' ')
        .split(' ')
        .where((t) => t.length > 1)
        .toSet()
        .toList()
      ..sort();
    return tokens.join(' ');
  }
}

class _CacheEntry {
  _CacheEntry(this.value, this.storedAt);
  final LabelTextAnalysis value;
  final DateTime storedAt;
}

/// App-lifetime provider (intentionally not auto-disposed) so the cache
/// survives navigation between scans.
final labelAnalysisCacheProvider = Provider<LabelAnalysisCache>(
  (ref) => LabelAnalysisCache(),
);

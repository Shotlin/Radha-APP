import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:radha_app/core/network/dio_provider.dart';
import 'package:radha_app/core/network/dto/ai_dto.dart';

/// Calls `POST /api/v1/ai/label/analyze-text` — the OCR-transcript → Gemini
/// fallback used when a barcode lookup misses.
///
/// Uses the shared [dioProvider] directly (the envelope interceptor already
/// unwraps `{ success, data }`), so this one endpoint doesn't require a
/// retrofit regeneration of the generated `ApiClient`.
class LabelAnalysisRepository {
  LabelAnalysisRepository(this._dio);

  final Dio _dio;

  Future<LabelTextAnalysis> analyzeTranscript({
    required String transcript,
    String locale = 'en',
  }) async {
    final res = await _dio.post<dynamic>(
      '/api/v1/ai/label/analyze-text',
      data: {'transcript': transcript, 'locale': locale},
    );
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return LabelTextAnalysis.fromJson(data);
    }
    // Defensive: an unexpected envelope still yields an honest empty result
    // rather than throwing — the screen renders a "try again" state.
    return const LabelTextAnalysis(
      confidence: 0,
      warnings: ['Unexpected response from the analysis service'],
    );
  }
}

final labelAnalysisRepositoryProvider = Provider<LabelAnalysisRepository>(
  (ref) => LabelAnalysisRepository(ref.watch(dioProvider)),
);

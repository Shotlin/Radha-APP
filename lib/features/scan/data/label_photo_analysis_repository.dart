import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:radha_app/core/network/dio_provider.dart';
import 'package:radha_app/core/network/dto/ai_dto.dart';

/// Calls `POST /api/v1/ai/label/analyze-photo` — the vision-native
/// counterpart to [LabelAnalysisRepository]: sends a photo (already
/// uploaded via [ProductSubmissionRepository.uploadPhotoEarly]) directly to
/// Gemini instead of flattening it to OCR text first, so table structure
/// (a nutrition panel's rows/columns) survives even on a curved or warped
/// label — the fix for wrong/missing nutrition values the on-device
/// flatten-then-regex approach can't reliably recover from.
///
/// Same "bypass retrofit codegen, use `dioProvider` directly" convention as
/// [LabelAnalysisRepository].
class LabelPhotoAnalysisRepository {
  LabelPhotoAnalysisRepository(this._dio);

  final Dio _dio;

  Future<LabelPhotoAnalysis> analyzePhoto({
    required String mediaId,
    String locale = 'en',
  }) async {
    final res = await _dio.post<dynamic>(
      '/api/v1/ai/label/analyze-photo',
      data: {'mediaId': mediaId, 'locale': locale},
    );
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return LabelPhotoAnalysis.fromJson(data);
    }
    // Defensive: an unexpected envelope still yields an honest empty result
    // rather than throwing — the caller degrades to the on-device flow.
    return const LabelPhotoAnalysis(
      confidence: 0,
      warnings: ['Unexpected response from the photo analysis service'],
    );
  }
}

final labelPhotoAnalysisRepositoryProvider = Provider<LabelPhotoAnalysisRepository>(
  (ref) => LabelPhotoAnalysisRepository(ref.watch(dioProvider)),
);

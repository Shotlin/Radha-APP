import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:radha_app/core/network/dio_provider.dart';
import 'package:radha_app/core/network/dto/ai_dto.dart';

/// Calls `POST /api/v1/ai/date/analyze-photo` — the vision escalation path
/// for the expiry-record wizard's date scanners (`date_scanner_screen.dart`)
/// specifically, and ONLY those. Sends a photo (already uploaded via
/// `ProductSubmissionRepository.uploadPhotoEarly`) to a vision model for
/// labels on-device OCR can't get a reliable read from at all — the
/// concrete real case: dates debossed into curved, translucent plastic
/// with no ink, which produced near-random garbage across ~20 consecutive
/// on-device ML Kit frames on a real device (I2217, 2026-08-22).
///
/// Deliberately NOT used by the barcode scanner, the full product-label/
/// nutrition photo flow ([LabelPhotoAnalysisRepository]), or the bulk
/// audit screen — those stay on-device only.
class DatePhotoAnalysisRepository {
  DatePhotoAnalysisRepository(this._dio);

  final Dio _dio;

  Future<DatePhotoAnalysis> analyzePhoto({required String mediaId}) async {
    final res = await _dio.post<dynamic>(
      '/api/v1/ai/date/analyze-photo',
      data: {'mediaId': mediaId},
    );
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return DatePhotoAnalysis.fromJson(data);
    }
    // Defensive: an unexpected envelope still yields an honest empty result
    // rather than throwing — the caller degrades to the on-device flow.
    return const DatePhotoAnalysis(
      confidence: 0,
      warnings: ['Unexpected response from the date analysis service'],
    );
  }
}

final datePhotoAnalysisRepositoryProvider = Provider<DatePhotoAnalysisRepository>(
  (ref) => DatePhotoAnalysisRepository(ref.watch(dioProvider)),
);

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:radha_app/core/network/api_client.dart';
import 'package:radha_app/core/network/dto/product_submission_dto.dart';

/// Submits a community product entry (BE-56 v2): optionally uploads a
/// captured label photo straight to S3 via a presigned POST, then posts
/// the EAN/name/nutrition to `/products/learn` for moderator review.
///
/// The photo upload is a three-step dance:
///   1. `apiClient.presignSubmissionPhoto` — authenticated call to our API,
///      returns an S3 presigned POST policy (`uploadUrl` + `uploadFields`).
///   2. A raw multipart POST straight to `uploadUrl` — deliberately on a
///      **bare** [Dio] instance, not [dioProvider]'s authenticated one: S3
///      doesn't want our JWT, and its response isn't our API's JSON
///      envelope, so none of [dioProvider]'s interceptors apply here.
///   3. `apiClient.confirmSubmissionPhoto` — authenticated call marking the
///      upload complete server-side.
/// Result of an early (pre-submit) photo upload — carries both the
/// `mediaId` (what the vision-analysis endpoint needs) and the `s3Key`
/// (what the final `/products/learn` submission needs), so the SAME
/// upload can serve both without a second round-trip.
class UploadedPhoto {
  const UploadedPhoto({required this.mediaId, required this.s3Key});

  final String mediaId;
  final String s3Key;
}

class ProductSubmissionRepository {
  ProductSubmissionRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Uploads [photo] (if provided) and submits the product. Returns the
  /// created (pending-review) submission.
  ///
  /// If the caller already uploaded the photo earlier (e.g. right after
  /// capture, to kick off a cloud analysis pass without waiting for the
  /// whole wizard — see `uploadPhotoEarly`), pass it as [alreadyUploaded]
  /// so this doesn't upload the same bytes a second time. Only falls back
  /// to uploading [photo] itself when [alreadyUploaded] is null (e.g. the
  /// user retook the photo after the early upload already happened).
  Future<SubmissionResponseDto> submit({
    required String ean,
    String? name,
    String? brand,
    String? category,
    String? ingredients,
    NutritionPanelPayload? nutrition,
    File? photo,
    UploadedPhoto? alreadyUploaded,
  }) async {
    String? s3Key = alreadyUploaded?.s3Key;
    if (s3Key == null && photo != null) {
      s3Key = (await uploadPhotoEarly(photo)).s3Key;
    }

    return _apiClient.submitProduct(
      SubmitProductRequestDto(
        ean: ean,
        name: name,
        brand: brand,
        category: category,
        ingredients: (ingredients != null && ingredients.trim().isNotEmpty)
            ? ingredients.trim()
            : null,
        s3ObjectKeys: s3Key != null ? [s3Key] : null,
        nutrition: (nutrition != null && !nutrition.isEmpty) ? nutrition : null,
      ),
    );
  }

  /// Runs the presign → S3-POST → confirm dance standalone, callable right
  /// after capture rather than only at final submit — so a cloud
  /// photo-analysis pass can start immediately instead of waiting for the
  /// whole wizard to finish. `submit()` reuses this internally too.
  Future<UploadedPhoto> uploadPhotoEarly(File photo) async {
    final bytes = await photo.readAsBytes();

    final presign = await _apiClient.presignSubmissionPhoto(
      SubmissionPresignRequestDto(
        contentType: 'image/jpeg',
        contentLength: bytes.length,
        filename: 'submission.jpg',
      ),
    );

    // S3 POST policy: every `uploadFields` entry as a plain form field,
    // then the file itself last — required field ordering for AWS's
    // presigned-POST signature to validate.
    final form = FormData();
    for (final entry in presign.uploadFields.entries) {
      form.fields.add(MapEntry(entry.key, entry.value.toString()));
    }
    form.files.add(
      MapEntry(
        'file',
        MultipartFile.fromBytes(bytes, filename: 'submission.jpg'),
      ),
    );

    // Bare Dio — see class doc. S3 rejects unexpected headers/auth, and a
    // non-2xx here should surface as a plain DioException, not run through
    // our API's error-envelope parsing.
    await Dio().post<void>(presign.uploadUrl, data: form);

    final confirmed = await _apiClient.confirmSubmissionPhoto(presign.mediaId);
    return UploadedPhoto(mediaId: presign.mediaId, s3Key: confirmed.s3Key);
  }
}

final productSubmissionRepositoryProvider = Provider<ProductSubmissionRepository>(
  (ref) => ProductSubmissionRepository(ref.watch(apiClientProvider)),
);

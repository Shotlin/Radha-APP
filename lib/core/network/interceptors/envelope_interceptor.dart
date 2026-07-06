import 'package:dio/dio.dart';

/// Unwraps the canonical RADHA API envelope so generated Retrofit
/// `fromJson` handlers see only the inner payload.
///
/// Backend `ResponseInterceptor` always wraps successful responses as:
///
///     { "success": true, "data": <T>, "meta": { requestId, ... } }
///
/// And errors as:
///
///     { "success": false, "error": { "code", "message", ... }, "meta": ... }
///
/// Without this unwrap step every typed DTO call would fail with a
/// JSON cast error because Retrofit reads `requestId`, `expiresIn`,
/// etc. from the envelope's top level rather than from `data`.
class EnvelopeInterceptor extends Interceptor {
  EnvelopeInterceptor();

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final data = response.data;

    // Only touch JSON object responses that look like our envelope.
    // Strings, lists, and unrelated shapes pass through unchanged.
    if (data is Map<String, dynamic> && data.containsKey('success')) {
      final ok = data['success'] == true;

      if (ok) {
        // Success → expose `data` (or empty map if the route legitimately
        // returns `{success:true}` with no payload).
        response.data = data['data'] ?? <String, dynamic>{};
      } else {
        // Failure → reject with a DioException so ErrorInterceptor maps
        // it to a typed ApiException downstream. The body stays as-is so
        // ErrorInterceptor can read `error.code` / `error.message`.
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error: data['error'],
          ),
        );
        return;
      }
    }

    handler.next(response);
  }
}

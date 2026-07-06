import 'package:dio/dio.dart';
import 'package:radha_app/core/network/api_exception.dart';

/// Maps [DioException] to typed [ApiException] subclasses.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapException(err);
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
      ),
    );
  }

  ApiException _mapException(DioException err) {
    // Network / timeout errors.
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return const NetworkException();
    }

    final response = err.response;
    if (response == null) {
      return const NetworkException();
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : <String, dynamic>{};

    final code = data['code'] as String? ?? 'UNKNOWN';
    final message =
        data['message'] as String? ?? err.message ?? 'Unknown error';
    final details = data['details'] is Map<String, dynamic>
        ? data['details'] as Map<String, dynamic>
        : null;

    switch (statusCode) {
      case 401:
        return UnauthorizedException(
          code: code,
          message: message,
          details: details,
        );
      case 403:
        return ForbiddenException(
          code: code,
          message: message,
          details: details,
        );
      case 409:
        return ConflictException(
          code: code,
          message: message,
          details: details,
        );
      case 422:
        final fieldErrors = <String, List<String>>{};
        if (data['fieldErrors'] is Map) {
          final raw = data['fieldErrors'] as Map<String, dynamic>;
          for (final entry in raw.entries) {
            if (entry.value is List) {
              fieldErrors[entry.key] = (entry.value as List).cast<String>();
            }
          }
        }
        return ValidationException(
          fieldErrors: fieldErrors,
          code: code,
          message: message,
          details: details,
        );
      case 429:
        final retryAfter =
            int.tryParse(response.headers.value('retry-after') ?? '') ??
            (data['retryAfter'] as num?)?.toInt() ??
            60;
        return RateLimitException(
          retryAfter: retryAfter,
          code: code,
          message: message,
          details: details,
        );
      default:
        if (statusCode >= 500) {
          return ServerException(
            statusCode: statusCode,
            code: code,
            message: message,
            details: details,
          );
        }
        return ApiException(
          statusCode: statusCode,
          code: code,
          message: message,
          details: details,
        );
    }
  }
}

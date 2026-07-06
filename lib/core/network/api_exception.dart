/// Base class for all typed errors surfaced by the networking layer.
class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.details,
  });

  final int statusCode;
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  @override
  String toString() => 'ApiException($statusCode $code): $message';
}

/// 401 — token missing, expired, or refresh failed.
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.code = 'UNAUTHORIZED',
    super.message = 'Authentication required',
    super.details,
  }) : super(statusCode: 401);
}

/// 403 — authenticated but not permitted.
class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.code = 'FORBIDDEN',
    super.message = 'Access denied',
    super.details,
  }) : super(statusCode: 403);
}

/// 409 — resource conflict (e.g. duplicate).
class ConflictException extends ApiException {
  const ConflictException({
    super.code = 'CONFLICT',
    super.message = 'Resource conflict',
    super.details,
  }) : super(statusCode: 409);
}

/// 422 — validation failed with per-field errors.
class ValidationException extends ApiException {
  const ValidationException({
    required this.fieldErrors,
    super.code = 'VALIDATION_ERROR',
    super.message = 'Validation failed',
    super.details,
  }) : super(statusCode: 422);

  final Map<String, List<String>> fieldErrors;

  @override
  String toString() =>
      'ValidationException($statusCode $code): $message — $fieldErrors';
}

/// 429 — rate limited.
class RateLimitException extends ApiException {
  const RateLimitException({
    required this.retryAfter,
    super.code = 'RATE_LIMIT',
    super.message = 'Too many requests',
    super.details,
  }) : super(statusCode: 429);

  /// Seconds until the client may retry.
  final int retryAfter;
}

/// 5xx — server-side failure.
class ServerException extends ApiException {
  const ServerException({
    super.statusCode = 500,
    super.code = 'SERVER_ERROR',
    super.message = 'Internal server error',
    super.details,
  });
}

/// No network connectivity or timeout.
class NetworkException extends ApiException {
  const NetworkException({
    super.code = 'NETWORK_ERROR',
    super.message = 'Network unavailable',
    super.details,
  }) : super(statusCode: 0);
}

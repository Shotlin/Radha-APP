import 'dart:async';

import 'package:dio/dio.dart';
import 'package:radha_app/core/network/token_provider.dart';

/// Injects `Authorization: Bearer <token>` into every request and handles
/// transparent 401 refresh + retry (once).
///
/// Concurrency note: the backend rotates the refresh token on every use —
/// presenting an already-rotated (stale) refresh token is treated as theft
/// and revokes every session for the user (see `auth.service.ts
/// refreshTokens()`). Without a single-flight lock, resuming the app after
/// the access token expires fires several parallel 401s (Home fetches
/// dashboard/tasks/notifications concurrently); each one would otherwise
/// read the same stale refresh token and race to rotate it, and every
/// request after the first would look like token theft to the server and
/// force a real logout. `_refreshFuture` below ensures every concurrent 401
/// awaits the *same* in-flight refresh instead of starting its own.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStore tokenStore,
    required Dio refreshDio,
    required String refreshPath,
  }) : _tokenStore = tokenStore,
       _refreshDio = refreshDio,
       _refreshPath = refreshPath;

  final TokenStore _tokenStore;

  /// A separate Dio instance (no interceptors) used exclusively for the
  /// refresh call to avoid infinite loops.
  final Dio _refreshDio;
  final String _refreshPath;

  static const _retryHeader = 'x-retry';

  /// Non-null while a refresh is in flight. Concurrent 401s await this
  /// same future instead of each firing their own `/auth/refresh` call.
  Future<String?>? _refreshFuture;

  /// Endpoints that must never go through the refresh-and-retry path: the
  /// refresh call itself (would loop), and the pre-login endpoints that run
  /// before any token exists. Deliberately does NOT match `/auth/me` or
  /// `/auth/logout` — those are authenticated calls that should be silently
  /// refreshed-and-retried like any other protected endpoint.
  static const _noRefreshPaths = [
    '/auth/refresh',
    '/auth/otp/request',
    '/auth/otp/verify',
    '/auth/admin/login',
  ];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStore.readAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    if (response == null || response.statusCode != 401) {
      return handler.next(err);
    }

    final options = err.requestOptions;

    // Don't retry if it's a pre-login / refresh-itself path or already retried.
    if (_noRefreshPaths.any(options.path.contains) ||
        options.headers[_retryHeader] == 'true') {
      return handler.next(err);
    }

    final refreshToken = await _tokenStore.readRefreshToken();
    if (refreshToken == null) {
      return handler.next(err);
    }

    try {
      // Single-flight: join an in-progress refresh instead of starting a
      // second one that would present the same (about-to-be-rotated) token
      // and get treated as token theft by the backend.
      final newAccess = await (_refreshFuture ??= _performRefresh(refreshToken));
      if (newAccess == null) {
        return handler.next(err);
      }

      // Retry original request with new token.
      options.headers['Authorization'] = 'Bearer $newAccess';
      options.headers[_retryHeader] = 'true';

      final retryResponse = await _refreshDio.fetch(options);
      // The retry bypassed the envelope interceptor; unwrap so the original
      // caller (which expects the inner payload) deserialises cleanly.
      final retryBody = retryResponse.data;
      if (retryBody is Map<String, dynamic> &&
          retryBody['success'] == true &&
          retryBody.containsKey('data')) {
        retryResponse.data = retryBody['data'];
      }
      return handler.resolve(retryResponse);
    } on DioException {
      // Retry-after-refresh failed — propagate original 401.
      return handler.next(err);
    }
  }

  /// Performs the actual `/auth/refresh` call exactly once no matter how
  /// many concurrent 401s are waiting on `_refreshFuture`. Returns the new
  /// access token, or `null` if the refresh itself failed (expired/revoked
  /// refresh token) — callers treat `null` as "propagate the original 401".
  Future<String?> _performRefresh(String refreshToken) async {
    try {
      final refreshResponse = await _refreshDio.post<Map<String, dynamic>>(
        _refreshPath,
        data: {'refreshToken': refreshToken},
      );

      // The refresh Dio has no interceptors (to avoid loops), so the response
      // arrives as the raw RADHA envelope `{ success, data: {...} }`. Unwrap it
      // before reading the rotated tokens — `accessToken` at the envelope's top
      // level is null. Falls back to a bare body if the route isn't enveloped.
      final body = refreshResponse.data!;
      final inner = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : body;
      final newAccess = inner['accessToken'] as String;
      final newRefresh = inner['refreshToken'] as String;

      await _tokenStore.persistTokens(access: newAccess, refresh: newRefresh);
      return newAccess;
    } on DioException {
      return null;
    } finally {
      // Clear regardless of outcome so the *next* access-token expiry starts
      // a fresh single-flight refresh rather than replaying this result.
      _refreshFuture = null;
    }
  }
}

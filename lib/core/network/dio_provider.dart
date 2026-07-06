import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radha_app/core/network/interceptors/auth_interceptor.dart';
import 'package:radha_app/core/network/interceptors/envelope_interceptor.dart';
import 'package:radha_app/core/network/interceptors/error_interceptor.dart';
import 'package:radha_app/core/network/interceptors/logging_interceptor.dart';
import 'package:radha_app/core/network/token_provider.dart';

/// Base URL injected at build time via `--dart-define=API_BASE_URL=...`.
/// Falls back to localhost for development.
const _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000',
);

/// Provides the singleton [Dio] instance configured with interceptors.
final dioProvider = Provider<Dio>((ref) {
  final tokenStore = ref.watch(tokenStoreProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Separate Dio for refresh (no interceptors → no loops).
  final refreshDio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Order: auth → envelope (unwrap success/data) → logging → error
  dio.interceptors.addAll([
    AuthInterceptor(
      tokenStore: tokenStore,
      refreshDio: refreshDio,
      refreshPath: '/api/v1/auth/refresh',
    ),
    EnvelopeInterceptor(),
    // Logging only in debug builds.
    if (kDebugMode) LoggingInterceptor(),
    ErrorInterceptor(),
  ]);

  return dio;
});

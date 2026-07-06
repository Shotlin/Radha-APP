import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Dev-only request/response logger. Redacts PII keys recursively.
class LoggingInterceptor extends Interceptor {
  static const _piiKeys = {
    'password',
    'otp',
    'refreshToken',
    'accessToken',
    'mobile',
    'email',
    'token',
    'authorization',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      dev.log('→ ${options.method} ${options.uri}', name: 'HTTP');
      if (options.data != null) {
        dev.log('  body: ${_redact(options.data)}', name: 'HTTP');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      dev.log(
        '← ${response.statusCode} ${response.requestOptions.method} '
        '${response.requestOptions.uri}',
        name: 'HTTP',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      dev.log(
        '✗ ${err.response?.statusCode ?? "?"} ${err.requestOptions.method} '
        '${err.requestOptions.uri} — ${err.message}',
        name: 'HTTP',
        level: 900,
      );
    }
    handler.next(err);
  }

  dynamic _redact(dynamic value) {
    if (value is Map) {
      return value.map((key, v) {
        if (_piiKeys.contains(key.toString().toLowerCase())) {
          return MapEntry(key, '***');
        }
        return MapEntry(key, _redact(v));
      });
    }
    if (value is List) {
      return value.map(_redact).toList();
    }
    return value;
  }
}

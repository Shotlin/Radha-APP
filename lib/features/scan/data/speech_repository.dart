import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:radha_app/core/network/dio_provider.dart';

/// Calls `POST /api/v1/ai/speech` — a nicer-sounding cloud voice (free
/// Fish Audio model via OpenRouter) as an upgrade to the AI insight card's
/// existing local device-voice speaker button. Never a replacement for
/// it: the free model backing this carries no availability guarantee, so
/// callers MUST catch failures here and fall back to the local
/// `flutter_tts` voice, which already works standalone.
class SpeechRepository {
  SpeechRepository(this._dio);

  final Dio _dio;

  /// Returns raw MP3 bytes. Throws on any failure (network, timeout, the
  /// backend's own 503-when-cloud-voice-unavailable) — callers are
  /// expected to catch and fall back to the local voice.
  Future<Uint8List> synthesize(String text) async {
    final res = await _dio.post<List<int>>(
      '/api/v1/ai/speech',
      data: {'text': text},
      options: Options(
        responseType: ResponseType.bytes,
        // The server allows up to 25s for synthesis alone (a real call for
        // a full insight paragraph measured >10s — see llm.service.ts's
        // AI_TTS_TIMEOUT_MS); this leaves headroom for that plus
        // downloading the resulting audio, above the client's 30s default.
        receiveTimeout: const Duration(seconds: 35),
      ),
    );
    final data = res.data;
    if (data == null || data.isEmpty) {
      throw StateError('Empty audio response from speech service');
    }
    return Uint8List.fromList(data);
  }
}

final speechRepositoryProvider = Provider<SpeechRepository>(
  (ref) => SpeechRepository(ref.watch(dioProvider)),
);

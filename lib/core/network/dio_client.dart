import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reaple_app/core/config/api_config.dart';
import 'package:reaple_app/core/network/session_events.dart';
import 'package:reaple_app/core/storage/token_storage.dart';

/// Menempelkan token Bearer, dan memberi tahu aplikasi jika token ditolak server (401).
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokens, this._events);

  final TokenStorage _tokens;
  final SessionEvents _events;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokens.read();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      options.extra['hasToken'] = true;
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 401 pada login (sandi salah) tidak memicu ini karena request login tidak membawa token.
    if (err.response?.statusCode == 401 && err.requestOptions.extra['hasToken'] == true) {
      _tokens.clear();
      _events.notifyExpired();
    }

    handler.next(err);
  }
}

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {'Accept': 'application/json'},
      contentType: Headers.jsonContentType,
    ),
  );

  dio.interceptors.add(
    AuthInterceptor(ref.watch(tokenStorageProvider), ref.watch(sessionEventsProvider)),
  );

  return dio;
});
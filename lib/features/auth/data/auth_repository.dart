import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reaple_app/core/network/api_exception.dart';
import 'package:reaple_app/core/network/dio_client.dart';
import 'package:reaple_app/core/storage/token_storage.dart';
import 'package:reaple_app/features/auth/data/user_model.dart';

class AuthRepository {
  AuthRepository(this._dio, this._tokens);

  final Dio _dio;
  final TokenStorage _tokens;

  String get _deviceName => 'mobile-${defaultTargetPlatform.name}';

  Future<UserModel> login({required String email, required String password}) {
    return guardApi(() async {
      final res = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
        'device_name': _deviceName,
      });
      return _saveSession(res.data);
    });
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) {
    return guardApi(() async {
      final res = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'device_name': _deviceName,
      });
      return _saveSession(res.data);
    });
  }

  Future<UserModel> me() {
    return guardApi(() async {
      final res = await _dio.get('/auth/me');
      return UserModel.fromJson(_data(res.data));
    });
  }

  /// Logout selalu berhasil di sisi aplikasi, walau server tidak terjangkau.
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {}
    await _tokens.clear();
  }

  Future<void> forgotPassword(String email) {
    return guardApi(() async {
      await _dio.post('/auth/forgot-password', data: {'email': email});
    });
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) {
    return guardApi(() async {
      await _dio.post('/auth/reset-password', data: {
        'email': email,
        'code': code,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
    });
  }

  // ------------------------------------------------------------------

  Future<UserModel> _saveSession(dynamic body) async {
    final data = _data(body);
    final token = data['token'] as String?;

    if (token == null || token.isEmpty) {
      throw ApiException('Respons server tidak lengkap. Coba lagi.');
    }

    await _tokens.save(token);
    return UserModel.fromJson(Map<String, dynamic>.from(data['user'] as Map));
  }

  Map<String, dynamic> _data(dynamic body) {
    if (body is Map && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    throw ApiException('Respons server tidak dikenali. Coba lagi.');
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(dioProvider), ref.watch(tokenStorageProvider)),
);
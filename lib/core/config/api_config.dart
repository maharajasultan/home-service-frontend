import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const String appName = 'reaple.id';

  /// Ganti tanpa mengubah kode:
  /// flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api/v1
  static const String _fromEnv = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_fromEnv.isNotEmpty) return _fromEnv;
    if (kIsWeb) return 'http://${Uri.base.host}:8000/api/v1';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8000/api/v1';
    return 'http://127.0.0.1:8000/api/v1';
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
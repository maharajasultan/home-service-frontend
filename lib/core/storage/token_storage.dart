import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Token login disimpan terenkripsi (Keystore Android / Keychain iOS).
class TokenStorage {
  TokenStorage([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'auth_token';

  final FlutterSecureStorage _storage;
  String? _cache;
  bool _loaded = false;

  Future<String?> read() async {
    if (_loaded) return _cache;
    try {
      _cache = await _storage.read(key: _key);
    } catch (_) {
      _cache = null; // penyimpanan rusak: anggap belum login
    }
    _loaded = true;
    return _cache;
  }

  Future<void> save(String token) async {
    _cache = token;
    _loaded = true;
    await _storage.write(key: _key, value: token);
  }

  Future<void> clear() async {
    _cache = null;
    _loaded = true;
    try {
      await _storage.delete(key: _key);
    } catch (_) {}
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());
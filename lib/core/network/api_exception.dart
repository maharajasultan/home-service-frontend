import 'package:dio/dio.dart';

/// Error API yang aman ditampilkan ke pengguna.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.errors = const {}});

  final String message;
  final int? statusCode;

  /// Error validasi per kolom (HTTP 422): { "email": ["Email sudah terdaftar."] }
  final Map<String, List<String>> errors;

  bool get isUnauthorized => statusCode == 401;
  bool get isNetworkError => statusCode == null;
  bool get hasFieldErrors => errors.isNotEmpty;

  String? fieldError(String field) {
    final list = errors[field];
    return (list == null || list.isEmpty) ? null : list.first;
  }

  factory ApiException.fromDio(DioException e) {
    const offline = 'Tidak dapat terhubung ke server. Periksa koneksi internet dan alamat API.';

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Koneksi ke server terlalu lama. Coba lagi.');
      case DioExceptionType.connectionError:
        return ApiException(offline);
      case DioExceptionType.cancel:
        return ApiException('Permintaan dibatalkan.');
      default:
        break;
    }

    final response = e.response;
    if (response == null) return ApiException(offline);

    final status = response.statusCode ?? 0;
    final data = response.data;

    String? message;
    final errors = <String, List<String>>{};

    if (data is Map) {
      message = data['message']?.toString();
      final raw = data['errors'];
      if (raw is Map) {
        raw.forEach((key, value) {
          if (value is List) {
            errors[key.toString()] = value.map((v) => v.toString()).toList();
          } else if (value != null) {
            errors[key.toString()] = [value.toString()];
          }
        });
      }
    }

    // Jangan tampilkan pesan mentah server (bisa berisi detail teknis).
    if (status >= 500) {
      message = 'Server sedang bermasalah. Coba lagi beberapa saat.';
    } else if (status == 429) {
      message = 'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.';
    } else if (message == null || message.isEmpty) {
      message = switch (status) {
        401 => 'Sesi Anda berakhir. Silakan login kembali.',
        403 => 'Anda tidak memiliki akses.',
        404 => 'Data tidak ditemukan.',
        422 => 'Data yang dimasukkan belum valid.',
        _ => 'Terjadi kesalahan. Coba lagi.',
      };
    }

    return ApiException(message, statusCode: status, errors: errors);
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Bungkus panggilan Dio agar semua error menjadi [ApiException].
Future<T> guardApi<T>(Future<T> Function() run) async {
  try {
    return await run();
  } on DioException catch (e) {
    throw ApiException.fromDio(e);
  }
}
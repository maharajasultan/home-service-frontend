import 'package:reaple_app/core/network/api_exception.dart';

Map<String, dynamic> asJsonMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  throw ApiException('Respons server tidak dikenali. Coba lagi.');
}

List<Map<String, dynamic>> asJsonList(dynamic value) {
  if (value is! List) return const [];
  return value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
}

int asInt(dynamic value, [int fallback = 0]) {
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}

double asDouble(dynamic value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? fallback;
}

/// Bungkus proses membaca JSON: bentuk data yang tidak sesuai menjadi pesan yang rapi, bukan crash.
T parseResponse<T>(T Function() parse) {
  try {
    return parse();
  } on ApiException {
    rethrow;
  } catch (_) {
    throw ApiException('Data dari server tidak dapat dibaca. Coba lagi.');
  }
}
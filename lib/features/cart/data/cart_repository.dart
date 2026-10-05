import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reaple_app/core/network/api_exception.dart';
import 'package:reaple_app/core/network/api_parse.dart';
import 'package:reaple_app/core/network/dio_client.dart';

class CartRepository {
  CartRepository(this._dio);

  final Dio _dio;

  /// Jumlah total item di keranjang (untuk badge).
  Future<int> count() {
    return guardApi(() async {
      final res = await _dio.get('/cart');
      return parseResponse(() => _itemCount(res.data));
    });
  }

  /// Tambah ke keranjang. Mengembalikan jumlah item terbaru.
  Future<int> add({required int variantId, int qty = 1}) {
    return guardApi(() async {
      final res = await _dio.post('/cart', data: {'product_variant_id': variantId, 'qty': qty});
      return parseResponse(() => _itemCount(res.data));
    });
  }

  int _itemCount(dynamic body) {
    final data = asJsonMap(asJsonMap(body)['data']);
    return asInt(asJsonMap(data['summary'])['item_count']);
  }
}

final cartRepositoryProvider = Provider<CartRepository>((ref) => CartRepository(ref.watch(dioProvider)));
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reaple_app/core/network/api_exception.dart';
import 'package:reaple_app/core/network/api_parse.dart';
import 'package:reaple_app/core/network/dio_client.dart';
import 'package:reaple_app/features/product/data/product_models.dart';

class ProductPage {
  const ProductPage({required this.items, required this.currentPage, required this.lastPage});

  final List<ProductModel> items;
  final int currentPage;
  final int lastPage;
}

class ReviewPage {
  const ReviewPage({required this.items, required this.currentPage, required this.lastPage, required this.total});

  final List<ReviewModel> items;
  final int currentPage;
  final int lastPage;
  final int total;
}

class ProductRepository {
  ProductRepository(this._dio);

  final Dio _dio;

  Future<ProductPage> fetchProducts({String? type, String? query, int page = 1, int perPage = 20}) {
    return guardApi(() async {
      final res = await _dio.get('/products', queryParameters: {
        if (type != null) 'type': type,
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        'page': page,
        'per_page': perPage,
      });

      return parseResponse(() {
        final body = asJsonMap(res.data);
        final meta = body['meta'] is Map ? asJsonMap(body['meta']) : <String, dynamic>{};

        return ProductPage(
          items: asJsonList(body['data']).map(ProductModel.fromJson).toList(),
          currentPage: asInt(meta['current_page'], 1),
          lastPage: asInt(meta['last_page'], 1),
        );
      });
    });
  }

  Future<ProductModel> fetchProduct(int id) {
    return guardApi(() async {
      final res = await _dio.get('/products/$id');
      return parseResponse(() => ProductModel.fromJson(asJsonMap(asJsonMap(res.data)['data'])));
    });
  }

  Future<ReviewPage> fetchReviews(int productId, {int page = 1}) {
    return guardApi(() async {
      final res = await _dio.get('/products/$productId/reviews', queryParameters: {'page': page});

      return parseResponse(() {
        final body = asJsonMap(res.data);
        final meta = body['meta'] is Map ? asJsonMap(body['meta']) : <String, dynamic>{};

        return ReviewPage(
          items: asJsonList(body['data']).map(ReviewModel.fromJson).toList(),
          currentPage: asInt(meta['current_page'], 1),
          lastPage: asInt(meta['last_page'], 1),
          total: asInt(meta['total']),
        );
      });
    });
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) => ProductRepository(ref.watch(dioProvider)));
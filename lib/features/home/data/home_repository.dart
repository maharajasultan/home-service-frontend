import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reaple_app/core/network/api_exception.dart';
import 'package:reaple_app/core/network/api_parse.dart';
import 'package:reaple_app/core/network/dio_client.dart';
import 'package:reaple_app/features/home/data/banner_model.dart';

class HomeRepository {
  HomeRepository(this._dio);

  final Dio _dio;

  Future<List<BannerModel>> fetchBanners() {
    return guardApi(() async {
      final res = await _dio.get('/banners');
      return parseResponse(
        () => asJsonList(asJsonMap(res.data)['data']).map(BannerModel.fromJson).toList(),
      );
    });
  }
}

final homeRepositoryProvider = Provider<HomeRepository>((ref) => HomeRepository(ref.watch(dioProvider)));
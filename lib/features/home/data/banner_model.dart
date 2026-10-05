import 'package:reaple_app/core/network/api_parse.dart';

class BannerModel {
  const BannerModel({required this.id, required this.title, this.imageUrl});

  final int id;
  final String title;
  final String? imageUrl;

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
        id: asInt(json['id']),
        title: (json['title'] as String?) ?? '',
        imageUrl: json['image_url'] as String?,
      );
}
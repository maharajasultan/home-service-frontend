import 'package:reaple_app/core/network/api_parse.dart';
import 'package:reaple_app/core/utils/format.dart';

/// Petunjuk dari server: popup apa yang harus ditampilkan saat memesan.
class ProductOptions {
  const ProductOptions({
    this.needsIphoneModel = false,
    this.needsGrade = false,
    this.needsDuration = false,
    this.inspectionOnly = false,
  });

  final bool needsIphoneModel;
  final bool needsGrade; // sparepart
  final bool needsDuration; // unlock IMEI
  final bool inspectionOnly; // matot: hanya ongkir/pengecekan

  factory ProductOptions.fromJson(Map<String, dynamic> json) => ProductOptions(
        needsIphoneModel: json['needs_iphone_model'] == true,
        needsGrade: json['needs_grade'] == true,
        needsDuration: json['needs_duration'] == true,
        inspectionOnly: json['inspection_only'] == true,
      );
}

class VariantModel {
  const VariantModel({
    required this.id,
    required this.price,
    required this.finalPrice,
    required this.stock,
    required this.available,
    this.iphoneModelId,
    this.iphoneModel,
    this.grade,
    this.gradeLabel,
    this.durationMonths,
    this.durationLabel,
  });

  final int id;
  final int? iphoneModelId;
  final String? iphoneModel;
  final String? grade; // standar | premium | original
  final String? gradeLabel;
  final int? durationMonths;
  final String? durationLabel;
  final int price;
  final int finalPrice; // harga + ongkir/pengecekan, dihitung server
  final int stock;
  final bool available;

  /// Contoh: "iPhone 13 - Premium" atau "3 Bulan".
  String get shortLabel =>
      [iphoneModel, gradeLabel, durationLabel].whereType<String>().where((s) => s.isNotEmpty).join(' - ');

  factory VariantModel.fromJson(Map<String, dynamic> json) => VariantModel(
        id: asInt(json['id']),
        iphoneModelId: json['iphone_model_id'] == null ? null : asInt(json['iphone_model_id']),
        iphoneModel: json['iphone_model'] as String?,
        grade: json['grade'] as String?,
        gradeLabel: json['grade_label'] as String?,
        durationMonths: json['duration_months'] == null ? null : asInt(json['duration_months']),
        durationLabel: json['duration_label'] as String?,
        price: asInt(json['price']),
        finalPrice: asInt(json['final_price'], asInt(json['price'])),
        stock: asInt(json['stock']),
        available: json['available'] == true,
      );
}

class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.rating,
    required this.userName,
    this.comment,
    this.userAvatarUrl,
    this.reply,
    this.createdAt,
  });

  final int id;
  final int rating;
  final String? comment;
  final String userName;
  final String? userAvatarUrl;
  final String? reply;
  final DateTime? createdAt;

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map ? asJsonMap(json['user']) : <String, dynamic>{};

    return ReviewModel(
      id: asInt(json['id']),
      rating: asInt(json['rating']),
      comment: json['comment'] as String?,
      userName: (user['name'] as String?) ?? 'Pengguna',
      userAvatarUrl: user['avatar_url'] as String?,
      reply: json['reply'] as String?,
      createdAt: Fmt.parse(json['created_at'] as String?),
    );
  }
}

class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.type,
    required this.typeLabel,
    required this.options,
    this.slug = '',
    this.description,
    this.thumbnail,
    this.images = const [],
    this.baseFee = 0,
    this.startingPrice,
    this.ratingAvg = 0,
    this.ratingCount = 0,
    this.inStock = false,
    this.variants = const [],
    this.latestReviews = const [],
  });

  final int id;
  final String name;
  final String slug;
  final String type; // sparepart | matot | unlock_imei
  final String typeLabel;
  final String? description;
  final String? thumbnail;
  final List<String> images;
  final int baseFee;
  final int? startingPrice;
  final double ratingAvg;
  final int ratingCount;
  final bool inStock;
  final ProductOptions options;
  final List<VariantModel> variants; // hanya terisi di detail
  final List<ReviewModel> latestReviews; // hanya terisi di detail

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] as List?)?.whereType<String>().toList() ?? const <String>[];

    return ProductModel(
      id: asInt(json['id']),
      name: (json['name'] as String?) ?? '',
      slug: (json['slug'] as String?) ?? '',
      type: (json['type'] as String?) ?? 'sparepart',
      typeLabel: (json['type_label'] as String?) ?? '',
      description: json['description'] as String?,
      thumbnail: json['thumbnail'] as String?,
      images: images,
      baseFee: asInt(json['base_fee']),
      startingPrice: json['starting_price'] == null ? null : asInt(json['starting_price']),
      ratingAvg: asDouble(json['rating_avg']),
      ratingCount: asInt(json['rating_count']),
      inStock: json['in_stock'] == true,
      options: ProductOptions.fromJson(asJsonMap(json['options'] ?? <String, dynamic>{})),
      variants: asJsonList(json['variants']).map(VariantModel.fromJson).toList(),
      latestReviews: asJsonList(json['latest_reviews']).map(ReviewModel.fromJson).toList(),
    );
  }
}
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.roleLabel,
    this.phone,
    this.avatarUrl,
    this.bio,
    this.avgRating,
    this.ratingCount,
  });

  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role; // user | technician
  final String roleLabel;
  final String? avatarUrl;

  // Khusus teknisi
  final String? bio;
  final double? avgRating;
  final int? ratingCount;

  bool get isTechnician => role == 'technician';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final tech = json['technician'];

    return UserModel(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phone: json['phone'] as String?,
      role: (json['role'] as String?) ?? 'user',
      roleLabel: (json['role_label'] as String?) ?? 'Pelanggan',
      avatarUrl: json['avatar_url'] as String?,
      bio: tech is Map ? tech['bio'] as String? : null,
      avgRating: tech is Map ? (tech['avg_rating'] as num?)?.toDouble() : null,
      ratingCount: tech is Map ? (tech['rating_count'] as num?)?.toInt() : null,
    );
  }
}
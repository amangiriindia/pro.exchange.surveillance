import '../../domain/entities/profile_details.dart';

class ProfileDetailsModel extends ProfileDetails {
  const ProfileDetailsModel({
    required super.id,
    required super.username,
    required super.isActive,
    required super.createdAt,
    required super.tokenGeneratedAt,
  });

  factory ProfileDetailsModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? <String, dynamic>{};

    DateTime? parseDate(dynamic value) {
      if (value is! String || value.isEmpty) return null;
      return DateTime.tryParse(value)?.toLocal();
    }

    return ProfileDetailsModel(
      id: user['id'] as String? ?? '',
      username: user['username'] as String? ?? '',
      isActive: user['is_active'] as bool? ?? false,
      createdAt: parseDate(user['created_at']),
      tokenGeneratedAt: parseDate(user['token_generated_at']),
    );
  }
}

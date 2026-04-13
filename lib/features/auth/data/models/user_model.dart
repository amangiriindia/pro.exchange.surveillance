import '../../domain/entities/user.dart';

class LoginUserModel extends User {
  const LoginUserModel({
    required super.id,
    required super.username,
    required super.apiToken,
    required super.jwtToken,
    required super.role,
    super.isActive,
  });

  factory LoginUserModel.fromJson(Map<String, dynamic> json) {
    final token = json['token'] as Map<String, dynamic>? ?? {};
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return LoginUserModel(
      id: user['id'] as String? ?? '',
      username: user['username'] as String? ?? '',
      apiToken: token['api_token'] as String? ?? '',
      jwtToken: token['jwt_token'] as String? ?? '',
      role: user['role'] as String? ?? '',
      isActive: user['is_active'] as bool? ?? true,
    );
  }

  factory LoginUserModel.fromStorageJson(Map<String, dynamic> json) {
    return LoginUserModel(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      apiToken: json['api_token'] as String? ?? '',
      jwtToken: json['jwt_token'] as String? ?? '',
      role: json['role'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  factory LoginUserModel.fromEntity(User user) {
    return LoginUserModel(
      id: user.id,
      username: user.username,
      apiToken: user.apiToken,
      jwtToken: user.jwtToken,
      role: user.role,
      isActive: user.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'api_token': apiToken,
      'jwt_token': jwtToken,
      'role': role,
      'is_active': isActive,
    };
  }
}

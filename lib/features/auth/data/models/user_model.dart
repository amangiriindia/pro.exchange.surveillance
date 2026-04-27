import '../../domain/entities/user.dart';

class LoginUserModel extends User {
  const LoginUserModel({
    required super.id,
    super.name,
    super.email,
    required super.username,
    required super.apiToken,
    required super.jwtToken,
    required super.role,
    super.isActive,
  });

  factory LoginUserModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final user = data['userData'] as Map<String, dynamic>? ?? {};
    final token = data['token'] as String? ?? '';
    final displayName = (user['name'] as String? ?? '').trim();
    final email = (user['email'] as String? ?? '').trim();
    return LoginUserModel(
      id: (user['id'] ?? '').toString(),
      name: displayName,
      email: email,
      username: displayName.isNotEmpty ? displayName : email,
      apiToken: token,
      jwtToken: token,
      role: user['role'] as String? ?? '',
      isActive: !(user['isDeleted'] as bool? ?? false),
    );
  }

  factory LoginUserModel.fromStorageJson(Map<String, dynamic> json) {
    return LoginUserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
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
      name: user.name,
      email: user.email,
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
      'name': name,
      'email': email,
      'username': username,
      'api_token': apiToken,
      'jwt_token': jwtToken,
      'role': role,
      'is_active': isActive,
    };
  }
}

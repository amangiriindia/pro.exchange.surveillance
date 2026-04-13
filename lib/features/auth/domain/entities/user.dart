import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String apiToken;
  final String jwtToken;
  final String role;
  final bool isActive;
  const User({
    required this.id,
    required this.username,
    required this.apiToken,
    required this.jwtToken,
    required this.role,
    this.isActive = true,
  });
  @override
  List<Object?> get props => [id, username, apiToken, jwtToken, role, isActive];
}

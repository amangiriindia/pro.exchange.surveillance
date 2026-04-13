import 'package:equatable/equatable.dart';

class ProfileDetails extends Equatable {
  final String id;
  final String username;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? tokenGeneratedAt;

  const ProfileDetails({
    required this.id,
    required this.username,
    required this.isActive,
    required this.createdAt,
    required this.tokenGeneratedAt,
  });

  @override
  List<Object?> get props => [
    id,
    username,
    isActive,
    createdAt,
    tokenGeneratedAt,
  ];
}

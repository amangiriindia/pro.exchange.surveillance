import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_details.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String username,
    required String password,
  });

  Future<Either<Failure, String>> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  });

  Future<Either<Failure, ProfileDetails>> getProfile({required String token});

  Future<Either<Failure, String>> logout({required String token});
}

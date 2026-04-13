import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/profile_details.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> login({
    required String username,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(
        username: username,
        password: password,
      );
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final message = await remoteDataSource.changePassword(
        token: token,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return Right(message);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, ProfileDetails>> getProfile({
    required String token,
  }) async {
    try {
      final profile = await remoteDataSource.getProfile(token: token);
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, String>> logout({required String token}) async {
    try {
      final message = await remoteDataSource.logout(token: token);
      return Right(message);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}

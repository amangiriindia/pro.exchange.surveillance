import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class ChangePassword implements UseCase<String, ChangePasswordParams> {
  final AuthRepository repository;

  ChangePassword({required this.repository});

  @override
  Future<Either<Failure, String>> call(ChangePasswordParams params) async {
    return repository.changePassword(
      token: params.token,
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
    );
  }
}

class ChangePasswordParams extends Equatable {
  final String token;
  final String currentPassword;
  final String newPassword;

  const ChangePasswordParams({
    required this.token,
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [token, currentPassword, newPassword];
}

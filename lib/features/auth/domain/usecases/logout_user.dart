import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class LogoutUser implements UseCase<String, LogoutParams> {
  final AuthRepository repository;

  LogoutUser({required this.repository});

  @override
  Future<Either<Failure, String>> call(LogoutParams params) async {
    return repository.logout(token: params.token);
  }
}

class LogoutParams extends Equatable {
  final String token;

  const LogoutParams({required this.token});

  @override
  List<Object?> get props => [token];
}

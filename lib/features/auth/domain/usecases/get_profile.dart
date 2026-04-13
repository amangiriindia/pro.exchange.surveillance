import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile_details.dart';
import '../repositories/auth_repository.dart';

class GetProfile implements UseCase<ProfileDetails, GetProfileParams> {
  final AuthRepository repository;

  GetProfile({required this.repository});

  @override
  Future<Either<Failure, ProfileDetails>> call(GetProfileParams params) async {
    return repository.getProfile(token: params.token);
  }
}

class GetProfileParams extends Equatable {
  final String token;

  const GetProfileParams({required this.token});

  @override
  List<Object?> get props => [token];
}

import 'package:dartz/dartz.dart';
import 'package:surveillance/core/errors/failures.dart';
import '../../domain/entities/btst_entity.dart';
import '../../domain/entities/btst_detail_entity.dart';
import '../../domain/repositories/btst_repository.dart';
import '../datasources/btst_remote_data_source.dart';

class BTSTRepositoryImpl implements BTSTRepository {
  final BTSTRemoteDataSource remoteDataSource;

  BTSTRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<BTSTEntity>>> getBTSTData() async {
    try {
      final remoteData = await remoteDataSource.getBTSTData();
      return Right(remoteData);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<BTSTDetailEntity>>> getBTSTDetails(String uName) async {
    try {
      final remoteData = await remoteDataSource.getBTSTDetails(uName);
      return Right(remoteData);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}

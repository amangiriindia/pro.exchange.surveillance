import 'package:dartz/dartz.dart';
import 'package:surveillance/core/errors/failures.dart';
import '../../domain/entities/same_ip_entity.dart';
import '../../domain/entities/same_ip_detail_entity.dart';
import '../../domain/repositories/same_ip_repository.dart';
import '../datasources/same_ip_remote_data_source.dart';

class SameIPRepositoryImpl implements SameIPRepository {
  final SameIPRemoteDataSource remoteDataSource;

  SameIPRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<SameIPEntity>>> getSameIPData() async {
    try {
      final remoteData = await remoteDataSource.getSameIPData();
      return Right(remoteData);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<SameIPDetailEntity>>> getSameIPDetails(String clusterId) async {
    try {
      final remoteData = await remoteDataSource.getSameIPDetails(clusterId);
      return Right(remoteData);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}

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
  Future<Either<Failure, List<SameIPEntity>>> getSameIPData({
    int page = 1,
    int sizePerPage = 20,
  }) async {
    try {
      final remoteData = await remoteDataSource.getSameIPData(
        page: page,
        sizePerPage: sizePerPage,
      );
      return Right(remoteData);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<SameIPDetailEntity>>> getSameIPDetails(
    int alertId,
  ) async {
    try {
      final remoteData = await remoteDataSource.getSameIPDetails(alertId);
      return Right(remoteData);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}

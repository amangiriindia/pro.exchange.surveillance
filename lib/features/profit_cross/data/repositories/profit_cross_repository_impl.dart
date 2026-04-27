import 'package:dartz/dartz.dart';
import 'package:surveillance/core/errors/failures.dart';
import '../../domain/entities/profit_cross_entity.dart';
import '../../domain/entities/order_duration_entity.dart';
import '../../domain/repositories/profit_cross_repository.dart';
import '../datasources/profit_cross_remote_data_source.dart';

class ProfitCrossRepositoryImpl implements ProfitCrossRepository {
  final ProfitCrossRemoteDataSource remoteDataSource;

  ProfitCrossRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ProfitCrossEntity>>> getProfitCrossData({
    int page = 1,
    int sizePerPage = 20,
  }) async {
    try {
      final remoteData = await remoteDataSource.getProfitCrossData(
        page: page,
        sizePerPage: sizePerPage,
      );
      return Right(remoteData);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<OrderDurationEntity>>> getOrderDurationDetails(
    int alertId,
  ) async {
    try {
      final remoteData = await remoteDataSource.getOrderDurationDetails(
        alertId,
      );
      return Right(remoteData);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}

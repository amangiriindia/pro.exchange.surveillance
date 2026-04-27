import 'package:dartz/dartz.dart';
import 'package:surveillance/core/errors/failures.dart';
import '../../domain/entities/trade_comparison_entity.dart';
import '../../domain/repositories/trade_comparison_repository.dart';
import '../datasources/trade_comparison_remote_data_source.dart';

class TradeComparisonRepositoryImpl implements TradeComparisonRepository {
  final TradeComparisonRemoteDataSource remoteDataSource;

  TradeComparisonRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TradeComparisonEntity>>> getTradeComparisonData({
    int page = 1,
    int sizePerPage = 20,
  }) async {
    try {
      final remoteData = await remoteDataSource.getTradeComparisonData(
        page: page,
        sizePerPage: sizePerPage,
      );
      return Right(remoteData);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}

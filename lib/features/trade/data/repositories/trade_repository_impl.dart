import 'package:dartz/dartz.dart';
import '../../domain/repositories/trade_repository.dart';
import '../datasources/trade_remote_data_source.dart';

class TradeRepositoryImpl implements TradeRepository {
  final TradeRemoteDataSource remoteDataSource;

  TradeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, TradePaginatedResult>> getTrades({
    int page = 1,
    int sizePerPage = 20,
  }) async {
    try {
      final result = await remoteDataSource.getTrades(
        page: page,
        sizePerPage: sizePerPage,
      );
      return Right(result);
    } catch (e) {
      return Left('Error fetching trades: ${e.toString()}');
    }
  }
}

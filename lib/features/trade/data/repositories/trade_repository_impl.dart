import 'package:dartz/dartz.dart';
import '../../domain/entities/trade_entity.dart';
import '../../domain/repositories/trade_repository.dart';
import '../datasources/trade_remote_data_source.dart';

class TradeRepositoryImpl implements TradeRepository {
  final TradeRemoteDataSource remoteDataSource;

  TradeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<dynamic, List<TradeEntity>>> getTrades() async {
    try {
      final remoteTrades = await remoteDataSource.getTrades();
      return Right(remoteTrades);
    } catch (e) {
      return Left('Error fetching data');
    }
  }
}

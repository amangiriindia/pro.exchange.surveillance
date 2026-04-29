import 'package:dartz/dartz.dart';
import '../../data/datasources/trade_remote_data_source.dart';

abstract class TradeRepository {
  Future<Either<String, TradePaginatedResult>> getTrades({
    int page = 1,
    int sizePerPage = 20,
  });

  Future<Either<String, TradeCountResult>> getTradeCount();
}

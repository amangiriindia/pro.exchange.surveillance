import 'package:dartz/dartz.dart';
import '../repositories/trade_repository.dart';
import '../../data/datasources/trade_remote_data_source.dart';

class GetTrades {
  final TradeRepository repository;

  GetTrades(this.repository);

  Future<Either<String, TradePaginatedResult>> call({
    int page = 1,
    int sizePerPage = 20,
  }) async {
    return await repository.getTrades(page: page, sizePerPage: sizePerPage);
  }
}

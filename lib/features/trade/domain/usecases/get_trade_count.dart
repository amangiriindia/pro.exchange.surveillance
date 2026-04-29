import 'package:dartz/dartz.dart';
import '../../data/datasources/trade_remote_data_source.dart';
import '../repositories/trade_repository.dart';

class GetTradeCount {
  final TradeRepository repository;

  GetTradeCount(this.repository);

  Future<Either<String, TradeCountResult>> call() async {
    return await repository.getTradeCount();
  }
}

import 'package:dartz/dartz.dart';
import '../entities/trade_entity.dart';
import '../repositories/trade_repository.dart';

class GetTrades {
  final TradeRepository repository;

  GetTrades(this.repository);

  Future<Either<dynamic, List<TradeEntity>>> call() async {
    return await repository.getTrades();
  }
}

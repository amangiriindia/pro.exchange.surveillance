import 'package:dartz/dartz.dart';
import '../entities/trade_entity.dart';

abstract class TradeRepository {
  Future<Either<dynamic, List<TradeEntity>>> getTrades();
}

import 'package:dartz/dartz.dart';
import 'package:surveillance/core/errors/failures.dart';
import '../entities/trade_comparison_entity.dart';

abstract class TradeComparisonRepository {
  Future<Either<Failure, List<TradeComparisonEntity>>> getTradeComparisonData();
}

import 'package:dartz/dartz.dart';
import 'package:surveillance/core/errors/failures.dart';

import '../entities/profit_cross_entity.dart';
import '../entities/order_duration_entity.dart';

abstract class ProfitCrossRepository {
  Future<Either<Failure, List<ProfitCrossEntity>>> getProfitCrossData();
  Future<Either<Failure, List<OrderDurationEntity>>> getOrderDurationDetails(String symbol);
}

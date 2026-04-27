import 'package:dartz/dartz.dart';
import 'package:surveillance/core/errors/failures.dart';

import '../entities/profit_cross_entity.dart';
import '../entities/order_duration_entity.dart';

abstract class ProfitCrossRepository {
  Future<Either<Failure, List<ProfitCrossEntity>>> getProfitCrossData({
    int page = 1,
    int sizePerPage = 20,
  });
  Future<Either<Failure, List<OrderDurationEntity>>> getOrderDurationDetails(
    int alertId,
  );
}

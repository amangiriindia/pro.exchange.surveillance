import 'package:dartz/dartz.dart';
import 'package:surveillance/core/errors/failures.dart';

import '../entities/order_duration_entity.dart';
import '../repositories/profit_cross_repository.dart';

class GetOrderDurationDetails {
  final ProfitCrossRepository repository;

  GetOrderDurationDetails(this.repository);

  Future<Either<Failure, List<OrderDurationEntity>>> call(String symbol) async {
    return await repository.getOrderDurationDetails(symbol);
  }
}

import 'package:dartz/dartz.dart';
import 'package:surveillance/core/errors/failures.dart';
import '../entities/trade_comparison_entity.dart';
import '../repositories/trade_comparison_repository.dart';

class GetTradeComparisonData {
  final TradeComparisonRepository repository;

  GetTradeComparisonData(this.repository);

  Future<Either<Failure, List<TradeComparisonEntity>>> call({
    int page = 1,
    int sizePerPage = 20,
  }) async {
    return await repository.getTradeComparisonData(
      page: page,
      sizePerPage: sizePerPage,
    );
  }
}

import 'package:dartz/dartz.dart';
import '../repositories/group_trade_repository.dart';

class GetGroupTrades {
  final GroupTradeRepository repository;

  GetGroupTrades(this.repository);

  Future<Either<String, GroupTradePaginatedResult>> call({
    int page = 1,
    int sizePerPage = 100,
  }) async {
    return await repository.getGroupTrades(page: page, sizePerPage: sizePerPage);
  }
}

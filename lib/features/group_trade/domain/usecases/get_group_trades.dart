import 'package:dartz/dartz.dart';
import '../entities/group_trade_entity.dart';
import '../repositories/group_trade_repository.dart';

class GetGroupTrades {
  final GroupTradeRepository repository;

  GetGroupTrades(this.repository);

  Future<Either<dynamic, List<GroupTradeEntity>>> call() async {
    return await repository.getGroupTrades();
  }
}

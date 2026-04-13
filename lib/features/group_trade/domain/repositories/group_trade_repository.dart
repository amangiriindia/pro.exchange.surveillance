import 'package:dartz/dartz.dart';
import '../entities/group_trade_entity.dart';

abstract class GroupTradeRepository {
  Future<Either<dynamic, List<GroupTradeEntity>>> getGroupTrades();
}

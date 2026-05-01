import 'package:dartz/dartz.dart';
import '../entities/group_trade_details_entity.dart';

abstract class GroupTradeDetailsRepository {
  Future<Either<String, List<GroupTradeDetailsEntity>>> getDetails(int alertId);
}

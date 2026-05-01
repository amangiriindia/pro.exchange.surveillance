import 'package:dartz/dartz.dart';
import '../entities/group_trade_details_entity.dart';
import '../repositories/group_trade_details_repository.dart';

class GetGroupTradeDetails {
  final GroupTradeDetailsRepository repository;

  GetGroupTradeDetails(this.repository);

  Future<Either<String, List<GroupTradeDetailsEntity>>> call(
    int alertId,
  ) async {
    return await repository.getDetails(alertId);
  }
}

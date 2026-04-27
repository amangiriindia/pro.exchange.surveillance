import 'package:dartz/dartz.dart';
import '../entities/group_trade_entity.dart';

class GroupTradePaginatedResult {
  final List<GroupTradeEntity> items;
  final int totalRecords;
  final int totalPages;
  final int currentPage;

  const GroupTradePaginatedResult({
    required this.items,
    required this.totalRecords,
    required this.totalPages,
    required this.currentPage,
  });
}

abstract class GroupTradeRepository {
  Future<Either<String, GroupTradePaginatedResult>> getGroupTrades({
    int page = 1,
    int sizePerPage = 100,
  });
}

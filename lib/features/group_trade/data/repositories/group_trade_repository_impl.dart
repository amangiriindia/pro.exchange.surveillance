import 'package:dartz/dartz.dart';
import '../../domain/repositories/group_trade_repository.dart';
import '../datasources/group_trade_remote_data_source.dart'
    hide GroupTradePaginatedResult;

class GroupTradeRepositoryImpl implements GroupTradeRepository {
  final GroupTradeRemoteDataSource remoteDataSource;

  GroupTradeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, GroupTradePaginatedResult>> getGroupTrades({
    int page = 1,
    int sizePerPage = 100,
  }) async {
    try {
      final result = await remoteDataSource.getGroupTrades(
        page: page,
        sizePerPage: sizePerPage,
      );
      return Right(
        GroupTradePaginatedResult(
          items: result.items,
          totalRecords: result.totalRecords,
          totalPages: result.totalPages,
          currentPage: result.currentPage,
        ),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }
}

import 'package:dartz/dartz.dart';
import '../../domain/entities/group_trade_details_entity.dart';
import '../../domain/repositories/group_trade_details_repository.dart';
import '../datasources/group_trade_details_remote_data_source.dart';

class GroupTradeDetailsRepositoryImpl implements GroupTradeDetailsRepository {
  final GroupTradeDetailsRemoteDataSource remoteDataSource;

  GroupTradeDetailsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, List<GroupTradeDetailsEntity>>> getDetails(
    int alertId,
  ) async {
    try {
      final result = await remoteDataSource.getDetails(alertId);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

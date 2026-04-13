import 'package:dartz/dartz.dart';
import '../../domain/entities/group_trade_entity.dart';
import '../../domain/repositories/group_trade_repository.dart';
import '../datasources/group_trade_remote_data_source.dart';

class GroupTradeRepositoryImpl implements GroupTradeRepository {
  final GroupTradeRemoteDataSource remoteDataSource;

  GroupTradeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<dynamic, List<GroupTradeEntity>>> getGroupTrades() async {
    try {
      final remoteTrades = await remoteDataSource.getGroupTrades();
      return Right(remoteTrades);
    } catch (e) {
      return Left('Error fetching data');
    }
  }
}

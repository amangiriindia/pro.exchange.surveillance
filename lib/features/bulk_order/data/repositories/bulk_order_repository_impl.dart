import 'package:dartz/dartz.dart';
import '../../domain/entities/bulk_order_entity.dart';
import '../../domain/repositories/bulk_order_repository.dart';
import '../datasources/bulk_order_remote_data_source.dart';

class BulkOrderRepositoryImpl implements BulkOrderRepository {
  final BulkOrderRemoteDataSource remoteDataSource;

  BulkOrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<dynamic, List<BulkOrderEntity>>> getBulkOrders({
    int page = 1,
    int sizePerPage = 20,
  }) async {
    try {
      final remoteData = await remoteDataSource.getBulkOrders(
        page: page,
        sizePerPage: sizePerPage,
      );
      return Right(remoteData);
    } catch (e) {
      return Left('Error fetching bulk orders');
    }
  }
}

import 'package:dartz/dartz.dart';
import '../../domain/entities/bulk_order_details_entity.dart';
import '../../domain/repositories/bulk_order_details_repository.dart';
import '../datasources/bulk_order_details_remote_data_source.dart';

class BulkOrderDetailsRepositoryImpl implements BulkOrderDetailsRepository {
  final BulkOrderDetailsRemoteDataSource remoteDataSource;

  BulkOrderDetailsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<dynamic, List<BulkOrderDetailsEntity>>> getDetails(
    int alertId,
  ) async {
    try {
      final data = await remoteDataSource.getDetails(alertId);
      return Right(data);
    } catch (e) {
      return Left('Error fetching bulk order details');
    }
  }
}

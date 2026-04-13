import 'package:dartz/dartz.dart';
import '../../domain/entities/bulk_order_details_entity.dart';
import '../../domain/repositories/bulk_order_details_repository.dart';
import '../datasources/bulk_order_details_remote_data_source.dart';

class BulkOrderDetailsRepositoryImpl implements BulkOrderDetailsRepository {
  final BulkOrderDetailsRemoteDataSource remoteDataSource;

  BulkOrderDetailsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<dynamic, List<BulkOrderDetailsEntity>>> getDetails(String symbol) async {
    try {
      final data = await remoteDataSource.getDetails(symbol);
      return Right(data);
    } catch (e) {
      return Left('Error fetching bulk order details for \$symbol');
    }
  }
}

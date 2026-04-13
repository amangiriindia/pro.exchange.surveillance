import 'package:dartz/dartz.dart';
import '../entities/bulk_order_details_entity.dart';

abstract class BulkOrderDetailsRepository {
  Future<Either<dynamic, List<BulkOrderDetailsEntity>>> getDetails(String symbol);
}

import 'package:dartz/dartz.dart';
import '../entities/bulk_order_entity.dart';

abstract class BulkOrderRepository {
  Future<Either<dynamic, List<BulkOrderEntity>>> getBulkOrders({
    int page = 1,
    int sizePerPage = 20,
  });
}

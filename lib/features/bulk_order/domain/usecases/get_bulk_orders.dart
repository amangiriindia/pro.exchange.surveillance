import 'package:dartz/dartz.dart';
import '../entities/bulk_order_entity.dart';
import '../repositories/bulk_order_repository.dart';

class GetBulkOrders {
  final BulkOrderRepository repository;

  GetBulkOrders(this.repository);

  Future<Either<dynamic, List<BulkOrderEntity>>> call() async {
    return await repository.getBulkOrders();
  }
}

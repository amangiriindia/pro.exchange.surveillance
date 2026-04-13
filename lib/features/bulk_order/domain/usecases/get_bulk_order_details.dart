import 'package:dartz/dartz.dart';
import '../entities/bulk_order_details_entity.dart';
import '../repositories/bulk_order_details_repository.dart';

class GetBulkOrderDetails {
  final BulkOrderDetailsRepository repository;

  GetBulkOrderDetails(this.repository);

  Future<Either<dynamic, List<BulkOrderDetailsEntity>>> call(String symbol) async {
    return await repository.getDetails(symbol);
  }
}

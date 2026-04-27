import 'package:dartz/dartz.dart';
import 'package:surveillance/core/errors/failures.dart';
import '../entities/same_ip_entity.dart';
import '../entities/same_ip_detail_entity.dart';

abstract class SameIPRepository {
  Future<Either<Failure, List<SameIPEntity>>> getSameIPData({
    int page = 1,
    int sizePerPage = 20,
  });
  Future<Either<Failure, List<SameIPDetailEntity>>> getSameIPDetails(
    int alertId,
  );
}

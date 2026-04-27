import 'package:dartz/dartz.dart';
import 'package:surveillance/core/errors/failures.dart';
import '../entities/btst_entity.dart';
import '../entities/btst_detail_entity.dart';

abstract class BTSTRepository {
  Future<Either<Failure, List<BTSTEntity>>> getBTSTData({
    int page = 1,
    int sizePerPage = 20,
  });
  Future<Either<Failure, List<BTSTDetailEntity>>> getBTSTDetails(int alertId);
}

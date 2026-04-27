import 'package:dartz/dartz.dart';
import 'package:surveillance/core/errors/failures.dart';

import '../entities/profit_cross_entity.dart';
import '../repositories/profit_cross_repository.dart';

class GetProfitCrossData {
  final ProfitCrossRepository repository;

  GetProfitCrossData(this.repository);

  Future<Either<Failure, List<ProfitCrossEntity>>> call({
    int page = 1,
    int sizePerPage = 20,
  }) async {
    return await repository.getProfitCrossData(
      page: page,
      sizePerPage: sizePerPage,
    );
  }
}

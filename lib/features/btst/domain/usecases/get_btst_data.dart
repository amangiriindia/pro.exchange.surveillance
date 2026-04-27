import 'package:dartz/dartz.dart';
import 'package:surveillance/core/errors/failures.dart';
import '../entities/btst_entity.dart';
import '../repositories/btst_repository.dart';

class GetBTSTData {
  final BTSTRepository repository;

  GetBTSTData(this.repository);

  Future<Either<Failure, List<BTSTEntity>>> call({
    int page = 1,
    int sizePerPage = 20,
  }) async {
    return await repository.getBTSTData(page: page, sizePerPage: sizePerPage);
  }
}

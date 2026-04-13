import 'package:dartz/dartz.dart';
import 'package:surveillance/core/errors/failures.dart';
import '../entities/btst_detail_entity.dart';
import '../repositories/btst_repository.dart';

class GetBTSTDetails {
  final BTSTRepository repository;

  GetBTSTDetails(this.repository);

  Future<Either<Failure, List<BTSTDetailEntity>>> call(String uName) async {
    return await repository.getBTSTDetails(uName);
  }
}

import 'package:dartz/dartz.dart';
import 'package:surveillance/core/errors/failures.dart';
import '../entities/same_ip_entity.dart';
import '../repositories/same_ip_repository.dart';

class GetSameIPData {
  final SameIPRepository repository;

  GetSameIPData(this.repository);

  Future<Either<Failure, List<SameIPEntity>>> call() async {
    return await repository.getSameIPData();
  }
}

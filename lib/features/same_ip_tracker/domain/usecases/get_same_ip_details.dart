import 'package:dartz/dartz.dart';
import 'package:surveillance/core/errors/failures.dart';
import '../entities/same_ip_detail_entity.dart';
import '../repositories/same_ip_repository.dart';

class GetSameIPDetails {
  final SameIPRepository repository;

  GetSameIPDetails(this.repository);

  Future<Either<Failure, List<SameIPDetailEntity>>> call(String clusterId) async {
    return await repository.getSameIPDetails(clusterId);
  }
}

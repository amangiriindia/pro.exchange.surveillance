import 'package:dartz/dartz.dart';
import 'package:surveillance/core/errors/failures.dart';
import '../entities/same_device_detail_entity.dart';
import '../repositories/same_device_repository.dart';

class GetSameDeviceDetails {
  final SameDeviceRepository repository;

  GetSameDeviceDetails(this.repository);

  Future<Either<Failure, List<SameDeviceDetailEntity>>> call(String clusterId) async {
    return await repository.getSameDeviceDetails(clusterId);
  }
}

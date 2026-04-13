import 'package:dartz/dartz.dart';
import 'package:surveillance/core/errors/failures.dart';
import '../entities/same_device_entity.dart';
import '../repositories/same_device_repository.dart';

class GetSameDeviceData {
  final SameDeviceRepository repository;

  GetSameDeviceData(this.repository);

  Future<Either<Failure, List<SameDeviceEntity>>> call() async {
    return await repository.getSameDeviceData();
  }
}

import 'package:dartz/dartz.dart';
import 'package:surveillance/core/errors/failures.dart';
import '../entities/same_device_entity.dart';
import '../entities/same_device_detail_entity.dart';

abstract class SameDeviceRepository {
  Future<Either<Failure, List<SameDeviceEntity>>> getSameDeviceData();
  Future<Either<Failure, List<SameDeviceDetailEntity>>> getSameDeviceDetails(String clusterId);
}

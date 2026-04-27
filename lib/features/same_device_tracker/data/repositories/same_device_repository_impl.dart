import 'package:dartz/dartz.dart';
import 'package:surveillance/core/errors/failures.dart';
import '../../domain/entities/same_device_entity.dart';
import '../../domain/entities/same_device_detail_entity.dart';
import '../../domain/repositories/same_device_repository.dart';
import '../datasources/same_device_remote_data_source.dart';

class SameDeviceRepositoryImpl implements SameDeviceRepository {
  final SameDeviceRemoteDataSource remoteDataSource;

  SameDeviceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<SameDeviceEntity>>> getSameDeviceData({
    int page = 1,
    int sizePerPage = 20,
  }) async {
    try {
      final remoteData = await remoteDataSource.getSameDeviceData(
        page: page,
        sizePerPage: sizePerPage,
      );
      return Right(remoteData);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<SameDeviceDetailEntity>>> getSameDeviceDetails(
    int alertId,
  ) async {
    try {
      final remoteData = await remoteDataSource.getSameDeviceDetails(alertId);
      return Right(remoteData);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:surveillance/core/errors/failures.dart';
import '../../domain/entities/jobber_tracker_entity.dart';
import '../../domain/entities/jobber_detail_entity.dart';
import '../../domain/repositories/jobber_tracker_repository.dart';
import '../datasources/jobber_tracker_remote_data_source.dart';

class JobberTrackerRepositoryImpl implements JobberTrackerRepository {
  final JobberTrackerRemoteDataSource remoteDataSource;

  JobberTrackerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<JobberTrackerEntity>>> getJobberTrackerData() async {
    try {
      final remoteData = await remoteDataSource.getJobberTrackerData();
      return Right(remoteData);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<JobberDetailEntity>>> getJobberDetails(String uName) async {
    try {
      final remoteData = await remoteDataSource.getJobberDetails(uName);
      return Right(remoteData);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}

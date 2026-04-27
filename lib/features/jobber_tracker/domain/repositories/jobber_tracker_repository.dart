import 'package:dartz/dartz.dart';
import 'package:surveillance/core/errors/failures.dart';
import '../entities/jobber_tracker_entity.dart';
import '../entities/jobber_detail_entity.dart';

abstract class JobberTrackerRepository {
  Future<Either<Failure, List<JobberTrackerEntity>>> getJobberTrackerData({
    int page = 1,
    int sizePerPage = 20,
  });
  Future<Either<Failure, List<JobberDetailEntity>>> getJobberDetails(
    int alertId,
  );
}

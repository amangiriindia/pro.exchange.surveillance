import 'package:dartz/dartz.dart';
import 'package:surveillance/core/errors/failures.dart';
import '../entities/jobber_tracker_entity.dart';
import '../repositories/jobber_tracker_repository.dart';

class GetJobberTrackerData {
  final JobberTrackerRepository repository;

  GetJobberTrackerData(this.repository);

  Future<Either<Failure, List<JobberTrackerEntity>>> call({
    int page = 1,
    int sizePerPage = 20,
  }) async {
    return await repository.getJobberTrackerData(
      page: page,
      sizePerPage: sizePerPage,
    );
  }
}

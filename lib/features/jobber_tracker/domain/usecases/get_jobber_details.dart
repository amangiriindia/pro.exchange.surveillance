import 'package:dartz/dartz.dart';
import 'package:surveillance/core/errors/failures.dart';
import '../entities/jobber_detail_entity.dart';
import '../repositories/jobber_tracker_repository.dart';

class GetJobberDetails {
  final JobberTrackerRepository repository;

  GetJobberDetails(this.repository);

  Future<Either<Failure, List<JobberDetailEntity>>> call(String uName) async {
    return await repository.getJobberDetails(uName);
  }
}

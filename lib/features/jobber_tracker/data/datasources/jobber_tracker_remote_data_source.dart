import 'package:dio/dio.dart';
import '../../../../core/constants/auth_constants.dart';
import '../models/jobber_tracker_model.dart';
import '../models/jobber_detail_model.dart';

abstract class JobberTrackerRemoteDataSource {
  Future<List<JobberTrackerModel>> getJobberTrackerData({
    int page,
    int sizePerPage,
  });
  Future<List<JobberDetailModel>> getJobberDetails(
    int alertId, {
    int page,
    int sizePerPage,
  });
}

class JobberTrackerRemoteDataSourceImpl
    implements JobberTrackerRemoteDataSource {
  final Dio dio;
  JobberTrackerRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<JobberTrackerModel>> getJobberTrackerData({
    int page = 1,
    int sizePerPage = 20,
  }) async {
    final response = await dio.get(
      AuthConstants.jobberTrackerListEndpoint,
      queryParameters: {'page': page, 'sizePerPage': sizePerPage},
    );
    final body = response.data['data'] as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>;
    return items
        .map((e) => JobberTrackerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<JobberDetailModel>> getJobberDetails(
    int alertId, {
    int page = 1,
    int sizePerPage = 20,
  }) async {
    final response = await dio.get(
      '${AuthConstants.jobberTrackerTradesEndpoint}/$alertId/trades',
      queryParameters: {'page': page, 'sizePerPage': sizePerPage},
    );
    final body = response.data['data'] as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>;
    return items
        .map((e) => JobberDetailModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

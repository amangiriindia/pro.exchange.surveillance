import 'package:dio/dio.dart';
import '../../../../core/constants/auth_constants.dart';
import '../models/bulk_order_details_model.dart';

abstract class BulkOrderDetailsRemoteDataSource {
  Future<List<BulkOrderDetailsModel>> getDetails(
    int alertId, {
    int page = 1,
    int sizePerPage = 20,
  });
}

class BulkOrderDetailsRemoteDataSourceImpl
    implements BulkOrderDetailsRemoteDataSource {
  final Dio dio;

  BulkOrderDetailsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<BulkOrderDetailsModel>> getDetails(
    int alertId, {
    int page = 1,
    int sizePerPage = 20,
  }) async {
    final response = await dio.get(
      '${AuthConstants.bulkOrderTradesEndpoint}/$alertId/trades',
      queryParameters: {'page': page, 'sizePerPage': sizePerPage},
    );
    final data = response.data as Map<String, dynamic>;
    final body = data['data'] as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>;
    return items
        .map((e) => BulkOrderDetailsModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

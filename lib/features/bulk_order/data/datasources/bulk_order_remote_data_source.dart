import 'package:dio/dio.dart';
import '../../../../core/constants/auth_constants.dart';
import '../models/bulk_order_model.dart';

abstract class BulkOrderRemoteDataSource {
  Future<List<BulkOrderModel>> getBulkOrders({
    int page = 1,
    int sizePerPage = 20,
  });
}

class BulkOrderRemoteDataSourceImpl implements BulkOrderRemoteDataSource {
  final Dio dio;

  BulkOrderRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<BulkOrderModel>> getBulkOrders({
    int page = 1,
    int sizePerPage = 20,
  }) async {
    final response = await dio.get(
      AuthConstants.bulkOrderListEndpoint,
      queryParameters: {'page': page, 'sizePerPage': sizePerPage},
    );
    final data = response.data as Map<String, dynamic>;
    final body = data['data'] as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>;
    return items
        .map((e) => BulkOrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

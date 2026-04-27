import 'package:dio/dio.dart';
import '../../../../core/constants/auth_constants.dart';
import '../models/profit_cross_model.dart';
import '../models/order_duration_model.dart';

abstract class ProfitCrossRemoteDataSource {
  Future<List<ProfitCrossModel>> getProfitCrossData({
    int page,
    int sizePerPage,
  });
  Future<List<OrderDurationModel>> getOrderDurationDetails(
    int alertId, {
    int page,
    int sizePerPage,
  });
}

class ProfitCrossRemoteDataSourceImpl implements ProfitCrossRemoteDataSource {
  final Dio dio;
  ProfitCrossRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ProfitCrossModel>> getProfitCrossData({
    int page = 1,
    int sizePerPage = 20,
  }) async {
    final response = await dio.get(
      AuthConstants.profitCrossListEndpoint,
      queryParameters: {'page': page, 'sizePerPage': sizePerPage},
    );
    final body = response.data['data'] as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>;
    return items
        .map((e) => ProfitCrossModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<OrderDurationModel>> getOrderDurationDetails(
    int alertId, {
    int page = 1,
    int sizePerPage = 20,
  }) async {
    final response = await dio.get(
      '${AuthConstants.profitCrossTradesEndpoint}/$alertId/trades',
      queryParameters: {'page': page, 'sizePerPage': sizePerPage},
    );
    final body = response.data['data'] as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>;
    return items
        .map((e) => OrderDurationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

import 'package:dio/dio.dart';
import '../../../../core/constants/auth_constants.dart';
import '../models/trade_comparison_model.dart';

abstract class TradeComparisonRemoteDataSource {
  Future<List<TradeComparisonModel>> getTradeComparisonData({
    int page = 1,
    int sizePerPage = 20,
  });
}

class TradeComparisonRemoteDataSourceImpl
    implements TradeComparisonRemoteDataSource {
  final Dio dio;

  TradeComparisonRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<TradeComparisonModel>> getTradeComparisonData({
    int page = 1,
    int sizePerPage = 20,
  }) async {
    final response = await dio.get(
      AuthConstants.tradeComparisonListEndpoint,
      queryParameters: {'page': page, 'sizePerPage': sizePerPage},
    );
    final items = response.data['data']['items'] as List<dynamic>;
    return items
        .map((e) => TradeComparisonModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

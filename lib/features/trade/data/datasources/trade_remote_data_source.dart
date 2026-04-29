import '../models/trade_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/auth_constants.dart';

class TradePaginatedResult {
  final List<TradeModel> trades;
  final int totalRecords;
  final int totalPages;
  final int currentPage;

  const TradePaginatedResult({
    required this.trades,
    required this.totalRecords,
    required this.totalPages,
    required this.currentPage,
  });
}

class TradeCountResult {
  final int totalTrades;
  final String? fromDate;
  final String? toDate;
  final bool isCustomRange;

  const TradeCountResult({
    required this.totalTrades,
    this.fromDate,
    this.toDate,
    required this.isCustomRange,
  });
}

abstract class TradeRemoteDataSource {
  Future<TradePaginatedResult> getTrades({int page = 1, int sizePerPage = 20});
  Future<TradeCountResult> getTradeCount();
}

class TradeRemoteDataSourceImpl implements TradeRemoteDataSource {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<TradePaginatedResult> getTrades({
    int page = 1,
    int sizePerPage = 20,
  }) async {
    final response = await _apiClient.client.get(
      AuthConstants.tradeListEndpoint,
      queryParameters: {'page': page, 'sizePerPage': sizePerPage},
    );

    final data = response.data as Map<String, dynamic>;
    final body = data['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final tradesJson =
        (body['items'] ?? body['trades']) as List<dynamic>? ?? <dynamic>[];

    return TradePaginatedResult(
      trades: tradesJson
          .map((e) => TradeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalRecords: (body['totalRecords'] as num?)?.toInt() ?? 0,
      totalPages: (body['totalPages'] as num?)?.toInt() ?? 1,
      currentPage: (body['currentPage'] as num?)?.toInt() ?? page,
    );
  }

  @override
  Future<TradeCountResult> getTradeCount() async {
    final response = await _apiClient.client.get(
      AuthConstants.tradeCountEndpoint,
    );

    final data = response.data as Map<String, dynamic>;
    final body = data['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return TradeCountResult(
      totalTrades: (body['totalTrades'] as num?)?.toInt() ?? 0,
      fromDate: body['fromDate'] as String?,
      toDate: body['toDate'] as String?,
      isCustomRange: body['isCustomRange'] as bool? ?? false,
    );
  }
}

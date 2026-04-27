import '../../../../core/constants/auth_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/group_trade_model.dart';

class GroupTradePaginatedResult {
  final List<GroupTradeModel> items;
  final int totalRecords;
  final int totalPages;
  final int currentPage;

  const GroupTradePaginatedResult({
    required this.items,
    required this.totalRecords,
    required this.totalPages,
    required this.currentPage,
  });
}

abstract class GroupTradeRemoteDataSource {
  Future<GroupTradePaginatedResult> getGroupTrades({int page = 1, int sizePerPage = 100});
}

class GroupTradeRemoteDataSourceImpl implements GroupTradeRemoteDataSource {
  @override
  Future<GroupTradePaginatedResult> getGroupTrades({int page = 1, int sizePerPage = 100}) async {
    final response = await ApiClient().dio.get(
      AuthConstants.groupTradeListEndpoint,
      queryParameters: {'page': page, 'sizePerPage': sizePerPage},
    );

    final data = response.data['data'] as Map<String, dynamic>;
    final itemsJson = data['items'] as List<dynamic>;

    return GroupTradePaginatedResult(
      items: itemsJson
          .map((e) => GroupTradeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalRecords: data['totalRecords'] as int? ?? 0,
      totalPages: data['totalPages'] as int? ?? 1,
      currentPage: data['currentPage'] as int? ?? page,
    );
  }
}

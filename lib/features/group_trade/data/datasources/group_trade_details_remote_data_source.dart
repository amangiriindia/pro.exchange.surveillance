import 'package:dio/dio.dart';
import '../../../../core/constants/auth_constants.dart';
import '../models/group_trade_details_model.dart';

abstract class GroupTradeDetailsRemoteDataSource {
  Future<List<GroupTradeDetailsModel>> getDetails(
    int alertId, {
    int page = 1,
    int sizePerPage = 50,
  });
}

class GroupTradeDetailsRemoteDataSourceImpl
    implements GroupTradeDetailsRemoteDataSource {
  final Dio dio;

  GroupTradeDetailsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<GroupTradeDetailsModel>> getDetails(
    int alertId, {
    int page = 1,
    int sizePerPage = 50,
  }) async {
    final response = await dio.get(
      '${AuthConstants.groupTradeListEndpoint}/$alertId/trades',
      queryParameters: {'page': page, 'sizePerPage': sizePerPage},
    );
    final data = response.data as Map<String, dynamic>;
    final body = data['data'] as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>;
    return items
        .map((e) => GroupTradeDetailsModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

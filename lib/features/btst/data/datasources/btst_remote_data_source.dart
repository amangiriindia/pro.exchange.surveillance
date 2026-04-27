import 'package:dio/dio.dart';
import '../../../../core/constants/auth_constants.dart';
import '../models/btst_model.dart';
import '../models/btst_detail_model.dart';

abstract class BTSTRemoteDataSource {
  Future<List<BTSTModel>> getBTSTData({int page = 1, int sizePerPage = 20});
  Future<List<BTSTDetailModel>> getBTSTDetails(int alertId);
}

class BTSTRemoteDataSourceImpl implements BTSTRemoteDataSource {
  final Dio dio;

  BTSTRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<BTSTModel>> getBTSTData({
    int page = 1,
    int sizePerPage = 20,
  }) async {
    final response = await dio.get(
      AuthConstants.btstListEndpoint,
      queryParameters: {'page': page, 'sizePerPage': sizePerPage},
    );
    final items = response.data['data']['items'] as List<dynamic>;
    return items
        .map((e) => BTSTModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<BTSTDetailModel>> getBTSTDetails(int alertId) async {
    final response = await dio.get(
      '${AuthConstants.btstTradesEndpoint}/$alertId/trades',
    );
    final items = response.data['data']['items'] as List<dynamic>;
    return items
        .map((e) => BTSTDetailModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

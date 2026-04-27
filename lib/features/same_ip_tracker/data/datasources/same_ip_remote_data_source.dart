import 'package:dio/dio.dart';
import '../../../../core/constants/auth_constants.dart';
import '../models/same_ip_model.dart';
import '../models/same_ip_detail_model.dart';

abstract class SameIPRemoteDataSource {
  Future<List<SameIPModel>> getSameIPData({int page = 1, int sizePerPage = 20});
  Future<List<SameIPDetailModel>> getSameIPDetails(int alertId);
}

class SameIPRemoteDataSourceImpl implements SameIPRemoteDataSource {
  final Dio dio;

  SameIPRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<SameIPModel>> getSameIPData({
    int page = 1,
    int sizePerPage = 20,
  }) async {
    final response = await dio.get(
      AuthConstants.sameIPListEndpoint,
      queryParameters: {'page': page, 'sizePerPage': sizePerPage},
    );
    final items = response.data['data']['items'] as List<dynamic>;
    return items
        .map((e) => SameIPModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<SameIPDetailModel>> getSameIPDetails(int alertId) async {
    final response = await dio.get(
      '${AuthConstants.sameIPTradesEndpoint}/$alertId/trades',
    );
    final items = response.data['data']['items'] as List<dynamic>;
    return items
        .map((e) => SameIPDetailModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

import 'package:dio/dio.dart';
import '../../../../core/constants/auth_constants.dart';
import '../models/same_device_model.dart';
import '../models/same_device_detail_model.dart';

abstract class SameDeviceRemoteDataSource {
  Future<List<SameDeviceModel>> getSameDeviceData({
    int page = 1,
    int sizePerPage = 20,
  });
  Future<List<SameDeviceModelDetail>> getSameDeviceDetails(int alertId);
}

class SameDeviceRemoteDataSourceImpl implements SameDeviceRemoteDataSource {
  final Dio dio;

  SameDeviceRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<SameDeviceModel>> getSameDeviceData({
    int page = 1,
    int sizePerPage = 20,
  }) async {
    final response = await dio.get(
      AuthConstants.sameDeviceListEndpoint,
      queryParameters: {'page': page, 'sizePerPage': sizePerPage},
    );
    final items = response.data['data']['items'] as List<dynamic>;
    return items
        .map((e) => SameDeviceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<SameDeviceModelDetail>> getSameDeviceDetails(int alertId) async {
    final response = await dio.get(
      '${AuthConstants.sameDeviceTradesEndpoint}/$alertId/trades',
    );
    final items = response.data['data']['items'] as List<dynamic>;
    return items
        .map((e) => SameDeviceModelDetail.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

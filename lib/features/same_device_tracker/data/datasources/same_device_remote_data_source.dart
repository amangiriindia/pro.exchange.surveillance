import '../models/same_device_model.dart';
import '../models/same_device_detail_model.dart';

abstract class SameDeviceRemoteDataSource {
  Future<List<SameDeviceModel>> getSameDeviceData();
  Future<List<SameDeviceModelDetail>> getSameDeviceDetails(String clusterId);
}

class SameDeviceRemoteDataSourceImpl implements SameDeviceRemoteDataSource {
  @override
  Future<List<SameDeviceModel>> getSameDeviceData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const SameDeviceModel(
        time: '13/03/2026 | 10:22:02 AM',
        uName: 'DEMO56/DEMO/DEMO 04',
        deviceId: 'F8:E9:4E:0A:9B:1C',
      ),
      const SameDeviceModel(
        time: '13/03/2026 | 10:22:02 AM',
        uName: 'DEMO4/Shah/Demo05/Patel',
        deviceId: 'D1:A2:B3:C4:E5:F6',
      ),
      const SameDeviceModel(
        time: '13/03/2026 | 10:22:02 AM',
        uName: 'DEMO56/Demo01/Parmar01/DEMO09',
        deviceId: 'A1:B2:C3:D4:E5:66',
      ),
    ];
  }

  @override
  Future<List<SameDeviceModelDetail>> getSameDeviceDetails(String clusterId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      const SameDeviceModelDetail(
        uName: 'DEMO56',
        pUser: 'DEMO',
        exch: 'MCX',
        symbol: 'RELIANCE',
        orderTime: '22/11/25 03:06:34 PM',
        buySell: 'SELL - SL Market',
        quantity: -500.0,
        lot: 1.0,
        type: 'Market',
        pl: 36200.0,
        tPrice: 124191.0,
        brk: 0.0,
        rPrice: 0.0,
      ),
      const SameDeviceModelDetail(
        uName: 'DEMO4',
        pUser: 'DEMO49',
        exch: 'MCX',
        symbol: 'RELIANCE',
        orderTime: '22/11/25 03:06:34 PM',
        buySell: 'BUY - SL Add Trade',
        quantity: 1000000.0,
        lot: 1.0,
        type: 'Market',
        pl: 36200.0,
        tPrice: 124191.0,
        brk: 0.0,
        rPrice: 0.0,
      ),
    ];
  }
}

import '../models/same_ip_model.dart';
import '../models/same_ip_detail_model.dart';

abstract class SameIPRemoteDataSource {
  Future<List<SameIPModel>> getSameIPData();
  Future<List<SameIPDetailModel>> getSameIPDetails(String clusterId);
}

class SameIPRemoteDataSourceImpl implements SameIPRemoteDataSource {
  @override
  Future<List<SameIPModel>> getSameIPData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const SameIPModel(
        time: '13/03/2026 | 10:22:02 AM',
        uName: 'DEMO56/DEMO/DEMO 01',
        ipAddress: '192.0.2.1',
      ),
      const SameIPModel(
        time: '13/03/2026 | 10:22:02 AM',
        uName: 'DEMO4/Shah/Demo05/Patel',
        ipAddress: '192.0.2.1',
      ),
      const SameIPModel(
        time: '13/03/2026 | 10:22:02 AM',
        uName: 'DEMO56/Demo01/Parmar01/DEMO09',
        ipAddress: '192.0.2.1',
      ),
      const SameIPModel(
        time: '13/03/2026 | 10:22:02 AM',
        uName: 'DEMO4/Shah/Demo05/Patel',
        ipAddress: '192.0.2.1',
      ),
    ];
  }

  @override
  Future<List<SameIPDetailModel>> getSameIPDetails(String clusterId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      const SameIPDetailModel(
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
      const SameIPDetailModel(
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

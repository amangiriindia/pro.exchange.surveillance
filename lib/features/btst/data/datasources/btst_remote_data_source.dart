import '../models/btst_model.dart';
import '../models/btst_detail_model.dart';

abstract class BTSTRemoteDataSource {
  Future<List<BTSTModel>> getBTSTData();
  Future<List<BTSTDetailModel>> getBTSTDetails(String uName);
}

class BTSTRemoteDataSourceImpl implements BTSTRemoteDataSource {
  @override
  Future<List<BTSTModel>> getBTSTData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const BTSTModel(
        uName: 'DEMO56',
        pUser: 'DEMO',
        exchange: 'MCX',
        symbol: 'GOLD',
        pnl: 36200.0,
        inTime: '13/03/2026 | 10:22:02 AM',
        outTime: '13/03/2026 | 10:22:02 AM',
        orderDuration: '11 hours 47 minutes',
      ),
      const BTSTModel(
        uName: 'DEMO4',
        pUser: 'DEMO49',
        exchange: 'MCX',
        symbol: 'GOLD',
        pnl: 36200.0,
        inTime: '13/03/2026 | 10:22:02 AM',
        outTime: '13/03/2026 | 10:22:02 AM',
        orderDuration: '11 hours 47 minutes',
      ),
      const BTSTModel(
        uName: 'DEMO56',
        pUser: 'DEMO49',
        exchange: 'MCX',
        symbol: 'GOLD',
        pnl: 36200.0,
        inTime: '13/03/2026 | 10:22:02 AM',
        outTime: '13/03/2026 | 10:22:02 AM',
        orderDuration: '11 hours 47 minutes',
      ),
    ];
  }

  @override
  Future<List<BTSTDetailModel>> getBTSTDetails(String uName) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      const BTSTDetailModel(
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
      const BTSTDetailModel(
        uName: 'DEMO56',
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

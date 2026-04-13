import '../models/jobber_tracker_model.dart';
import '../models/jobber_detail_model.dart';

abstract class JobberTrackerRemoteDataSource {
  Future<List<JobberTrackerModel>> getJobberTrackerData();
  Future<List<JobberDetailModel>> getJobberDetails(String uName);
}

class JobberTrackerRemoteDataSourceImpl implements JobberTrackerRemoteDataSource {
  @override
  Future<List<JobberTrackerModel>> getJobberTrackerData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const JobberTrackerModel(
        time: '13/03/2026 | 10:22:02 AM',
        uName: 'DEMO56',
        pUser: 'DEMO',
        exchange: 'MCX',
        symbol: 'GOLD',
        tradeFrequency: 10,
        pnl: 36200.0,
      ),
      const JobberTrackerModel(
        time: '13/03/2026 | 10:22:02 AM',
        uName: 'DEMO4',
        pUser: 'DEMO49',
        exchange: 'MCX',
        symbol: 'GOLD',
        tradeFrequency: 3,
        pnl: 36200.0,
      ),
      const JobberTrackerModel(
        time: '13/03/2026 | 10:22:02 AM',
        uName: 'DEMO56',
        pUser: 'DEMO49',
        exchange: 'MCX',
        symbol: 'GOLD',
        tradeFrequency: 1,
        pnl: 36200.0,
      ),
      const JobberTrackerModel(
        time: '13/03/2026 | 10:22:02 AM',
        uName: 'DEMO4',
        pUser: 'DEMO12',
        exchange: 'MCX',
        symbol: 'GOLD',
        tradeFrequency: 2,
        pnl: 36200.0,
      ),
    ];
  }

  @override
  Future<List<JobberDetailModel>> getJobberDetails(String uName) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      const JobberDetailModel(
        uName: 'DEMO56',
        pUser: 'DEMO',
        exch: 'MCX',
        symbol: 'GOLD',
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
      const JobberDetailModel(
        uName: 'DEMO56',
        pUser: 'DEMO49',
        exch: 'MCX',
        symbol: 'GOLD',
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
      const JobberDetailModel(
        uName: 'DEMO56',
        pUser: 'DEMO49',
        exch: 'MCX',
        symbol: 'GOLD',
        orderTime: '22/11/25 03:06:34 PM',
        buySell: 'SELL - SL Add Trade',
        quantity: -500.0,
        lot: 1.0,
        type: 'Market',
        pl: 36200.0,
        tPrice: -256.0,
        brk: 0.0,
        rPrice: 0.0,
      ),
    ];
  }
}

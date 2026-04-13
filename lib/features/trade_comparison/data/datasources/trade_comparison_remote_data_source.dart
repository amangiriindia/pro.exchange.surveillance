import '../models/trade_comparison_model.dart';

abstract class TradeComparisonRemoteDataSource {
  Future<List<TradeComparisonModel>> getTradeComparisonData();
}

class TradeComparisonRemoteDataSourceImpl implements TradeComparisonRemoteDataSource {
  @override
  Future<List<TradeComparisonModel>> getTradeComparisonData() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      const TradeComparisonModel(
        uName: 'DEM41',
        pUser: 'DEMO',
        exch: 'MCX',
        symbol: 'RELIANCE',
        orderDateTime: '22/11/25 03:06:34 PM',
        buySell: 'SELL - SL Market',
        quantity: -500.0,
        lot: 1.0,
        type: 'Market',
        pl: 36200.0,
        tPrice: 124191.0,
        brk: 0.0,
        rPrice: 0.0,
        executionDateTime: '22/11/25 03:06:34 PM',
        deviceId: 'i Phone',
        ipAddress: '192.0.2.1',
        city: 'Bhuj',
      ),
      const TradeComparisonModel(
        uName: 'DEMO4',
        pUser: 'DEMO49',
        exch: 'MCX',
        symbol: 'RELIANCE',
        orderDateTime: '22/11/25 03:06:34 PM',
        buySell: 'BUY - SL Add Trade',
        quantity: 1000000.0,
        lot: 1.0,
        type: 'Market',
        pl: 36200.0,
        tPrice: 124191.0,
        brk: 0.0,
        rPrice: 0.0,
        executionDateTime: '22/11/25 03:06:34 PM',
        deviceId: 'i Phone',
        ipAddress: '192.0.2.1',
        city: 'Bhuj',
      ),
      const TradeComparisonModel(
        uName: 'DEM41',
        pUser: 'DEMO49',
        exch: 'MCX',
        symbol: 'RELIANCE',
        orderDateTime: '22/11/25 03:06:34 PM',
        buySell: 'SELL - SL Add Trade',
        quantity: -500.0,
        lot: 1.0,
        type: 'Market',
        pl: 36200.0,
        tPrice: -256.0,
        brk: 0.0,
        rPrice: 0.0,
        executionDateTime: '22/11/25 03:06:34 PM',
        deviceId: 'i Phone',
        ipAddress: '192.0.2.1',
        city: 'Bhuj',
      ),
      const TradeComparisonModel(
        uName: 'DEMO4',
        pUser: 'DEMO12',
        exch: 'MCX',
        symbol: 'RELIANCE',
        orderDateTime: '22/11/25 03:06:34 PM',
        buySell: 'BUY - SL Exit Market',
        quantity: 100.0,
        lot: 1.0,
        type: 'Market',
        pl: 36200.0,
        tPrice: 124191.0,
        brk: 0.0,
        rPrice: 0.0,
        executionDateTime: '22/11/25 03:06:34 PM',
        deviceId: 'i Phone',
        ipAddress: '192.0.2.1',
        city: 'Bhuj',
      ),
    ];
  }
}

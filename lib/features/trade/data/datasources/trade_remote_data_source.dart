import '../models/trade_model.dart';
import 'package:dartz/dartz.dart';

abstract class TradeRemoteDataSource {
  Future<List<TradeModel>> getTrades();
}

class TradeRemoteDataSourceImpl implements TradeRemoteDataSource {
  @override
  Future<List<TradeModel>> getTrades() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    return List.generate(20, (index) {
      return TradeModel(
        uName: index % 2 == 0 ? 'DEMO56' : 'DEMO4',
        pUser: index % 3 == 0 ? 'DEMO' : 'DEMO49',
        exchange: 'MCX',
        symbol: 'RELIANCE',
        orderDateTime: '22/11/25 03:06:34 PM',
        buySell: index % 3 == 0 ? 'SELL - L Market' : (index % 2 == 0 ? 'BUY - SL Add Trade' : 'SELL - SL Add Trade'),
        quantity: index % 2 == 0 ? -500.00 : 100000.0,
        lot: 1.00,
        type: 'Market',
        profitLoss: 36200.00,
        tradePrice: 124191.00,
        brk: 0.00,
        rPrice: 0.00,
        executionDateTime: '22/11/25 03:06:34 PM',
        deviceId: 'E621E1F8-C36C-495A-93FC-0C247A3E6E5F',
        ipAddress: '192.0.2.1',
        city: 'Bhuj',
      );
    });
  }
}

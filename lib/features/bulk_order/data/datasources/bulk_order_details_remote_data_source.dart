import '../models/bulk_order_details_model.dart';

abstract class BulkOrderDetailsRemoteDataSource {
  Future<List<BulkOrderDetailsModel>> getDetails(String symbol);
}

class BulkOrderDetailsRemoteDataSourceImpl implements BulkOrderDetailsRemoteDataSource {
  @override
  Future<List<BulkOrderDetailsModel>> getDetails(String symbol) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return List.generate(20, (index) {
      bool isSell = index % 2 == 0;
      return BulkOrderDetailsModel(
        uName: index % 3 == 0 ? 'DEMO4' : 'DEMO56',
        pUser: index % 2 == 0 ? 'DEMO' : (index % 3 == 0 ? 'DEMO12' : 'DEMO49'),
        exch: 'MCX',
        symbol: symbol,
        orderTime: '22/11/25 03:06:34 PM',
        buySell: isSell ? 'SELL - SL Market' : 'BUY - SL Add Trade',
        quantity: isSell ? -500.00 : 1000000.00,
        lot: 1.00,
        type: 'Market',
        pl: 36200.00,
        tPrice: index == 2 ? -256.00 : 124191.00,
        brk: 0.00,
        rPrice: 0.00,
        executionTime: '22/11/25 03:06:34 PM',
        deviceId: 'E621E1F8-C36C-495A-93FC-0C247A3E6E5F',
        ipAddress: '192.0.2.1',
        city: 'Bhuj',
      );
    });
  }
}

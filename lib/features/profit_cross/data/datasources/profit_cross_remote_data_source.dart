import '../models/profit_cross_model.dart';
import '../models/order_duration_model.dart';

abstract class ProfitCrossRemoteDataSource {
  Future<List<ProfitCrossModel>> getProfitCrossData();
  Future<List<OrderDurationModel>> getOrderDurationDetails(String symbol);
}

class ProfitCrossRemoteDataSourceImpl implements ProfitCrossRemoteDataSource {
  @override
  Future<List<ProfitCrossModel>> getProfitCrossData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.generate(20, (index) {
      return ProfitCrossModel(
        time: '13/03/2026 | 10:22:02 AM',
        exchange: 'MCX',
        symbol: 'RELIANCE',
        orderDT: '22/11/25 03:06:34 PM',
        pnl: 36200.0,
        orderDuration: '11 hours 47 minutes',
        pnlPercentage: (index + 1).toDouble(),
      );
    });
  }

  @override
  Future<List<OrderDurationModel>> getOrderDurationDetails(String symbol) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.generate(3, (index) {
      return OrderDurationModel(
        duration: '3 hours 20 min',
        symbol: 'MCX SILVER Dec 05',
        type: index == 1 ? 'Sell' : 'Buy Limit',
        qty: 5000.0,
        price: 1000000.0,
        executionDT: '28-03-26 04:33:00 PM',
        pnl: index == 1 ? -1000000.0 : 1000000.0,
      );
    });
  }
}

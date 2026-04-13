import '../models/bulk_order_model.dart';
import 'package:dartz/dartz.dart';

abstract class BulkOrderRemoteDataSource {
  Future<List<BulkOrderModel>> getBulkOrders();
}

class BulkOrderRemoteDataSourceImpl implements BulkOrderRemoteDataSource {
  @override
  Future<List<BulkOrderModel>> getBulkOrders() async {
    await Future.delayed(const Duration(seconds: 1));
    
    return List.generate(15, (index) {
      final isReliance = index % 2 == 0;
      final qty = index == 0 ? 5000.0 : 
                  index == 1 ? 7000.0 : 
                  index == 2 ? 9501.0 : 
                  index == 3 ? 10000.0 : 
                  index == 4 ? 205000.0 : 
                  3200.0;
                  
      // Negative value implies Red in our simple mockup logic
      final finalQty = index % 2 == 0 ? -qty : qty;
      
      return BulkOrderModel(
        time: '13/03/2026 | 10:22:02 AM',
        exchange: 'NSE',
        symbol: isReliance ? 'TCS' : 'RELIANCE',
        quantity: finalQty,
      );
    });
  }
}

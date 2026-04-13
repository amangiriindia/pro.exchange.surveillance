import '../../domain/entities/order_duration_entity.dart';

class OrderDurationModel extends OrderDurationEntity {
  const OrderDurationModel({
    required super.duration,
    required super.symbol,
    required super.type,
    required super.qty,
    required super.price,
    required super.executionDT,
    required super.pnl,
  });

  factory OrderDurationModel.fromJson(Map<String, dynamic> json) {
    return OrderDurationModel(
      duration: json['duration'],
      symbol: json['symbol'],
      type: json['type'],
      qty: (json['qty'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      executionDT: json['execution_dt'],
      pnl: (json['pnl'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'duration': duration,
      'symbol': symbol,
      'type': type,
      'qty': qty,
      'price': price,
      'execution_dt': executionDT,
      'pnl': pnl,
    };
  }
}

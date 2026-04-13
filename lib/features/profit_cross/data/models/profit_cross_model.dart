import '../../domain/entities/profit_cross_entity.dart';

class ProfitCrossModel extends ProfitCrossEntity {
  const ProfitCrossModel({
    required super.time,
    required super.exchange,
    required super.symbol,
    required super.orderDT,
    required super.pnl,
    required super.orderDuration,
    required super.pnlPercentage,
  });

  factory ProfitCrossModel.fromJson(Map<String, dynamic> json) {
    return ProfitCrossModel(
      time: json['time'],
      exchange: json['exchange'],
      symbol: json['symbol'],
      orderDT: json['order_dt'],
      pnl: (json['pnl'] as num).toDouble(),
      orderDuration: json['order_duration'],
      pnlPercentage: (json['pnl_percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'exchange': exchange,
      'symbol': symbol,
      'order_dt': orderDT,
      'pnl': pnl,
      'order_duration': orderDuration,
      'pnl_percentage': pnlPercentage,
    };
  }
}

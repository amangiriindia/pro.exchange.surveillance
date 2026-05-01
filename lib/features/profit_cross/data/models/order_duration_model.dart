import '../../domain/entities/order_duration_entity.dart';

class OrderDurationModel extends OrderDurationEntity {
  const OrderDurationModel({
    required super.id,
    required super.duration,
    required super.symbol,
    required super.exchange,
    required super.symbolName,
    required super.type,
    required super.tradeType,
    required super.qty,
    required super.price,
    required super.executionDT,
    required super.pnl,
    super.orderType,
    super.comment,
  });

  factory OrderDurationModel.fromJson(Map<String, dynamic> json) {
    return OrderDurationModel(
      id: (json['id'] ?? 0) as int,
      duration: json['duration'] ?? '',
      symbol: json['symbol'] ?? '',
      exchange: json['exchange'] ?? '',
      symbolName: json['symbolName'] ?? '',
      type: json['type'] ?? '',
      tradeType: json['tradeType'] ?? '',
      qty: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      executionDT: json['executionDateTime'] ?? '',
      pnl: double.tryParse(json['profitLoss']?.toString() ?? '0') ?? 0,
      orderType: json['orderType'] as String?,
      comment: json['comment'] as String?,
    );
  }
}

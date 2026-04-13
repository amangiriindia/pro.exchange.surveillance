import '../../domain/entities/bulk_order_entity.dart';

class BulkOrderModel extends BulkOrderEntity {
  const BulkOrderModel({
    required super.time,
    required super.exchange,
    required super.symbol,
    required super.quantity,
  });

  factory BulkOrderModel.fromJson(Map<String, dynamic> json) {
    return BulkOrderModel(
      time: json['time'] ?? '',
      exchange: json['exchange'] ?? '',
      symbol: json['symbol'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
    );
  }
}

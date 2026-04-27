import '../../domain/entities/bulk_order_entity.dart';

class BulkOrderModel extends BulkOrderEntity {
  const BulkOrderModel({
    required super.id,
    required super.time,
    required super.exchange,
    required super.symbol,
    required super.tradeType,
    required super.quantity,
    required super.threshold,
    required super.exceedsThreshold,
    required super.investigateStatus,
    required super.isRead,
    required super.clientIds,
    required super.tradeIds,
  });

  factory BulkOrderModel.fromJson(Map<String, dynamic> json) {
    return BulkOrderModel(
      id: (json['id'] ?? 0) as int,
      time: json['time'] ?? '',
      exchange: json['exchange'] ?? '',
      symbol: json['symbol'] ?? '',
      tradeType: json['tradeType'] ?? '',
      quantity: (json['quantity'] ?? 0) as int,
      threshold: (json['threshold'] ?? 0) as int,
      exceedsThreshold: json['exceedsThreshold'] ?? false,
      investigateStatus: json['investigateStatus'] ?? '',
      isRead: json['isRead'] ?? false,
      clientIds: (json['clientIds'] as List<dynamic>? ?? []).cast<int>(),
      tradeIds: (json['tradeIds'] as List<dynamic>? ?? []).cast<int>(),
    );
  }
}

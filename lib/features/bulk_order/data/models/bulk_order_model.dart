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
      id: (json['id'] as num?)?.toInt() ?? 0,
      time: json['time']?.toString() ?? '',
      exchange: json['exchange']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
      tradeType: json['tradeType']?.toString() ?? '',
      quantity: _asDouble(json['quantity']),
      threshold: _asInt(json['threshold']),
      exceedsThreshold: json['exceedsThreshold'] == true,
      investigateStatus: json['investigateStatus']?.toString() ?? '',
      isRead: json['isRead'] == true,
      clientIds: (json['clientIds'] as List<dynamic>? ?? [])
          .map((e) => (e as num).toInt())
          .toList(),
      tradeIds: (json['tradeIds'] as List<dynamic>? ?? [])
          .map((e) => (e as num).toInt())
          .toList(),
    );
  }

  static double _asDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.round();
    return int.tryParse(v.toString()) ?? 0;
  }
}

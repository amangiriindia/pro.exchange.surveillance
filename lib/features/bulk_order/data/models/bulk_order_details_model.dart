import '../../domain/entities/bulk_order_details_entity.dart';

class BulkOrderDetailsModel extends BulkOrderDetailsEntity {
  const BulkOrderDetailsModel({
    required super.uName,
    required super.pUser,
    required super.exch,
    required super.symbol,
    required super.orderTime,
    required super.buySell,
    required super.quantity,
    required super.lot,
    required super.type,
    required super.pl,
    required super.tPrice,
    required super.brk,
    required super.rPrice,
    required super.executionTime,
    required super.deviceId,
    required super.ipAddress,
    required super.city,
  });

  factory BulkOrderDetailsModel.fromJson(Map<String, dynamic> json) {
    return BulkOrderDetailsModel(
      uName: json['u_name'] ?? '',
      pUser: json['p_user'] ?? '',
      exch: json['exch'] ?? '',
      symbol: json['symbol'] ?? '',
      orderTime: json['order_time'] ?? '',
      buySell: json['buy_sell'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      lot: (json['lot'] ?? 0).toDouble(),
      type: json['type'] ?? '',
      pl: (json['pl'] ?? 0).toDouble(),
      tPrice: (json['t_price'] ?? 0).toDouble(),
      brk: (json['brk'] ?? 0).toDouble(),
      rPrice: (json['r_price'] ?? 0).toDouble(),
      executionTime: json['execution_time'] ?? '',
      deviceId: json['device_id'] ?? '',
      ipAddress: json['ip_address'] ?? '',
      city: json['city'] ?? '',
    );
  }
}

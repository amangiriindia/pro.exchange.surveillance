import '../../domain/entities/trade_comparison_entity.dart';

class TradeComparisonModel extends TradeComparisonEntity {
  const TradeComparisonModel({
    required super.uName,
    required super.pUser,
    required super.exch,
    required super.symbol,
    required super.orderDateTime,
    required super.buySell,
    required super.quantity,
    required super.lot,
    required super.type,
    required super.pl,
    required super.tPrice,
    required super.brk,
    required super.rPrice,
    required super.executionDateTime,
    required super.deviceId,
    required super.ipAddress,
    required super.city,
  });

  factory TradeComparisonModel.fromJson(Map<String, dynamic> json) {
    return TradeComparisonModel(
      uName: json['u_name'],
      pUser: json['p_user'],
      exch: json['exch'],
      symbol: json['symbol'],
      orderDateTime: json['order_date_time'],
      buySell: json['buy_sell'],
      quantity: (json['quantity'] as num).toDouble(),
      lot: (json['lot'] as num).toDouble(),
      type: json['type'],
      pl: (json['pl'] as num).toDouble(),
      tPrice: (json['t_price'] as num).toDouble(),
      brk: (json['brk'] as num).toDouble(),
      rPrice: (json['r_price'] as num).toDouble(),
      executionDateTime: json['execution_date_time'],
      deviceId: json['device_id'],
      ipAddress: json['ip_address'],
      city: json['city'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'u_name': uName,
      'p_user': pUser,
      'exch': exch,
      'symbol': symbol,
      'order_date_time': orderDateTime,
      'buy_sell': buySell,
      'quantity': quantity,
      'lot': lot,
      'type': type,
      'pl': pl,
      't_price': tPrice,
      'brk': brk,
      'r_price': rPrice,
      'execution_date_time': executionDateTime,
      'device_id': deviceId,
      'ip_address': ipAddress,
      'city': city,
    };
  }
}

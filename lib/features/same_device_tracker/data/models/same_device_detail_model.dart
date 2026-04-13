import '../../domain/entities/same_device_detail_entity.dart';

class SameDeviceModelDetail extends SameDeviceDetailEntity {
  const SameDeviceModelDetail({
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
  });

  factory SameDeviceModelDetail.fromJson(Map<String, dynamic> json) {
    return SameDeviceModelDetail(
      uName: json['u_name'],
      pUser: json['p_user'],
      exch: json['exch'],
      symbol: json['symbol'],
      orderTime: json['order_time'],
      buySell: json['buy_sell'],
      quantity: (json['quantity'] as num).toDouble(),
      lot: (json['lot'] as num).toDouble(),
      type: json['type'],
      pl: (json['pl'] as num).toDouble(),
      tPrice: (json['t_price'] as num).toDouble(),
      brk: (json['brk'] as num).toDouble(),
      rPrice: (json['r_price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'u_name': uName,
      'p_user': pUser,
      'exch': exch,
      'symbol': symbol,
      'order_time': orderTime,
      'buy_sell': buySell,
      'quantity': quantity,
      'lot': lot,
      'type': type,
      'pl': pl,
      't_price': tPrice,
      'brk': brk,
      'r_price': rPrice,
    };
  }
}

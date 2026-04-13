import '../../domain/entities/btst_entity.dart';

class BTSTModel extends BTSTEntity {
  const BTSTModel({
    required super.uName,
    required super.pUser,
    required super.exchange,
    required super.symbol,
    required super.pnl,
    required super.inTime,
    required super.outTime,
    required super.orderDuration,
  });

  factory BTSTModel.fromJson(Map<String, dynamic> json) {
    return BTSTModel(
      uName: json['u_name'],
      pUser: json['p_user'],
      exchange: json['exchange'],
      symbol: json['symbol'],
      pnl: (json['pnl'] as num).toDouble(),
      inTime: json['in_time'],
      outTime: json['out_time'],
      orderDuration: json['order_duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'u_name': uName,
      'p_user': pUser,
      'exchange': exchange,
      'symbol': symbol,
      'pnl': pnl,
      'in_time': inTime,
      'out_time': outTime,
      'order_duration': orderDuration,
    };
  }
}

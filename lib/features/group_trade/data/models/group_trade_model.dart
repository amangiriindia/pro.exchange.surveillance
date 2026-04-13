import '../../domain/entities/group_trade_entity.dart';

class GroupTradeModel extends GroupTradeEntity {
  const GroupTradeModel({
    required super.uName,
    required super.pUser,
    required super.exchange,
    required super.symbol,
    required super.orderDateTime,
    required super.buySell,
    required super.quantity,
    required super.lot,
    required super.type,
    required super.profitLoss,
    required super.tradePrice,
    super.brk,
    super.rPrice,
    super.executionDateTime,
    super.deviceId,
    super.ipAddress,
    super.city,
  });

  factory GroupTradeModel.fromJson(Map<String, dynamic> json) {
    return GroupTradeModel(
      uName: json['u_name'] ?? '',
      pUser: json['p_user'] ?? '',
      exchange: json['exchange'] ?? '',
      symbol: json['symbol'] ?? '',
      orderDateTime: json['order_dt'] ?? '',
      buySell: json['buy_sell'] ?? '',
      quantity: (json['qty'] ?? 0).toDouble(),
      lot: (json['lot'] ?? 0).toDouble(),
      type: json['type'] ?? '',
      profitLoss: (json['pl'] ?? 0).toDouble(),
      tradePrice: (json['t_price'] ?? 0).toDouble(),
      brk: json['brk']?.toDouble(),
      rPrice: json['r_price']?.toDouble(),
      executionDateTime: json['execution_dt'],
      deviceId: json['device_id'],
      ipAddress: json['ip_address'],
      city: json['city'],
    );
  }
}

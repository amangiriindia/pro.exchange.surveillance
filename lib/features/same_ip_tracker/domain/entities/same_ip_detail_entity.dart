import 'package:equatable/equatable.dart';

class SameIPDetailEntity extends Equatable {
  final int id;
  final String uName;
  final String pUser;
  final String exch;
  final String symbol;
  final String orderTime;
  final String buySell;
  final String tradeType;
  final String mainOrderType;
  final double quantity;
  final double lot;
  final String type;
  final double pl;
  final double tPrice;
  final double brk;
  final double rPrice;
  final String executionTime;
  final String deviceId;
  final String ipAddress;
  final String city;

  const SameIPDetailEntity({
    required this.id,
    required this.uName,
    required this.pUser,
    required this.exch,
    required this.symbol,
    required this.orderTime,
    required this.buySell,
    required this.tradeType,
    required this.mainOrderType,
    required this.quantity,
    required this.lot,
    required this.type,
    required this.pl,
    required this.tPrice,
    required this.brk,
    required this.rPrice,
    required this.executionTime,
    required this.deviceId,
    required this.ipAddress,
    required this.city,
  });

  @override
  List<Object> get props => [
    id,
    uName,
    pUser,
    exch,
    symbol,
    orderTime,
    buySell,
    quantity,
    lot,
    type,
    pl,
    tPrice,
    brk,
    rPrice,
  ];
}

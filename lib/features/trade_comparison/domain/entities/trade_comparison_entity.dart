import 'package:equatable/equatable.dart';

class TradeComparisonEntity extends Equatable {
  final String uName;
  final String pUser;
  final String exch;
  final String symbol;
  final String orderDateTime;
  final String buySell;
  final double quantity;
  final double lot;
  final String type;
  final double pl;
  final double tPrice;
  final double brk;
  final double rPrice;
  final String executionDateTime;
  final String deviceId;
  final String ipAddress;
  final String city;

  const TradeComparisonEntity({
    required this.uName,
    required this.pUser,
    required this.exch,
    required this.symbol,
    required this.orderDateTime,
    required this.buySell,
    required this.quantity,
    required this.lot,
    required this.type,
    required this.pl,
    required this.tPrice,
    required this.brk,
    required this.rPrice,
    required this.executionDateTime,
    required this.deviceId,
    required this.ipAddress,
    required this.city,
  });

  @override
  List<Object> get props => [
    uName, pUser, exch, symbol, orderDateTime, buySell,
    quantity, lot, type, pl, tPrice, brk, rPrice,
    executionDateTime, deviceId, ipAddress, city,
  ];
}

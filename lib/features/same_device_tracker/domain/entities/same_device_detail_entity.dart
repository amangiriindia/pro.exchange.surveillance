import 'package:equatable/equatable.dart';

class SameDeviceDetailEntity extends Equatable {
  final String uName;
  final String pUser;
  final String exch;
  final String symbol;
  final String orderTime;
  final String buySell;
  final double quantity;
  final double lot;
  final String type;
  final double pl;
  final double tPrice;
  final double brk;
  final double rPrice;

  const SameDeviceDetailEntity({
    required this.uName,
    required this.pUser,
    required this.exch,
    required this.symbol,
    required this.orderTime,
    required this.buySell,
    required this.quantity,
    required this.lot,
    required this.type,
    required this.pl,
    required this.tPrice,
    required this.brk,
    required this.rPrice,
  });

  @override
  List<Object> get props => [
    uName, pUser, exch, symbol, orderTime, buySell,
    quantity, lot, type, pl, tPrice, brk, rPrice,
  ];
}

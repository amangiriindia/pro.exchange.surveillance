import 'package:equatable/equatable.dart';

class GroupTradeEntity extends Equatable {
  final String uName;
  final String pUser;
  final String exchange;
  final String symbol;
  final String orderDateTime;
  final String buySell;
  final double quantity;
  final double lot;
  final String type;
  final double profitLoss;
  final double tradePrice;
  final double? brk;
  final double? rPrice;
  final String? executionDateTime;
  final String? deviceId;
  final String? ipAddress;
  final String? city;

  const GroupTradeEntity({
    required this.uName,
    required this.pUser,
    required this.exchange,
    required this.symbol,
    required this.orderDateTime,
    required this.buySell,
    required this.quantity,
    required this.lot,
    required this.type,
    required this.profitLoss,
    required this.tradePrice,
    this.brk,
    this.rPrice,
    this.executionDateTime,
    this.deviceId,
    this.ipAddress,
    this.city,
  });

  @override
  List<Object?> get props => [
        uName, pUser, exchange, symbol, orderDateTime, buySell, quantity, lot,
        type, profitLoss, tradePrice, brk, rPrice, executionDateTime, deviceId,
        ipAddress, city,
      ];
}

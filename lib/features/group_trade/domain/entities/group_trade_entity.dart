import 'package:equatable/equatable.dart';

class GroupTradeEntity extends Equatable {
  final int id;
  final String? userName;
  final String? parentUserName;
  final String exchange;
  final String symbol;
  final String orderDateTime;
  final String buySell;
  final String tradeType;
  final String mainOrderType;
  final double quantity;
  final double lot;
  final String type;
  final double profitLoss;
  final double tradePrice;
  final double brokerage;
  final double referencePrice;
  final String? executionDateTime;
  final String? deviceId;
  final String? ipAddress;
  final String? city;

  const GroupTradeEntity({
    required this.id,
    this.userName,
    this.parentUserName,
    required this.exchange,
    required this.symbol,
    required this.orderDateTime,
    required this.buySell,
    required this.tradeType,
    required this.mainOrderType,
    required this.quantity,
    required this.lot,
    required this.type,
    required this.profitLoss,
    required this.tradePrice,
    required this.brokerage,
    required this.referencePrice,
    this.executionDateTime,
    this.deviceId,
    this.ipAddress,
    this.city,
  });

  @override
  List<Object?> get props => [
    id,
    userName,
    parentUserName,
    exchange,
    symbol,
    orderDateTime,
    buySell,
    tradeType,
    mainOrderType,
    quantity,
    lot,
    type,
    profitLoss,
    tradePrice,
    brokerage,
    referencePrice,
    executionDateTime,
    deviceId,
    ipAddress,
    city,
  ];
}

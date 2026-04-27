import 'package:equatable/equatable.dart';

class TradeEntity extends Equatable {
  final int id;
  final String uName; // userName
  final String pUser; // parentUserName
  final String exchange; // exchangeName
  final String symbol; // symbolName
  final String orderDateTime;
  final String buySell; // constructed: "SELL - L Market"
  final double quantity; // totalQuantity
  final double lot; // lotSize
  final String type; // mainOrderType (Market/Limit)
  final double profitLoss;
  final double tradePrice; // price
  final double? brk; // brokerageAmount
  final double? rPrice; // referencePrice
  final String? executionDateTime;
  final String? deviceId;
  final String? ipAddress;
  final String? city;
  final String? comment;
  final String? status;
  final String? productType;
  final int? userId;

  const TradeEntity({
    required this.id,
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
    this.comment,
    this.status,
    this.productType,
    this.userId,
  });

  @override
  List<Object?> get props => [
    id,
    uName,
    pUser,
    exchange,
    symbol,
    orderDateTime,
    buySell,
    quantity,
    lot,
    type,
    profitLoss,
    tradePrice,
    brk,
    rPrice,
    executionDateTime,
    deviceId,
    ipAddress,
    city,
    comment,
    status,
    productType,
    userId,
  ];
}

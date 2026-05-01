import 'package:equatable/equatable.dart';

class GroupTradeEntity extends Equatable {
  final int id;
  final String time;
  final String exchange;
  final String symbol;
  final String tradeType;
  final int clientCount;
  final double totalQty;
  final double qtyThreshold;
  final int timeFrameSeconds;
  final int tradeCount;
  final String userNameJoined;
  final String investigateStatus;
  final bool isRead;

  const GroupTradeEntity({
    required this.id,
    required this.time,
    required this.exchange,
    required this.symbol,
    required this.tradeType,
    required this.clientCount,
    required this.totalQty,
    required this.qtyThreshold,
    required this.timeFrameSeconds,
    required this.tradeCount,
    required this.userNameJoined,
    required this.investigateStatus,
    required this.isRead,
  });

  @override
  List<Object?> get props => [
    id,
    time,
    exchange,
    symbol,
    tradeType,
    clientCount,
    totalQty,
    qtyThreshold,
    timeFrameSeconds,
    tradeCount,
    userNameJoined,
    investigateStatus,
    isRead,
  ];
}

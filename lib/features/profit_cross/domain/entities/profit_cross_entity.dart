import 'package:equatable/equatable.dart';

class ProfitCrossEntity extends Equatable {
  final int id;
  final String time;
  final String exchange;
  final String symbol;
  final String orderDT;
  final double pnl;
  final double profitPercent;
  final String orderDuration;
  final double pnlPercentage;
  final String investigateStatus;
  final bool isRead;
  final List<int> clientIds;
  final List<int> tradeIds;
  final String userNameJoined;

  const ProfitCrossEntity({
    required this.id,
    required this.time,
    required this.exchange,
    required this.symbol,
    required this.orderDT,
    required this.pnl,
    required this.profitPercent,
    required this.orderDuration,
    required this.pnlPercentage,
    required this.investigateStatus,
    required this.isRead,
    required this.clientIds,
    required this.tradeIds,
    required this.userNameJoined,
  });

  @override
  List<Object> get props => [
    id,
    time,
    exchange,
    symbol,
    orderDT,
    pnl,
    orderDuration,
    pnlPercentage,
  ];
}

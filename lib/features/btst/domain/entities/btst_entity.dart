import 'package:equatable/equatable.dart';

class BTSTEntity extends Equatable {
  final int id;
  final String label;
  final String uName;
  final String pUser;
  final String exchange;
  final String symbol;
  final double pnl;
  final String inTime;
  final String outTime;
  final String orderDuration;
  final List<int> clientIds;
  final List<int> tradeIds;
  final String investigateStatus;
  final bool isRead;

  const BTSTEntity({
    required this.id,
    required this.label,
    required this.uName,
    required this.pUser,
    required this.exchange,
    required this.symbol,
    required this.pnl,
    required this.inTime,
    required this.outTime,
    required this.orderDuration,
    required this.clientIds,
    required this.tradeIds,
    required this.investigateStatus,
    required this.isRead,
  });

  @override
  List<Object> get props => [
    id,
    uName,
    pUser,
    exchange,
    symbol,
    pnl,
    inTime,
    outTime,
    orderDuration,
  ];
}

import 'package:equatable/equatable.dart';

class JobberTrackerEntity extends Equatable {
  final int id;
  final String time;
  final String uName;
  final String pUser;
  final String exchange;
  final String symbol;
  final int tradeFrequency;
  final double pnl;
  final List<int> clientIds;
  final List<int> tradeIds;
  final String investigateStatus;
  final bool isRead;

  const JobberTrackerEntity({
    required this.id,
    required this.time,
    required this.uName,
    required this.pUser,
    required this.exchange,
    required this.symbol,
    required this.tradeFrequency,
    required this.pnl,
    required this.clientIds,
    required this.tradeIds,
    required this.investigateStatus,
    required this.isRead,
  });

  @override
  List<Object> get props => [
    id,
    time,
    uName,
    pUser,
    exchange,
    symbol,
    tradeFrequency,
    pnl,
  ];
}

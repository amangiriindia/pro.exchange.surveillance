import 'package:equatable/equatable.dart';

class JobberTrackerEntity extends Equatable {
  final String time;
  final String uName;
  final String pUser;
  final String exchange;
  final String symbol;
  final int tradeFrequency;
  final double pnl;

  const JobberTrackerEntity({
    required this.time,
    required this.uName,
    required this.pUser,
    required this.exchange,
    required this.symbol,
    required this.tradeFrequency,
    required this.pnl,
  });

  @override
  List<Object> get props => [time, uName, pUser, exchange, symbol, tradeFrequency, pnl];
}

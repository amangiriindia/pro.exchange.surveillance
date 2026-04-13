import 'package:equatable/equatable.dart';

class ProfitCrossEntity extends Equatable {
  final String time;
  final String exchange;
  final String symbol;
  final String orderDT;
  final double pnl;
  final String orderDuration;
  final double pnlPercentage;

  const ProfitCrossEntity({
    required this.time,
    required this.exchange,
    required this.symbol,
    required this.orderDT,
    required this.pnl,
    required this.orderDuration,
    required this.pnlPercentage,
  });

  @override
  List<Object> get props => [time, exchange, symbol, orderDT, pnl, orderDuration, pnlPercentage];
}

import 'package:equatable/equatable.dart';

class BTSTEntity extends Equatable {
  final String uName;
  final String pUser;
  final String exchange;
  final String symbol;
  final double pnl;
  final String inTime;
  final String outTime;
  final String orderDuration;

  const BTSTEntity({
    required this.uName,
    required this.pUser,
    required this.exchange,
    required this.symbol,
    required this.pnl,
    required this.inTime,
    required this.outTime,
    required this.orderDuration,
  });

  @override
  List<Object> get props => [uName, pUser, exchange, symbol, pnl, inTime, outTime, orderDuration];
}

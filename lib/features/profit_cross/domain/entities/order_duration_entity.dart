import 'package:equatable/equatable.dart';

class OrderDurationEntity extends Equatable {
  final String duration;
  final String symbol;
  final String type;
  final double qty;
  final double price;
  final String executionDT;
  final double pnl;

  const OrderDurationEntity({
    required this.duration,
    required this.symbol,
    required this.type,
    required this.qty,
    required this.price,
    required this.executionDT,
    required this.pnl,
  });

  @override
  List<Object> get props => [duration, symbol, type, qty, price, executionDT, pnl];
}

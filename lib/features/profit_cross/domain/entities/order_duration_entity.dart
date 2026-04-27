import 'package:equatable/equatable.dart';

class OrderDurationEntity extends Equatable {
  final int id;
  final String duration;
  final String symbol;
  final String exchange;
  final String symbolName;
  final String type;
  final String tradeType;
  final double qty;
  final double price;
  final String executionDT;
  final double pnl;

  const OrderDurationEntity({
    required this.id,
    required this.duration,
    required this.symbol,
    required this.exchange,
    required this.symbolName,
    required this.type,
    required this.tradeType,
    required this.qty,
    required this.price,
    required this.executionDT,
    required this.pnl,
  });

  @override
  List<Object> get props => [
    id,
    duration,
    symbol,
    type,
    qty,
    price,
    executionDT,
    pnl,
  ];
}

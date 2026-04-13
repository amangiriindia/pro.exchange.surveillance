import 'package:equatable/equatable.dart';

class BulkOrderEntity extends Equatable {
  final String time;
  final String exchange;
  final String symbol;
  final double quantity;

  const BulkOrderEntity({
    required this.time,
    required this.exchange,
    required this.symbol,
    required this.quantity,
  });

  @override
  List<Object> get props => [time, exchange, symbol, quantity];
}

import 'package:equatable/equatable.dart';

class BulkOrderEntity extends Equatable {
  final int id;
  final String time;
  final String exchange;
  final String symbol;
  final String tradeType;
  final double quantity;
  final int threshold;
  final bool exceedsThreshold;
  final String investigateStatus;
  final bool isRead;
  final List<int> clientIds;
  final List<int> tradeIds;

  const BulkOrderEntity({
    required this.id,
    required this.time,
    required this.exchange,
    required this.symbol,
    required this.tradeType,
    required this.quantity,
    required this.threshold,
    required this.exceedsThreshold,
    required this.investigateStatus,
    required this.isRead,
    required this.clientIds,
    required this.tradeIds,
  });

  @override
  List<Object> get props => [
    id,
    time,
    exchange,
    symbol,
    tradeType,
    quantity,
    threshold,
    exceedsThreshold,
    investigateStatus,
    isRead,
  ];
}

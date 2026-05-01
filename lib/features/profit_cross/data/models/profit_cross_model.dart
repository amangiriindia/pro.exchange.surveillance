import '../../domain/entities/profit_cross_entity.dart';

class ProfitCrossModel extends ProfitCrossEntity {
  const ProfitCrossModel({
    required super.id,
    required super.time,
    required super.exchange,
    required super.symbol,
    required super.orderDT,
    required super.pnl,
    required super.profitPercent,
    required super.orderDuration,
    required super.pnlPercentage,
    required super.investigateStatus,
    required super.isRead,
    required super.clientIds,
    required super.tradeIds,
    required super.userNameJoined,
  });

  factory ProfitCrossModel.fromJson(Map<String, dynamic> json) {
    return ProfitCrossModel(
      id: (json['id'] ?? 0) as int,
      time: json['time'] ?? '',
      exchange: json['exchange'] ?? '',
      symbol: json['symbol'] ?? '',
      orderDT: json['orderDateTime'] ?? '',
      pnl: (json['profitLoss'] as num? ?? 0).toDouble(),
      profitPercent: (json['profitPercent'] as num? ?? 0).toDouble(),
      orderDuration: json['orderDuration'] ?? '',
      pnlPercentage: (json['profitPercent'] as num? ?? 0).toDouble(),
      investigateStatus: json['investigateStatus'] ?? '',
      isRead: json['isRead'] ?? false,
      clientIds: (json['clientIds'] as List<dynamic>? ?? []).cast<int>(),
      tradeIds: (json['tradeIds'] as List<dynamic>? ?? []).cast<int>(),
      userNameJoined: json['userNameJoined'] as String? ?? '',
    );
  }
}

import '../../domain/entities/btst_entity.dart';

class BTSTModel extends BTSTEntity {
  const BTSTModel({
    required super.id,
    required super.label,
    required super.uName,
    required super.pUser,
    required super.exchange,
    required super.symbol,
    required super.pnl,
    required super.inTime,
    required super.outTime,
    required super.orderDuration,
    required super.clientIds,
    required super.tradeIds,
    required super.investigateStatus,
    required super.isRead,
  });

  factory BTSTModel.fromJson(Map<String, dynamic> json) {
    return BTSTModel(
      id: (json['id'] ?? 0) as int,
      label: json['label'] ?? '',
      uName: json['userName'] ?? '',
      pUser: json['parentUserName'] ?? '',
      exchange: json['exchange'] ?? '',
      symbol: json['symbol'] ?? '',
      pnl: (json['profitLoss'] as num? ?? 0).toDouble(),
      inTime: json['inTime'] ?? '',
      outTime: json['outTime'] ?? '',
      orderDuration: json['orderDuration'] ?? '',
      clientIds: (json['clientIds'] as List<dynamic>? ?? []).cast<int>(),
      tradeIds: (json['tradeIds'] as List<dynamic>? ?? []).cast<int>(),
      investigateStatus: json['investigateStatus'] ?? '',
      isRead: json['isRead'] ?? false,
    );
  }
}

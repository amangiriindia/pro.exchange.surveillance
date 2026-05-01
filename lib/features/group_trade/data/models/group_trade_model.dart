import '../../domain/entities/group_trade_entity.dart';

class GroupTradeModel extends GroupTradeEntity {
  const GroupTradeModel({
    required super.id,
    required super.time,
    required super.exchange,
    required super.symbol,
    required super.tradeType,
    required super.clientCount,
    required super.totalQty,
    required super.qtyThreshold,
    required super.timeFrameSeconds,
    required super.tradeCount,
    required super.userNameJoined,
    required super.investigateStatus,
    required super.isRead,
  });

  factory GroupTradeModel.fromJson(Map<String, dynamic> json) {
    return GroupTradeModel(
      id: json['id'] as int? ?? 0,
      time: json['time'] as String? ?? '',
      exchange: json['exchange'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      tradeType: json['tradeType'] as String? ?? '',
      clientCount: json['clientCount'] as int? ?? 0,
      totalQty: double.tryParse(json['totalQty']?.toString() ?? '0') ?? 0.0,
      qtyThreshold:
          double.tryParse(json['qtyThreshold']?.toString() ?? '0') ?? 0.0,
      timeFrameSeconds: json['timeFrameSeconds'] as int? ?? 0,
      tradeCount: json['tradeCount'] as int? ?? 0,
      userNameJoined: json['userNameJoined'] as String? ?? '',
      investigateStatus: json['investigateStatus'] as String? ?? 'NEW',
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}

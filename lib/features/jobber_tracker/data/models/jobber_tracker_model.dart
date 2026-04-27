import '../../domain/entities/jobber_tracker_entity.dart';

class JobberTrackerModel extends JobberTrackerEntity {
  const JobberTrackerModel({
    required super.id,
    required super.time,
    required super.uName,
    required super.pUser,
    required super.exchange,
    required super.symbol,
    required super.tradeFrequency,
    required super.pnl,
    required super.clientIds,
    required super.tradeIds,
    required super.investigateStatus,
    required super.isRead,
  });

  factory JobberTrackerModel.fromJson(Map<String, dynamic> json) {
    return JobberTrackerModel(
      id: (json['id'] ?? 0) as int,
      time: json['time'] ?? '',
      uName: json['userName'] ?? '',
      pUser: json['parentUserName'] ?? '',
      exchange: json['exchange'] ?? '',
      symbol: json['symbol'] ?? '',
      tradeFrequency: (json['tradeFrequency'] ?? 0) as int,
      pnl: (json['profitLoss'] as num? ?? 0).toDouble(),
      clientIds: (json['clientIds'] as List<dynamic>? ?? []).cast<int>(),
      tradeIds: (json['tradeIds'] as List<dynamic>? ?? []).cast<int>(),
      investigateStatus: json['investigateStatus'] ?? '',
      isRead: json['isRead'] ?? false,
    );
  }
}

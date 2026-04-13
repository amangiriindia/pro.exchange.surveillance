import '../../domain/entities/jobber_tracker_entity.dart';

class JobberTrackerModel extends JobberTrackerEntity {
  const JobberTrackerModel({
    required super.time,
    required super.uName,
    required super.pUser,
    required super.exchange,
    required super.symbol,
    required super.tradeFrequency,
    required super.pnl,
  });

  factory JobberTrackerModel.fromJson(Map<String, dynamic> json) {
    return JobberTrackerModel(
      time: json['time'],
      uName: json['u_name'],
      pUser: json['p_user'],
      exchange: json['exchange'],
      symbol: json['symbol'],
      tradeFrequency: json['trade_frequency'],
      pnl: (json['pnl'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'u_name': uName,
      'p_user': pUser,
      'exchange': exchange,
      'symbol': symbol,
      'trade_frequency': tradeFrequency,
      'pnl': pnl,
    };
  }
}

import '../../domain/entities/trade_comparison_entity.dart';

class TradeComparisonModel extends TradeComparisonEntity {
  const TradeComparisonModel({
    required super.uName,
    required super.pUser,
    required super.exch,
    required super.symbol,
    required super.orderDateTime,
    required super.buySell,
    required super.quantity,
    required super.lot,
    required super.type,
    required super.pl,
    required super.tPrice,
    required super.brk,
    required super.rPrice,
    required super.executionDateTime,
    required super.deviceId,
    required super.ipAddress,
    required super.city,
  });

  static String _formatIso(dynamic raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw as String).toLocal();
      final dd = dt.day.toString().padLeft(2, '0');
      final mm = dt.month.toString().padLeft(2, '0');
      final yy = (dt.year % 100).toString().padLeft(2, '0');
      final hh = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      final ss = dt.second.toString().padLeft(2, '0');
      return '$dd/$mm/$yy $hh:$min:$ss';
    } catch (_) {
      return raw.toString();
    }
  }

  factory TradeComparisonModel.fromJson(Map<String, dynamic> json) {
    return TradeComparisonModel(
      uName: json['userName']?.toString() ?? '',
      pUser: json['parentUserName']?.toString() ?? '',
      exch: json['exchange']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
      orderDateTime: _formatIso(json['orderDateTime']),
      buySell: json['buySell']?.toString() ?? '',
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      lot: double.tryParse(json['lot']?.toString() ?? '0') ?? 0,
      type: json['type']?.toString() ?? '',
      pl: double.tryParse(json['profitLoss']?.toString() ?? '0') ?? 0,
      tPrice: double.tryParse(json['tradePrice']?.toString() ?? '0') ?? 0,
      brk: double.tryParse(json['brokerage']?.toString() ?? '0') ?? 0,
      rPrice: double.tryParse(json['referencePrice']?.toString() ?? '0') ?? 0,
      executionDateTime: _formatIso(json['executionDateTime']),
      deviceId: json['deviceId']?.toString() ?? '',
      ipAddress: json['ipAddress']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
    );
  }
}

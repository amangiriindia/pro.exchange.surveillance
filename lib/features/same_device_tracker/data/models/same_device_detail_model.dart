import '../../domain/entities/same_device_detail_entity.dart';

class SameDeviceModelDetail extends SameDeviceDetailEntity {
  const SameDeviceModelDetail({
    required super.id,
    required super.uName,
    required super.pUser,
    required super.exch,
    required super.symbol,
    required super.orderTime,
    required super.buySell,
    required super.tradeType,
    required super.mainOrderType,
    required super.quantity,
    required super.lot,
    required super.type,
    required super.pl,
    required super.tPrice,
    required super.brk,
    required super.rPrice,
    required super.executionTime,
    required super.deviceId,
    required super.ipAddress,
    required super.city,
    super.orderType,
    super.comment,
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

  factory SameDeviceModelDetail.fromJson(Map<String, dynamic> json) {
    return SameDeviceModelDetail(
      id: json['id'] as int,
      uName: json['userName']?.toString() ?? '',
      pUser: json['parentUserName']?.toString() ?? '',
      exch: json['exchange']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? '',
      orderTime: _formatIso(json['orderDateTime']),
      buySell: json['buySell']?.toString() ?? '',
      tradeType: json['tradeType']?.toString() ?? '',
      mainOrderType: json['mainOrderType']?.toString() ?? '',
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      lot: double.tryParse(json['lot']?.toString() ?? '0') ?? 0,
      type: json['type']?.toString() ?? '',
      pl: double.tryParse(json['profitLoss']?.toString() ?? '0') ?? 0,
      tPrice: double.tryParse(json['tradePrice']?.toString() ?? '0') ?? 0,
      brk: double.tryParse(json['brokerage']?.toString() ?? '0') ?? 0,
      rPrice: double.tryParse(json['referencePrice']?.toString() ?? '0') ?? 0,
      executionTime: _formatIso(json['executionDateTime']),
      deviceId: json['deviceId']?.toString() ?? '',
      ipAddress: json['ipAddress']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      orderType: json['orderType'] as String?,
      comment: json['comment'] as String?,
    );
  }
}

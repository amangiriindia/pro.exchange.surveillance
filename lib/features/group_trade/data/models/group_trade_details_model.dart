import '../../domain/entities/group_trade_details_entity.dart';

class GroupTradeDetailsModel extends GroupTradeDetailsEntity {
  const GroupTradeDetailsModel({
    required super.id,
    super.userName,
    super.parentUserName,
    required super.exchange,
    required super.symbol,
    required super.orderDateTime,
    required super.buySell,
    required super.tradeType,
    required super.mainOrderType,
    super.orderType,
    super.comment,
    required super.quantity,
    required super.lot,
    required super.type,
    required super.profitLoss,
    required super.tradePrice,
    required super.brokerage,
    required super.referencePrice,
    super.executionDateTime,
    super.deviceId,
    super.ipAddress,
    super.city,
  });

  factory GroupTradeDetailsModel.fromJson(Map<String, dynamic> json) {
    final rawBuySell = json['buySell'] as String? ?? '';
    return GroupTradeDetailsModel(
      id: json['id'] as int,
      userName: json['userName'] as String?,
      parentUserName: json['parentUserName'] as String?,
      exchange: json['exchange'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      orderDateTime: _formatDateTime(json['orderDateTime'] as String? ?? ''),
      buySell: _formatBuySell(rawBuySell),
      tradeType: json['tradeType'] as String? ?? '',
      mainOrderType: json['mainOrderType'] as String? ?? '',
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0.0,
      lot: double.tryParse(json['lot']?.toString() ?? '0') ?? 0.0,
      type: _formatType(json['type'] as String? ?? ''),
      profitLoss: double.tryParse(json['profitLoss']?.toString() ?? '0') ?? 0.0,
      tradePrice: double.tryParse(json['tradePrice']?.toString() ?? '0') ?? 0.0,
      brokerage: double.tryParse(json['brokerage']?.toString() ?? '0') ?? 0.0,
      referencePrice:
          double.tryParse(json['referencePrice']?.toString() ?? '0') ?? 0.0,
      executionDateTime: json['executionDateTime'] != null
          ? _formatDateTime(json['executionDateTime'] as String)
          : null,
      deviceId: json['deviceId'] as String?,
      ipAddress: json['ipAddress'] as String?,
      city: json['city'] as String?,
      orderType: json['orderType'] as String?,
      comment: json['comment'] as String?,
    );
  }

  static String _formatBuySell(String raw) {
    if (raw.isEmpty) return raw;
    final parts = raw.split(' - ');
    if (parts.length < 2) return raw.toUpperCase();
    final side = parts[0].toUpperCase();
    final order = parts.sublist(1).join(' - ');
    final orderFormatted = order.isNotEmpty
        ? order[0].toUpperCase() + order.substring(1).toLowerCase()
        : order;
    return '$side - $orderFormatted';
  }

  static String _formatType(String raw) {
    switch (raw.toLowerCase()) {
      case 'longterm':
        return 'Long Term';
      case 'intraday':
        return 'Intraday';
      case 'btst':
        return 'BTST';
      default:
        if (raw.isEmpty) return raw;
        return raw[0].toUpperCase() + raw.substring(1);
    }
  }

  static String _formatDateTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final amPm = dt.hour < 12 ? 'AM' : 'PM';
      final dd = dt.day.toString().padLeft(2, '0');
      final mm = dt.month.toString().padLeft(2, '0');
      final yy = dt.year.toString().substring(2);
      final hh = hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      final sec = dt.second.toString().padLeft(2, '0');
      return '$dd/$mm/$yy $hh:$min:$sec $amPm';
    } catch (_) {
      return iso;
    }
  }
}

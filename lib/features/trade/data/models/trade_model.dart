import '../../domain/entities/trade_entity.dart';

class TradeModel extends TradeEntity {
  const TradeModel({
    required super.id,
    required super.uName,
    required super.pUser,
    required super.exchange,
    required super.symbol,
    required super.orderDateTime,
    required super.buySell,
    required super.quantity,
    required super.lot,
    required super.type,
    required super.profitLoss,
    required super.tradePrice,
    super.brk,
    super.rPrice,
    super.executionDateTime,
    super.deviceId,
    super.ipAddress,
    super.city,
    super.comment,
    super.status,
    super.productType,
    super.userId,
  });

  factory TradeModel.fromJson(Map<String, dynamic> json) {
    final tradeType = (json['tradeType'] as String? ?? 'buy').toLowerCase();
    final productType = (json['productType'] as String? ?? '');
    final mainOrderType = (json['mainOrderType'] as String? ?? 'market');

    // Build B/S display string: e.g. "SELL - L Market", "BUY - SL Add Trade"
    final productPrefix = _productPrefix(productType);
    final orderDisplay = _capitalize(mainOrderType);
    final buySell = '${tradeType.toUpperCase()} - $productPrefix $orderDisplay'
        .trim();

    // Format orderDateTime from ISO string
    final createdAt = json['createdAt'] as String? ?? '';
    final orderDateTime = _formatDateTime(createdAt);

    final executionRaw = json['executionDateTime'] as String?;
    final executionDateTime = executionRaw != null
        ? _formatDateTime(executionRaw)
        : null;

    return TradeModel(
      id: json['id'] as int? ?? 0,
      uName: json['userName'] as String? ?? 'User ${json['userId'] ?? ''}',
      pUser:
          json['parentUserName'] as String? ?? '${json['parentUserId'] ?? '-'}',
      exchange:
          json['exchangeName'] as String? ?? '${json['exchangeId'] ?? ''}',
      symbol: json['symbolName'] as String? ?? '',
      orderDateTime: orderDateTime,
      buySell: buySell,
      quantity: double.tryParse(json['totalQuantity']?.toString() ?? '0') ?? 0,
      lot: double.tryParse(json['lotSize']?.toString() ?? '0') ?? 0,
      type: _capitalize(mainOrderType),
      profitLoss: double.tryParse(json['profitLoss']?.toString() ?? '0') ?? 0,
      tradePrice: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      brk: double.tryParse(json['brokerageAmount']?.toString() ?? '0') ?? 0,
      rPrice: double.tryParse(json['referencePrice']?.toString() ?? '0') ?? 0,
      executionDateTime: executionDateTime,
      deviceId: json['deviceId'] as String?,
      ipAddress: json['ipAddress'] as String?,
      city: json['city'] as String?,
      comment: json['comment'] as String?,
      status: json['status'] as String?,
      productType: productType,
      userId: json['userId'] as int?,
    );
  }

  /// Maps productType to short prefix for B/S column.
  static String _productPrefix(String productType) {
    // toLowerCase() normalises both 'longTerm' and 'longterm'
    switch (productType.toLowerCase()) {
      case 'longterm':
        return 'L';
      case 'intraday':
        return 'I';
      case 'delivery':
        return 'D';
      default:
        return productType.isEmpty
            ? ''
            : productType.substring(0, 1).toUpperCase();
    }
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  /// Formats ISO 8601 datetime to "dd/MM/yy hh:mm:ss AM/PM"
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

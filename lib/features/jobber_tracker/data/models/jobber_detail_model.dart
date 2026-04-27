import '../../domain/entities/jobber_detail_entity.dart';

class JobberDetailModel extends JobberDetailEntity {
  const JobberDetailModel({
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
  });

  factory JobberDetailModel.fromJson(Map<String, dynamic> json) {
    return JobberDetailModel(
      id: (json['id'] ?? 0) as int,
      uName: json['userName'] ?? '',
      pUser: json['parentUserName'] ?? '',
      exch: json['exchange'] ?? '',
      symbol: json['symbol'] ?? '',
      orderTime: json['orderDateTime'] ?? '',
      buySell: json['buySell'] ?? '',
      tradeType: json['tradeType'] ?? '',
      mainOrderType: json['mainOrderType'] ?? '',
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      lot: double.tryParse(json['lot']?.toString() ?? '0') ?? 0,
      type: json['type'] ?? '',
      pl: double.tryParse(json['profitLoss']?.toString() ?? '0') ?? 0,
      tPrice: double.tryParse(json['tradePrice']?.toString() ?? '0') ?? 0,
      brk: double.tryParse(json['brokerage']?.toString() ?? '0') ?? 0,
      rPrice: double.tryParse(json['referencePrice']?.toString() ?? '0') ?? 0,
      executionTime: json['executionDateTime'] ?? '',
    );
  }
}

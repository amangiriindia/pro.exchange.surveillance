import '../../domain/entities/alert_entity.dart';

class AlertModel extends AlertEntity {
  const AlertModel({
    required super.alertType,
    super.script,
    super.exchange,
    required super.clientIds,
    required super.tradeIds,
    required super.message,
    required super.investigateStatus,
    required super.isRead,
    required super.createdAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      alertType: AlertType.fromString(json['alertType'] as String? ?? ''),
      script: json['script'] as String?,
      exchange: json['exchange'] as String?,
      clientIds: _parseIntList(json['clientIds']),
      tradeIds: _parseIntList(json['tradeIds']),
      message: json['message'] as String? ?? '',
      investigateStatus: json['investigateStatus'] as String? ?? 'NEW',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static List<int> _parseIntList(dynamic value) {
    if (value is List) {
      return value.map((e) => (e as num).toInt()).toList();
    }
    return [];
  }
}

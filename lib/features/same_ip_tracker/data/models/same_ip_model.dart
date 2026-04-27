import '../../domain/entities/same_ip_entity.dart';

class SameIPModel extends SameIPEntity {
  const SameIPModel({
    required super.id,
    required super.time,
    required super.uName,
    required super.ipAddress,
    required super.clientIds,
    required super.tradeIds,
    required super.investigateStatus,
    required super.isRead,
  });

  factory SameIPModel.fromJson(Map<String, dynamic> json) {
    return SameIPModel(
      id: (json['id'] ?? 0) as int,
      time: json['time'] ?? '',
      uName: json['userNameJoined'] ?? '',
      ipAddress: json['ipAddress'] ?? '',
      clientIds: (json['clientIds'] as List<dynamic>? ?? []).cast<int>(),
      tradeIds: (json['tradeIds'] as List<dynamic>? ?? []).cast<int>(),
      investigateStatus: json['investigateStatus'] ?? '',
      isRead: json['isRead'] ?? false,
    );
  }
}

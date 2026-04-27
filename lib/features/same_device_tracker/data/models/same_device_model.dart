import '../../domain/entities/same_device_entity.dart';

class SameDeviceModel extends SameDeviceEntity {
  const SameDeviceModel({
    required super.id,
    required super.time,
    required super.uName,
    required super.deviceId,
    required super.clientIds,
    required super.tradeIds,
    required super.investigateStatus,
    required super.isRead,
  });

  factory SameDeviceModel.fromJson(Map<String, dynamic> json) {
    String formattedTime = '';
    try {
      final dt = DateTime.parse(json['time'] as String).toLocal();
      final dd = dt.day.toString().padLeft(2, '0');
      final mm = dt.month.toString().padLeft(2, '0');
      final yyyy = dt.year.toString();
      final hh = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      final ss = dt.second.toString().padLeft(2, '0');
      formattedTime = '$dd/$mm/$yyyy | $hh:$min:$ss';
    } catch (_) {
      formattedTime = json['time']?.toString() ?? '';
    }
    return SameDeviceModel(
      id: json['id'] as int,
      time: formattedTime,
      uName: json['userNameJoined']?.toString() ?? '',
      deviceId: json['deviceId']?.toString() ?? '',
      clientIds: (json['clientIds'] as List<dynamic>? ?? [])
          .map((e) => e as int)
          .toList(),
      tradeIds: (json['tradeIds'] as List<dynamic>? ?? [])
          .map((e) => e as int)
          .toList(),
      investigateStatus: json['investigateStatus']?.toString() ?? '',
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}

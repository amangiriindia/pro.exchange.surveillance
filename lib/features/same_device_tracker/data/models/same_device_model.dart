import '../../domain/entities/same_device_entity.dart';

class SameDeviceModel extends SameDeviceEntity {
  const SameDeviceModel({
    required super.time,
    required super.uName,
    required super.deviceId,
  });

  factory SameDeviceModel.fromJson(Map<String, dynamic> json) {
    return SameDeviceModel(
      time: json['time'],
      uName: json['u_name'],
      deviceId: json['device_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'u_name': uName,
      'device_id': deviceId,
    };
  }
}

import 'package:equatable/equatable.dart';

class SameDeviceEntity extends Equatable {
  final String time;
  final String uName;
  final String deviceId;

  const SameDeviceEntity({
    required this.time,
    required this.uName,
    required this.deviceId,
  });

  @override
  List<Object> get props => [time, uName, deviceId];
}

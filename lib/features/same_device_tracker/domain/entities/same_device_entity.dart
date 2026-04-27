import 'package:equatable/equatable.dart';

class SameDeviceEntity extends Equatable {
  final int id;
  final String time;
  final String uName;
  final String deviceId;
  final List<int> clientIds;
  final List<int> tradeIds;
  final String investigateStatus;
  final bool isRead;

  const SameDeviceEntity({
    required this.id,
    required this.time,
    required this.uName,
    required this.deviceId,
    required this.clientIds,
    required this.tradeIds,
    required this.investigateStatus,
    required this.isRead,
  });

  @override
  List<Object> get props => [
    id,
    time,
    uName,
    deviceId,
    clientIds,
    tradeIds,
    investigateStatus,
    isRead,
  ];
}

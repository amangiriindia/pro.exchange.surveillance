import 'package:equatable/equatable.dart';

class SameIPEntity extends Equatable {
  final int id;
  final String time;
  final String uName;
  final String ipAddress;
  final List<int> clientIds;
  final List<int> tradeIds;
  final String investigateStatus;
  final bool isRead;

  const SameIPEntity({
    required this.id,
    required this.time,
    required this.uName,
    required this.ipAddress,
    required this.clientIds,
    required this.tradeIds,
    required this.investigateStatus,
    required this.isRead,
  });

  @override
  List<Object> get props => [id, time, uName, ipAddress];
}

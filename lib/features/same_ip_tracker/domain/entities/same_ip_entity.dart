import 'package:equatable/equatable.dart';

class SameIPEntity extends Equatable {
  final String time;
  final String uName; // This likely contains multiple names concatenated
  final String ipAddress;

  const SameIPEntity({
    required this.time,
    required this.uName,
    required this.ipAddress,
  });

  @override
  List<Object> get props => [time, uName, ipAddress];
}

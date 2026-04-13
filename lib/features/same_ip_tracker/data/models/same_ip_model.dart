import '../../domain/entities/same_ip_entity.dart';

class SameIPModel extends SameIPEntity {
  const SameIPModel({
    required super.time,
    required super.uName,
    required super.ipAddress,
  });

  factory SameIPModel.fromJson(Map<String, dynamic> json) {
    return SameIPModel(
      time: json['time'],
      uName: json['u_name'],
      ipAddress: json['ip_address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'u_name': uName,
      'ip_address': ipAddress,
    };
  }
}

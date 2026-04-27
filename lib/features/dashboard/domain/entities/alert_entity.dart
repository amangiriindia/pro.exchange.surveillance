import 'package:equatable/equatable.dart';

enum AlertType {
  btstStbt,
  tradeComparison,
  sameDevice,
  sameIp,
  jobberTracker,
  profitCross,
  bulkOrder,
  groupTrade,
  unknown;

  static AlertType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'BTST_STBT':
        return AlertType.btstStbt;
      case 'TRADE_COMPARISON':
        return AlertType.tradeComparison;
      case 'SAME_DEVICE':
        return AlertType.sameDevice;
      case 'SAME_IP':
        return AlertType.sameIp;
      case 'JOBBER_TRACKER':
        return AlertType.jobberTracker;
      case 'PROFIT_CROSS':
        return AlertType.profitCross;
      case 'BULK_ORDER':
        return AlertType.bulkOrder;
      case 'GROUP_TRADE':
        return AlertType.groupTrade;
      default:
        return AlertType.unknown;
    }
  }

  String get displayLabel {
    switch (this) {
      case AlertType.btstStbt:
        return 'BTST/STBT';
      case AlertType.tradeComparison:
        return 'Trade Comparison';
      case AlertType.sameDevice:
        return 'Same Device';
      case AlertType.sameIp:
        return 'Same IP';
      case AlertType.jobberTracker:
        return 'Jobber Tracker';
      case AlertType.profitCross:
        return 'Profit Cross';
      case AlertType.bulkOrder:
        return 'Bulk Order';
      case AlertType.groupTrade:
        return 'Group Trade';
      case AlertType.unknown:
        return 'Alert';
    }
  }

  /// Returns the API string used by the notification page tab config.
  String toApiString() {
    switch (this) {
      case AlertType.btstStbt:
        return 'BTST_STBT';
      case AlertType.tradeComparison:
        return 'TRADE_COMPARISON';
      case AlertType.sameDevice:
        return 'SAME_DEVICE';
      case AlertType.sameIp:
        return 'SAME_IP';
      case AlertType.jobberTracker:
        return 'JOBBER_TRACKER';
      case AlertType.profitCross:
        return 'PROFIT_CROSS';
      case AlertType.bulkOrder:
        return 'BULK_ORDER';
      case AlertType.groupTrade:
        return 'GROUP_TRADE';
      case AlertType.unknown:
        return '';
    }
  }
}

class AlertEntity extends Equatable {
  final AlertType alertType;
  final String? script;
  final String? exchange;
  final List<int> clientIds;
  final List<int> tradeIds;
  final String message;
  final String investigateStatus;
  final bool isRead;
  final DateTime createdAt;

  const AlertEntity({
    required this.alertType,
    this.script,
    this.exchange,
    required this.clientIds,
    required this.tradeIds,
    required this.message,
    required this.investigateStatus,
    required this.isRead,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    alertType,
    script,
    exchange,
    clientIds,
    tradeIds,
    message,
    investigateStatus,
    isRead,
    createdAt,
  ];
}

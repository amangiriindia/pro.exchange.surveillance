import 'package:flutter/material.dart';
import '../../domain/entities/alert_entity.dart';

Color alertTypeColor(AlertType type) {
  switch (type) {
    case AlertType.btstStbt:
      return const Color(0xFFE65100);
    case AlertType.tradeComparison:
      return const Color(0xFF1565C0);
    case AlertType.sameDevice:
      return const Color(0xFF6A1B9A);
    case AlertType.sameIp:
      return const Color(0xFF00695C);
    case AlertType.jobberTracker:
      return const Color(0xFFBF360C);
    case AlertType.profitCross:
      return const Color(0xFF2E7D32);
    case AlertType.bulkOrder:
      return const Color(0xFFC62828);
    case AlertType.groupTrade:
      return const Color(0xFF283593);
    case AlertType.unknown:
      return const Color(0xFF37474F);
  }
}

Color alertTypeLightColor(AlertType type) {
  return alertTypeColor(type).withOpacity(0.15);
}

IconData alertTypeIcon(AlertType type) {
  switch (type) {
    case AlertType.btstStbt:
      return Icons.swap_horiz_rounded;
    case AlertType.tradeComparison:
      return Icons.compare_arrows_rounded;
    case AlertType.sameDevice:
      return Icons.devices_rounded;
    case AlertType.sameIp:
      return Icons.lan_rounded;
    case AlertType.jobberTracker:
      return Icons.speed_rounded;
    case AlertType.profitCross:
      return Icons.trending_up_rounded;
    case AlertType.bulkOrder:
      return Icons.shopping_cart_rounded;
    case AlertType.groupTrade:
      return Icons.group_rounded;
    case AlertType.unknown:
      return Icons.notifications_rounded;
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget/table/view_data_table.dart';
import '../../../../core/widget/table_action_button.dart';
import '../../domain/entities/group_trade_entity.dart';

class GroupTradeTable extends StatelessWidget {
  final List<GroupTradeEntity> trades;
  final ValueChanged<GroupTradeEntity> onViewSelected;
  final VoidCallback? onNearBottom;
  final bool isLoadingMore;

  static const double _triggerThresholdPx = 1600;

  const GroupTradeTable({
    super.key,
    required this.trades,
    required this.onViewSelected,
    this.onNearBottom,
    this.isLoadingMore = false,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (onNearBottom != null &&
            notification.metrics.axis == Axis.vertical) {
          final remaining =
              notification.metrics.maxScrollExtent -
              notification.metrics.pixels;
          if (remaining < _triggerThresholdPx) {
            onNearBottom!();
          }
        }
        return false;
      },
      child: ViewDataTable<GroupTradeEntity>(
        columns: _buildColumns(),
        data: trades,
        idExtractor: (item) => item.id.toString(),
        autoFit: true,
        isDarkMode: AppColors.isDarkMode(context),
        rowBackgroundBuilder: (item, index) => index % 2 == 0
            ? AppColors.getTableRowBackground(context)
            : AppColors.getTableAlternateRowBackground(context),
        cellBuilder: (item, col) => _buildCell(context, item, col),
        footerBuilder: isLoadingMore ? (_) => const _LoadMoreFooter() : null,
      ),
    );
  }

  List<ViewTableColumn> _buildColumns() {
    return const [
      ViewTableColumn(id: 'time', label: 'Time', width: 200),
      ViewTableColumn(id: 'exchange', label: 'Exchange', width: 110),
      ViewTableColumn(id: 'symbol', label: 'Symbol', width: 220),
      ViewTableColumn(id: 'tradeType', label: 'B/S', width: 80),
      ViewTableColumn(
        id: 'clientCount',
        label: 'Client Count',
        width: 100,
        isNumeric: true,
      ),
      ViewTableColumn(
        id: 'totalQty',
        label: 'Total Qty',
        width: 110,
        isNumeric: true,
      ),
      ViewTableColumn(id: 'users', label: 'Users', width: 200),
      ViewTableColumn(id: 'action', label: 'Action', width: 120),
    ];
  }

  Widget _buildCell(
    BuildContext context,
    GroupTradeEntity trade,
    ViewTableColumn col,
  ) {
    Color textColor = const Color(0xFF616161);
    const FontWeight fontWeight = FontWeight.w600;

    if (col.id == 'action') {
      return TableActionButton.view(onPressed: () => onViewSelected(trade));
    }

    if (col.id == 'status') {
      if (trade.investigateStatus.toUpperCase() == 'NEW') {
        return const SizedBox.shrink();
      }
      return _buildStatusBadge(trade.investigateStatus);
    }

    String text = '';
    switch (col.id) {
      case 'time':
        try {
          final dt = DateTime.parse(trade.time).toLocal();
          text = DateFormat('dd/MM/yy hh:mm:ss a').format(dt);
        } catch (_) {
          text = trade.time;
        }
        break;
      case 'exchange':
        text = trade.exchange;
        break;
      case 'symbol':
        text = trade.symbol.trim().isEmpty ? '-' : trade.symbol;
        break;
      case 'tradeType':
        text = trade.tradeType.toUpperCase();
        textColor = trade.tradeType.toLowerCase() == 'buy'
            ? AppColors.primaryBlue
            : AppColors.errorColor;
        break;
      case 'clientCount':
        text = trade.clientCount.toString();
        break;
      case 'totalQty':
        text = NumberFormat('#,##0').format(trade.totalQty);
        break;
      case 'users':
        text = trade.userNameJoined.isEmpty ? '-' : trade.userNameJoined;
        break;
    }

    return Text(
      text,
      style: GoogleFonts.openSans(
        color: textColor,
        fontSize: 12,
        fontWeight: fontWeight,
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    switch (status.toUpperCase()) {
      case 'NEW':
        bgColor = const Color(0xFFE3F0FF);
        textColor = AppColors.primaryBlue;
        break;
      case 'INVESTIGATING':
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE65100);
        break;
      case 'RESOLVED':
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        break;
      default:
        bgColor = const Color(0xFFF5F5F5);
        textColor = const Color(0xFF616161);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: GoogleFonts.openSans(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: SizedBox.shrink(),
    );
  }
}

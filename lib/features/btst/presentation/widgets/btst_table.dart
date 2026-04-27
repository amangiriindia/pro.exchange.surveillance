import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget/table/view_data_table.dart';
import '../../domain/entities/btst_entity.dart';
import '../../../../core/widget/table_action_button.dart';

class BTSTTable extends StatelessWidget {
  final List<BTSTEntity> data;
  final ValueChanged<BTSTEntity> onViewSelected;
  final VoidCallback? onNearBottom;
  final bool isLoadingMore;

  static const double _triggerThresholdPx = 1600;

  const BTSTTable({
    super.key,
    required this.data,
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
      child: ViewDataTable<BTSTEntity>(
        columns: const [
          ViewTableColumn(id: 'u_name', label: 'U. NAME', width: 120),
          ViewTableColumn(id: 'p_user', label: 'P USER', width: 120),
          ViewTableColumn(id: 'exchange', label: 'EXCH', width: 100),
          ViewTableColumn(id: 'symbol', label: 'SYMBOL', width: 220),
          ViewTableColumn(id: 'pnl', label: 'P/L', width: 140, isNumeric: true),
          ViewTableColumn(id: 'in_time', label: 'In Time', width: 200),
          ViewTableColumn(id: 'out_time', label: 'Out Time', width: 200),
          ViewTableColumn(
            id: 'order_duration',
            label: 'ORDER DURATION',
            width: 180,
          ),
          ViewTableColumn(id: 'action', label: 'Action', width: 120),
        ],
        data: data,
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

  Widget _buildCell(
    BuildContext context,
    BTSTEntity item,
    ViewTableColumn col,
  ) {
    final currencyFormat = NumberFormat('#,##0.00');
    String text = '';
    Color textColor = const Color(0xFF616161);

    if (col.id == 'action') {
      return TableActionRow(onView: () => onViewSelected(item));
    }

    switch (col.id) {
      case 'u_name':
        text = item.uName;
        break;
      case 'p_user':
        text = item.pUser;
        break;
      case 'exchange':
        text = item.exchange;
        break;
      case 'symbol':
        text = item.symbol.trim().isEmpty ? '-' : item.symbol;
        break;
      case 'pnl':
        text = currencyFormat.format(item.pnl);
        textColor = item.pnl < 0 ? AppColors.errorColor : AppColors.primaryBlue;
        break;
      case 'in_time':
        try {
          final dt = DateTime.parse(item.inTime).toLocal();
          text =
              '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
        } catch (_) {
          text = item.inTime;
        }
        break;
      case 'out_time':
        try {
          final dt = DateTime.parse(item.outTime).toLocal();
          text =
              '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
        } catch (_) {
          text = item.outTime;
        }
        break;
      case 'order_duration':
        text = item.orderDuration;
        break;
    }

    return Text(
      text,
      style: GoogleFonts.openSans(
        color: textColor,
        fontSize: 12,
        fontWeight: FontWeight.w600,
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
      child: const SizedBox.shrink(),
    );
  }
}

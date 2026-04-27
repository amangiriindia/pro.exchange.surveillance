import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget/table/view_data_table.dart';
import '../../domain/entities/jobber_tracker_entity.dart';
import '../../../../core/widget/table_action_button.dart';

class JobberTrackerTable extends StatelessWidget {
  final List<JobberTrackerEntity> data;
  final ValueChanged<JobberTrackerEntity> onViewSelected;
  final VoidCallback? onNearBottom;
  final bool isLoadingMore;

  static const double _triggerThresholdPx = 1600;

  const JobberTrackerTable({
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
      child: ViewDataTable<JobberTrackerEntity>(
        columns: const [
          ViewTableColumn(id: 'time', label: 'Time', width: 200),
          ViewTableColumn(id: 'u_name', label: 'U. NAME', width: 140),
          ViewTableColumn(id: 'p_user', label: 'P USER', width: 140),
          ViewTableColumn(id: 'exchange', label: 'EXCH', width: 100),
          ViewTableColumn(id: 'symbol', label: 'SYMBOL', width: 220),
          ViewTableColumn(
            id: 'trade_frequency',
            label: 'Trade frequency',
            width: 160,
            isNumeric: true,
          ),
          ViewTableColumn(id: 'pnl', label: 'P/L', width: 140, isNumeric: true),
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
    JobberTrackerEntity item,
    ViewTableColumn col,
  ) {
    final currencyFormat = NumberFormat('#,##0.00');
    String text = '';
    Color textColor = const Color(0xFF616161);

    if (col.id == 'action') {
      return TableActionRow(onView: () => onViewSelected(item));
    }

    switch (col.id) {
      case 'time':
        try {
          final dt = DateTime.parse(item.time);
          text = DateFormat('dd/MM/yyyy | hh:mm:ss a').format(dt.toLocal());
        } catch (_) {
          text = item.time;
        }
        break;
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
      case 'trade_frequency':
        text = item.tradeFrequency.toString();
        break;
      case 'pnl':
        text = currencyFormat.format(item.pnl);
        textColor = item.pnl < 0 ? AppColors.errorColor : AppColors.primaryBlue;
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

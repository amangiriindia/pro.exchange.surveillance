import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget/table/view_data_table.dart';
import '../../domain/entities/jobber_tracker_entity.dart';
import '../../../../core/widget/table_action_button.dart';

class JobberTrackerTable extends StatelessWidget {
  final List<JobberTrackerEntity> data;
  final ValueChanged<String> onViewSelected;

  const JobberTrackerTable({super.key, required this.data, required this.onViewSelected});

  @override
  Widget build(BuildContext context) {
    return ViewDataTable<JobberTrackerEntity>(
      columns: const [
        ViewTableColumn(id: 'time', label: 'Time', width: 200),
        ViewTableColumn(id: 'u_name', label: 'U. NAME', width: 140),
        ViewTableColumn(id: 'p_user', label: 'P USER', width: 140),
        ViewTableColumn(id: 'exchange', label: 'EXCH', width: 100),
        ViewTableColumn(id: 'symbol', label: 'SYMBOL', width: 140),
        ViewTableColumn(id: 'trade_frequency', label: 'Trade frequency', width: 160, isNumeric: true),
        ViewTableColumn(id: 'pnl', label: 'P/L', width: 140, isNumeric: true),
        ViewTableColumn(id: 'action', label: 'Action', width: 240),
      ],
      data: data,
      idExtractor: (item) => '${item.uName}_${item.tradeFrequency}_${item.pnl}',
      autoFit: true,
      isDarkMode: AppColors.isDarkMode(context),
      rowBackgroundBuilder: (item, index) => index % 2 == 0 ? AppColors.getTableRowBackground(context) : AppColors.getTableAlternateRowBackground(context),
      cellBuilder: (item, col) => _buildCell(context, item, col),
    );
  }

  Widget _buildCell(BuildContext context, JobberTrackerEntity item, ViewTableColumn col) {
    final currencyFormat = NumberFormat('#,##0.00');
    String text = '';
    Color textColor = const Color(0xFF616161);

    if (col.id == 'action') {
      return TableActionRow(
        onView: () => onViewSelected(item.uName),
      );
    }

    switch (col.id) {
      case 'time': text = item.time; break;
      case 'u_name': text = item.uName; break;
      case 'p_user': text = item.pUser; break;
      case 'exchange': text = item.exchange; break;
      case 'symbol': text = item.symbol; break;
      case 'trade_frequency': text = item.tradeFrequency.toString(); break;
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget/table/view_data_table.dart';
import '../../domain/entities/jobber_tracker_entity.dart';
import '../../../../core/widget/custom_action_button.dart';

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
        ViewTableColumn(id: 'action', label: 'Action', width: 200),
      ],
      data: data,
      idExtractor: (item) => '${item.uName}_${item.tradeFrequency}_${item.pnl}',
      autoFit: true,
      isDarkMode: false,
      rowBackgroundBuilder: (item, index) => index % 2 == 0 ? Colors.white : const Color(0xFFF5F6F8),
      cellBuilder: (item, col) => _buildCell(context, item, col),
    );
  }

  Widget _buildCell(BuildContext context, JobberTrackerEntity item, ViewTableColumn col) {
    final currencyFormat = NumberFormat('#,##0.00');
    String text = '';
    Color textColor = const Color(0xFF616161);

    if (col.id == 'action') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomActionButton(
            text: 'View',
            onPressed: () => onViewSelected(item.uName),
            width: 65,
            height: 26,
            fontSize: 11,
          ),
          const SizedBox(width: 8),
          CustomActionButton(
            text: 'Investigate',
            onPressed: () {},
            width: 85,
            height: 26,
            fontSize: 11,
          ),
        ],
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

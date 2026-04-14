import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget/table/view_data_table.dart';
import '../../domain/entities/bulk_order_entity.dart';
import '../../../../core/widget/table_action_button.dart';

class BulkOrderTable extends StatelessWidget {
  final List<BulkOrderEntity> trades;
  final ValueChanged<String> onViewSelected;

  const BulkOrderTable({super.key, required this.trades, required this.onViewSelected});

  @override
  Widget build(BuildContext context) {
    return ViewDataTable<BulkOrderEntity>(
      columns: _buildColumns(),
      data: trades,
      idExtractor: (item) => item.time + item.symbol, // Dummy composite ID
      autoFit: true,
      isDarkMode: AppColors.isDarkMode(context),
      rowBackgroundBuilder: (item, index) => index % 2 == 0 ? AppColors.getTableRowBackground(context) : AppColors.getTableAlternateRowBackground(context),
      cellBuilder: (item, col) => _buildCell(context, item, col),
    );
  }

  List<ViewTableColumn> _buildColumns() {
    return const [
      ViewTableColumn(id: 'time', label: 'Time', width: 220),
      ViewTableColumn(id: 'exchange', label: 'Exchange', width: 140),
      ViewTableColumn(id: 'symbol', label: 'Symbol', width: 220),
      ViewTableColumn(id: 'quantity', label: 'Quantity', width: 160, isNumeric: true),
      ViewTableColumn(id: 'action', label: 'Action', width: 250),
    ];
  }

  Widget _buildCell(BuildContext context, BulkOrderEntity trade, ViewTableColumn col) {
    Color textColor = const Color(0xFF616161);
    FontWeight fontWeight = FontWeight.w600;

    if (col.id == 'action') {
      return TableActionRow(
        onView: () => onViewSelected(trade.symbol),
      );
    }

    String text = '';
    switch (col.id) {
      case 'time':
        text = trade.time;
        break;
      case 'exchange':
        text = trade.exchange;
        break;
      case 'symbol':
        text = trade.symbol;
        break;
      case 'quantity':
        final formatter = NumberFormat('#,##0');
        text = formatter.format(trade.quantity.abs());
        textColor = trade.quantity < 0 ? AppColors.errorColor : AppColors.primaryBlue;
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
}

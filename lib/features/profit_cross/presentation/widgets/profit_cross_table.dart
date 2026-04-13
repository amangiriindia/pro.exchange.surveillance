import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget/table/view_data_table.dart';
import '../../../../core/widget/common_dilog_box.dart';
import '../../domain/entities/profit_cross_entity.dart';
import '../bloc/profit_cross_bloc.dart';
import 'order_duration_dialog_content.dart';

class ProfitCrossTable extends StatelessWidget {
  final List<ProfitCrossEntity> data;

  const ProfitCrossTable({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ViewDataTable<ProfitCrossEntity>(
      columns: const [
        ViewTableColumn(id: 'time', label: 'Time', width: 200),
        ViewTableColumn(id: 'exchange', label: 'EXCH', width: 100),
        ViewTableColumn(id: 'symbol', label: 'SYMBOL', width: 140),
        ViewTableColumn(id: 'order_dt', label: 'ORDER D/T', width: 200),
        ViewTableColumn(id: 'pnl', label: 'P/L', width: 120, isNumeric: true),
        ViewTableColumn(id: 'order_duration', label: 'ORDER DURATION', width: 180),
        ViewTableColumn(id: 'pnl_percentage', label: 'P/L%', width: 100, isNumeric: true),
      ],
      data: data,
      idExtractor: (item) => item.time + item.symbol + item.pnlPercentage.toString(),
      autoFit: true,
      isDarkMode: false,
      rowBackgroundBuilder: (item, index) => index % 2 == 0 ? Colors.white : const Color(0xFFF5F6F8),
      cellBuilder: (item, col) => _buildCell(context, item, col),
    );
  }

  Widget _buildCell(BuildContext context, ProfitCrossEntity item, ViewTableColumn col) {
    final currencyFormat = NumberFormat('#,##0.00');
    String text = '';
    Color textColor = const Color(0xFF616161);
    bool isUnderlined = false;

    switch (col.id) {
      case 'time':
        text = item.time;
        break;
      case 'exchange':
        text = item.exchange;
        break;
      case 'symbol':
        text = item.symbol;
        break;
      case 'order_dt':
        text = item.orderDT;
        break;
      case 'pnl':
        text = currencyFormat.format(item.pnl);
        textColor = item.pnl < 0 ? AppColors.errorColor : AppColors.primaryBlue;
        break;
      case 'order_duration':
        text = item.orderDuration;
        isUnderlined = true;
        break;
      case 'pnl_percentage':
        text = item.pnlPercentage.toStringAsFixed(0);
        break;
    }

    Widget cellWidget = Text(
      text,
      style: GoogleFonts.openSans(
        color: textColor,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        decoration: isUnderlined ? TextDecoration.underline : null,
      ),
    );

    if (col.id == 'order_duration') {
      return InkWell(
        onTap: () {
          _showOrderDurationDialog(context, item.symbol);
        },
        child: cellWidget,
      );
    }

    return cellWidget;
  }

  void _showOrderDurationDialog(BuildContext context, String symbol) {
    final bloc = context.read<ProfitCrossBloc>();
    bloc.add(LoadOrderDurationDetails(symbol));

    CommonDialog.show(
      context: context,
      title: 'Order Duration',
      width: 1100,
      height: 500,
      showButtons: false,
      backgroundColor: Colors.white,
      headerColor: Colors.white,
      titleActions: [], // Can add icons here if needed to match screenshot exactly
      content: BlocProvider.value(
        value: bloc,
        child: OrderDurationDialogContent(symbol: symbol),
      ),
    );
  }
}

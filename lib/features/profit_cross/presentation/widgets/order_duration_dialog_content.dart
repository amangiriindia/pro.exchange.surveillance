import 'package:surveillance/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/widget/table/view_data_table.dart';
import '../bloc/profit_cross_bloc.dart';
import '../../domain/entities/order_duration_entity.dart';

class OrderDurationDialogContent extends StatelessWidget {
  final String symbol;

  const OrderDurationDialogContent({super.key, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfitCrossBloc, ProfitCrossState>(
        builder: (context, state) {
          if (state is OrderDurationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OrderDurationLoaded) {
            return ViewDataTable<OrderDurationEntity>(
              columns: const [
                ViewTableColumn(id: 'duration', label: 'DURATION', width: 140),
                ViewTableColumn(id: 'symbol', label: 'SYMBOL', width: 180),
                ViewTableColumn(id: 'type', label: 'TYPE', width: 100),
                ViewTableColumn(id: 'qty', label: 'QTY', width: 100, isNumeric: true),
                ViewTableColumn(id: 'price', label: 'PRICE', width: 120, isNumeric: true),
                ViewTableColumn(id: 'execution_dt', label: 'EXECUTION D/T', width: 180),
                ViewTableColumn(id: 'pnl', label: 'P/L', width: 120, isNumeric: true),
              ],
              data: state.details,
              idExtractor: (item) => item.executionDT + item.symbol,
              autoFit: true,
              isDarkMode: AppColors.isDarkMode(context),
              cellBuilder: (item, col) => _buildCell(context, item, col),
            );
          }
          return const Center(child: Text('No details available'));
        },
      );
  
  }

  Widget _buildCell(BuildContext context, OrderDurationEntity item, ViewTableColumn col) {
    final currencyFormat = NumberFormat('#,##0');
    String text = '';
    Color textColor = Colors.black87;

    switch (col.id) {
      case 'duration':
        text = item.duration;
        break;
      case 'symbol':
        text = item.symbol;
        textColor = const Color(0xFF2E6BFF);
        break;
      case 'type':
        text = item.type;
        textColor = item.type.toLowerCase().contains('sell') ? Colors.red : const Color(0xFF2E6BFF);
        break;
      case 'qty':
        text = currencyFormat.format(item.qty);
        textColor = const Color(0xFF2E6BFF);
        break;
      case 'price':
        text = currencyFormat.format(item.price);
        textColor = const Color(0xFF2E6BFF);
        break;
      case 'execution_dt':
        text = item.executionDT;
        break;
      case 'pnl':
        text = currencyFormat.format(item.pnl);
        textColor = item.pnl < 0 ? Colors.red : const Color(0xFF2E6BFF);
        break;
    }

    return Text(
      text,
      style: GoogleFonts.openSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }
}

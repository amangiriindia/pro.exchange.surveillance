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
  final VoidCallback? onNearBottom;
  final bool isLoadingMore;

  static const double _triggerThresholdPx = 1600;

  const ProfitCrossTable({
    super.key,
    required this.data,
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
      child: ViewDataTable<ProfitCrossEntity>(
        columns: const [
          ViewTableColumn(id: 'time', label: 'Time', width: 200),
          ViewTableColumn(id: 'exchange', label: 'EXCH', width: 100),
          ViewTableColumn(id: 'symbol', label: 'SYMBOL', width: 220),
          ViewTableColumn(id: 'order_dt', label: 'ORDER D/T', width: 200),
          ViewTableColumn(id: 'pnl', label: 'P/L', width: 120, isNumeric: true),
          ViewTableColumn(
            id: 'order_duration',
            label: 'ORDER DURATION',
            width: 180,
          ),
          ViewTableColumn(
            id: 'pnl_percentage',
            label: 'P/L%',
            width: 100,
            isNumeric: true,
          ),
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
    ProfitCrossEntity item,
    ViewTableColumn col,
  ) {
    final currencyFormat = NumberFormat('#,##0.00');
    String text = '';
    Color textColor = const Color(0xFF616161);

    switch (col.id) {
      case 'time':
        text = item.time;
        break;
      case 'exchange':
        text = item.exchange;
        break;
      case 'symbol':
        text = item.symbol.trim().isEmpty ? '-' : item.symbol;
        break;
      case 'order_dt':
        try {
          final dt = DateTime.parse(item.orderDT);
          text = DateFormat('dd/MM/yy hh:mm:ss a').format(dt.toLocal());
        } catch (_) {
          text = item.orderDT;
        }
        break;
      case 'pnl':
        text = currencyFormat.format(item.pnl);
        textColor = item.pnl < 0 ? AppColors.errorColor : AppColors.primaryBlue;
        break;
      case 'order_duration':
        text = item.orderDuration;
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
      ),
    );

    if (col.id == 'order_duration') {
      return InkWell(
        onTap: () {
          _showOrderDurationDialog(context, item.id, item.symbol);
        },
        child: Text(
          text,
          style: GoogleFonts.openSans(
            color: AppColors.primaryBlue,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.primaryBlue,
          ),
        ),
      );
    }

    return cellWidget;
  }

  void _showOrderDurationDialog(
    BuildContext context,
    int alertId,
    String symbol,
  ) {
    final bloc = context.read<ProfitCrossBloc>();
    bloc.add(LoadOrderDurationDetails(alertId));

    CommonDialog.show(
      context: context,
      title: 'Order Duration',
      width: 1200,
      height: 600,
      showButtons: false,
      backgroundColor: Colors.white,
      headerColor: const Color.fromARGB(255, 2, 12, 28),
      titleActions: [],
      content: BlocProvider.value(
        value: bloc,
        child: OrderDurationDialogContent(alertId: alertId, symbol: symbol),
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

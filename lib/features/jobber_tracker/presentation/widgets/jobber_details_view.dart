import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget/table/view_data_table.dart';
import '../../../../injection_container.dart';
import '../bloc/jobber_details_bloc.dart';
import '../../domain/entities/jobber_detail_entity.dart';

class JobberDetailsView extends StatelessWidget {
  final int alertId;
  final String uName;
  final VoidCallback onBack;

  const JobberDetailsView({
    super.key,
    required this.alertId,
    required this.uName,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<JobberDetailsBloc>()..add(LoadJobberDetails(alertId)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBreadcrumbs(context),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<JobberDetailsBloc, JobberDetailsState>(
              builder: (context, state) {
                if (state is JobberDetailsLoading) {
                  return const SizedBox.shrink();
                } else if (state is JobberDetailsLoaded) {
                  return _buildTable(state.details, context);
                } else if (state is JobberDetailsError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbs(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onBack,
          child: Text(
            'Jobber Tracker  ',
            style: GoogleFonts.openSans(fontSize: 18, color: Colors.black87),
          ),
        ),
        const Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 14),
        const SizedBox(width: 8),
        Text(
          uName,
          style: GoogleFonts.openSans(
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTable(List<JobberDetailEntity> data, BuildContext context) {
    return ViewDataTable<JobberDetailEntity>(
      columns: const [
        ViewTableColumn(id: 'u_name', label: 'U. NAME', width: 100),
        ViewTableColumn(id: 'p_user', label: 'P USER', width: 100),
        ViewTableColumn(id: 'exch', label: 'EXCH', width: 80),
        ViewTableColumn(id: 'symbol', label: 'SYMBOL', width: 110),
        ViewTableColumn(id: 'order_time', label: 'ORDER D/T', width: 180),
        ViewTableColumn(id: 'trade_type', label: 'tradeType', width: 100),
        ViewTableColumn(id: 'order_type', label: 'orderType', width: 110),
        ViewTableColumn(id: 'comment', label: 'comment', width: 180),
        ViewTableColumn(
          id: 'quantity',
          label: 'QTY',
          width: 110,
          isNumeric: true,
        ),
        ViewTableColumn(id: 'lot', label: 'LOT', width: 80, isNumeric: true),
        ViewTableColumn(id: 'pl', label: 'P/L', width: 100, isNumeric: true),
        ViewTableColumn(
          id: 't_price',
          label: 'T. PRICE',
          width: 100,
          isNumeric: true,
        ),
        ViewTableColumn(id: 'brk', label: 'BRK', width: 80, isNumeric: true),
        ViewTableColumn(
          id: 'r_price',
          label: 'R. PRICE',
          width: 80,
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
    );
  }

  Widget _buildCell(
    BuildContext context,
    JobberDetailEntity item,
    ViewTableColumn col,
  ) {
    final currencyFormat = NumberFormat('#,##0.00');
    String text = '';
    Color textColor = const Color(0xFF616161);

    switch (col.id) {
      case 'u_name':
        text = item.uName;
        break;
      case 'p_user':
        text = item.pUser;
        break;
      case 'exch':
        text = item.exch;
        break;
      case 'symbol':
        text = item.symbol;
        textColor = const Color(0xFFE27C00);
        break;
      case 'order_time':
        try {
          final dt = DateTime.parse(item.orderTime);
          text = DateFormat('dd/MM/yy hh:mm:ss a').format(dt.toLocal());
        } catch (_) {
          text = item.orderTime;
        }
        break;
      case 'buy_sell':
        text = item.buySell;
        textColor = text.toLowerCase().contains('sell')
            ? AppColors.errorColor
            : AppColors.primaryBlue;
        break;
      case 'trade_type':
        text = item.tradeType.isEmpty ? '-' : item.tradeType;
        textColor = item.tradeType.toLowerCase() == 'buy'
            ? AppColors.primaryBlue
            : AppColors.errorColor;
        break;
      case 'order_type':
        text = item.orderType ?? '-';
        break;
      case 'comment':
        text = item.comment ?? '-';
        break;
      case 'quantity':
        text = currencyFormat.format(item.quantity);
        textColor = item.quantity < 0
            ? AppColors.errorColor
            : AppColors.primaryBlue;
        break;
      case 'lot':
        text = currencyFormat.format(item.lot);
        break;
      case 'pl':
        text = currencyFormat.format(item.pl);
        textColor = AppColors.primaryBlue;
        break;
      case 't_price':
        text = currencyFormat.format(item.tPrice);
        textColor = AppColors.errorColor;
        break;
      case 'brk':
        text = currencyFormat.format(item.brk);
        break;
      case 'r_price':
        text = currencyFormat.format(item.rPrice);
        break;
    }

    return Text(
      text,
      style: GoogleFonts.openSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

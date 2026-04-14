import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget/table/view_data_table.dart';
import '../../../../injection_container.dart';
import '../bloc/same_ip_details_bloc.dart';
import '../../domain/entities/same_ip_detail_entity.dart';

class SameIPDetailsView extends StatelessWidget {
  final String clusterId;
  final VoidCallback onBack;

  const SameIPDetailsView({
    super.key,
    required this.clusterId,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SameIPDetailsBloc>()..add(LoadSameIPDetails(clusterId)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBreadcrumbs(context),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<SameIPDetailsBloc, SameIPDetailsState>(
              builder: (context, state) {
                if (state is SameIPDetailsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SameIPDetailsLoaded) {
                  return _buildTable(state.details, context);
                } else if (state is SameIPDetailsError) {
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
            'Same IP Tracker  ',
            style: GoogleFonts.openSans(fontSize: 18, color: Colors.black87),
          ),
        ),
        const Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            clusterId,
            style: GoogleFonts.openSans(
              fontSize: 18,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTable(List<SameIPDetailEntity> data, BuildContext context) {
    return ViewDataTable<SameIPDetailEntity>(
      columns: const [
        ViewTableColumn(id: 'u_name', label: 'U. NAME', width: 100),
        ViewTableColumn(id: 'p_user', label: 'P USER', width: 100),
        ViewTableColumn(id: 'exch', label: 'EXCH', width: 80),
        ViewTableColumn(id: 'symbol', label: 'SYMBOL', width: 110),
        ViewTableColumn(id: 'order_time', label: 'ORDER D/T', width: 180),
        ViewTableColumn(id: 'buy_sell', label: 'B/S', width: 180),
        ViewTableColumn(
          id: 'quantity',
          label: 'QTY',
          width: 110,
          isNumeric: true,
        ),
        ViewTableColumn(id: 'lot', label: 'LOT', width: 80, isNumeric: true),
        ViewTableColumn(id: 'type', label: 'TYPE', width: 80),
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
      idExtractor: (item) => '${item.uName}_${item.orderTime}_${item.quantity}',
      autoFit: true,
      isDarkMode: AppColors.isDarkMode(context),
      rowBackgroundBuilder: (item, index) =>
          index % 2 == 0 ? AppColors.getTableRowBackground(context) : AppColors.getTableAlternateRowBackground(context),
      cellBuilder: (item, col) => _buildCell(context, item, col),
    );
  }

  Widget _buildCell(
    BuildContext context,
    SameIPDetailEntity item,
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
        text = item.orderTime;
        break;
      case 'buy_sell':
        text = item.buySell;
        textColor = text.contains('SELL')
            ? AppColors.errorColor
            : AppColors.primaryBlue;
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
      case 'type':
        text = item.type;
        break;
      case 'pl':
        text = currencyFormat.format(item.pl);
        textColor = AppColors.errorColor;
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

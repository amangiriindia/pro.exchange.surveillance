import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/widget/table/view_data_table.dart';
import '../../../../../injection_container.dart';
import '../../domain/entities/bulk_order_details_entity.dart';
import '../bloc/details/bulk_order_details_bloc.dart';
import '../bloc/details/bulk_order_details_event.dart';
import '../bloc/details/bulk_order_details_state.dart';
import '../../../../../core/constants/app_colors.dart';

class BulkOrderDetailsView extends StatelessWidget {
  final int alertId;
  final String symbol;
  final VoidCallback onBack;

  const BulkOrderDetailsView({
    super.key,
    required this.alertId,
    required this.symbol,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<BulkOrderDetailsBloc>()
            ..add(LoadBulkOrderDetails(alertId: alertId)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: onBack,
                child: Text(
                  'Bulk Order Tracker  ',
                  style: GoogleFonts.openSans(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.black54,
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                symbol,
                style: GoogleFonts.openSans(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<BulkOrderDetailsBloc, BulkOrderDetailsState>(
              builder: (context, state) {
                if (state is BulkOrderDetailsLoading) {
                  return const SizedBox.shrink();
                } else if (state is BulkOrderDetailsLoaded) {
                  return _buildTable(context, state.details);
                } else if (state is BulkOrderDetailsError) {
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

  Widget _buildTable(BuildContext context, List<BulkOrderDetailsEntity> data) {
    return ViewDataTable<BulkOrderDetailsEntity>(
      columns: const [
        ViewTableColumn(id: 'uName', label: 'U. NAME', width: 100),
        ViewTableColumn(id: 'pUser', label: 'P USER', width: 100),
        ViewTableColumn(id: 'exch', label: 'EXCH', width: 80),
        ViewTableColumn(id: 'symbol', label: 'SYMBOL', width: 180),
        ViewTableColumn(id: 'orderTime', label: 'ORDER D/T', width: 180),
        ViewTableColumn(id: 'buySell', label: 'B/S', width: 160),
        ViewTableColumn(
          id: 'quantity',
          label: 'QTY',
          width: 100,
          isNumeric: true,
        ),
        ViewTableColumn(id: 'lot', label: 'LOT', width: 80, isNumeric: true),
        ViewTableColumn(id: 'type', label: 'TYPE', width: 100),
        ViewTableColumn(id: 'pl', label: 'P/L', width: 120, isNumeric: true),
        ViewTableColumn(
          id: 'tPrice',
          label: 'T. PRICE',
          width: 120,
          isNumeric: true,
        ),
        ViewTableColumn(id: 'brk', label: 'BRK', width: 80, isNumeric: true),
        ViewTableColumn(
          id: 'rPrice',
          label: 'R. PRICE',
          width: 80,
          isNumeric: true,
        ),
        ViewTableColumn(
          id: 'executionTime',
          label: 'EXECUTION D/T',
          width: 180,
        ),
        ViewTableColumn(id: 'deviceId', label: 'DEVICE ID', width: 300),
        ViewTableColumn(id: 'ipAddress', label: 'IP ADDRESS', width: 130),
        ViewTableColumn(id: 'city', label: 'CITY', width: 100),
      ],
      data: data,
      idExtractor: (item) => item.id.toString(),
      autoFit: true,
      isDarkMode: AppColors.isDarkMode(context),
      rowBackgroundBuilder: (item, index) => index % 2 == 0
          ? AppColors.getTableRowBackground(context)
          : AppColors.getTableAlternateRowBackground(context),
      cellBuilder: (item, col) {
        String text = '';
        Color textColor = const Color(0xFF616161);
        switch (col.id) {
          case 'uName':
            text = item.uName;
            break;
          case 'pUser':
            text = item.pUser;
            break;
          case 'exch':
            text = item.exch;
            break;
          case 'symbol':
            text = item.symbol;
            break;
          case 'orderTime':
            try {
              final dt = DateTime.parse(item.orderTime).toLocal();
              text =
                  '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year.toString().substring(2)} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
            } catch (_) {
              text = item.orderTime;
            }
            break;
          case 'buySell':
            text = item.buySell;
            textColor = item.tradeType.toLowerCase() == 'buy'
                ? AppColors.primaryBlue
                : AppColors.errorColor;
            break;
          case 'quantity':
            text = item.quantity.toStringAsFixed(2);
            textColor = item.tradeType.toLowerCase() == 'buy'
                ? AppColors.primaryBlue
                : AppColors.errorColor;
            break;
          case 'lot':
            text = item.lot.toStringAsFixed(2);
            break;
          case 'type':
            text = item.type;
            break;
          case 'pl':
            text = item.pl.toStringAsFixed(2);
            textColor = item.pl >= 0
                ? AppColors.primaryBlue
                : AppColors.errorColor;
            break;
          case 'tPrice':
            text = item.tPrice.toStringAsFixed(2);
            break;
          case 'brk':
            text = item.brk.toStringAsFixed(2);
            break;
          case 'rPrice':
            text = item.rPrice.toStringAsFixed(2);
            break;
          case 'executionTime':
            try {
              final dt = DateTime.parse(item.executionTime).toLocal();
              text =
                  '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year.toString().substring(2)} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
            } catch (_) {
              text = item.executionTime;
            }
            break;
          case 'deviceId':
            text = item.deviceId;
            break;
          case 'ipAddress':
            text = item.ipAddress;
            break;
          case 'city':
            text = item.city;
            break;
        }
        return Text(
          text,
          style: GoogleFonts.openSans(fontSize: 12, color: textColor),
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}

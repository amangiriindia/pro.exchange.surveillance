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
  final String symbol;
  final VoidCallback onBack;

  const BulkOrderDetailsView({
    super.key,
    required this.symbol,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BulkOrderDetailsBloc>()..add(LoadBulkOrderDetails(symbol: symbol)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: onBack,
                child: Text(
                  'Bulk Order Tracker  ',
                  style: GoogleFonts.openSans(fontSize: 18, color: Colors.black87),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.black54, size: 14),
              const SizedBox(width: 8),
              Text(
                symbol,
                style: GoogleFonts.openSans(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<BulkOrderDetailsBloc, BulkOrderDetailsState>(
              builder: (context, state) {
                if (state is BulkOrderDetailsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is BulkOrderDetailsLoaded) {
                  return _buildTable(state.details);
                } else if (state is BulkOrderDetailsError) {
                  return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<BulkOrderDetailsEntity> data) {
    return ViewDataTable<BulkOrderDetailsEntity>(
      columns: const [
        ViewTableColumn(id: 'uName', label: 'U. NAME', width: 100),
        ViewTableColumn(id: 'pUser', label: 'P USER', width: 100),
        ViewTableColumn(id: 'exch', label: 'EXCH', width: 80),
        ViewTableColumn(id: 'symbol', label: 'SYMBOL', width: 110),
        ViewTableColumn(id: 'orderTime', label: 'ORDER D/T', width: 180),
        ViewTableColumn(id: 'buySell', label: 'B/S', width: 180),
        ViewTableColumn(id: 'quantity', label: 'QTY', width: 110, isNumeric: true),
        ViewTableColumn(id: 'lot', label: 'LOT', width: 80, isNumeric: true),
        ViewTableColumn(id: 'type', label: 'TYPE', width: 80),
        ViewTableColumn(id: 'pl', label: 'P/L', width: 100, isNumeric: true),
        ViewTableColumn(id: 'tPrice', label: 'T. PRICE', width: 100, isNumeric: true),
        ViewTableColumn(id: 'brk', label: 'BRK', width: 80, isNumeric: true),
        ViewTableColumn(id: 'rPrice', label: 'R. PRICE', width: 80, isNumeric: true),
        ViewTableColumn(id: 'executionTime', label: 'EXECUTION D/T', width: 180),
        ViewTableColumn(id: 'deviceId', label: 'DEVICE ID', width: 350),
        ViewTableColumn(id: 'ipAddress', label: 'IP ADDRESS', width: 130),
        ViewTableColumn(id: 'city', label: 'CITY', width: 100),
      ],
      data: data,
      idExtractor: (item) => '${item.uName}_${item.orderTime}', // Mock unique key
      autoFit: true,
      isDarkMode: false,
      rowBackgroundBuilder: (item, index) => index % 2 == 0 ? Colors.white : const Color(0xFFF5F6F8),
      cellBuilder: (item, col) {
        String text = '';
        Color textColor = const Color(0xFF616161);
        switch (col.id) {
          case 'uName': text = item.uName; break;
          case 'pUser': text = item.pUser; break;
          case 'exch': text = item.exch; break;
          case 'symbol': text = item.symbol; break;
          case 'orderTime': text = item.orderTime; break;
          case 'buySell': 
            text = item.buySell; 
            textColor = text.startsWith('BUY') ? AppColors.primaryBlue : AppColors.errorColor;
            break;
          case 'quantity': 
            text = item.quantity.toStringAsFixed(2); 
            textColor = item.quantity > 0 ? AppColors.primaryBlue : AppColors.errorColor;
            break;
          case 'lot': text = item.lot.toStringAsFixed(2); break;
          case 'type': text = item.type; break;
          case 'pl': 
            text = item.pl.toStringAsFixed(2); 
            textColor = AppColors.errorColor;
            break;
          case 'tPrice': 
            text = item.tPrice.toStringAsFixed(2); 
            textColor = item.tPrice < 0 ? AppColors.primaryBlue : AppColors.errorColor;
            break;
          case 'brk': 
            text = item.brk.toStringAsFixed(2); 
            textColor = AppColors.errorColor;
            break;
          case 'rPrice': 
            text = item.rPrice.toStringAsFixed(2); 
            textColor = AppColors.errorColor; 
            break;
          case 'executionTime': text = item.executionTime; break;
          case 'deviceId': text = item.deviceId; break;
          case 'ipAddress': text = item.ipAddress; break;
          case 'city': text = item.city; break;
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

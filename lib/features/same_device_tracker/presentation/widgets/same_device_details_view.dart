import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget/city_from_ip_table_cell.dart';
import '../../../../core/widget/prefetch_ip_city_scope.dart';
import '../../../../core/widget/table/view_data_table.dart';
import '../../../../injection_container.dart';
import '../bloc/same_device_details_bloc.dart';
import '../../domain/entities/same_device_detail_entity.dart';

class SameDeviceDetailsView extends StatelessWidget {
  final int alertId;
  final String clusterId;
  final VoidCallback onBack;

  const SameDeviceDetailsView({
    super.key,
    required this.alertId,
    required this.clusterId,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<SameDeviceDetailsBloc>()..add(LoadSameDeviceDetails(alertId)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBreadcrumbs(context),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<SameDeviceDetailsBloc, SameDeviceDetailsState>(
              builder: (context, state) {
                if (state is SameDeviceDetailsLoading) {
                  return const SizedBox.shrink();
                } else if (state is SameDeviceDetailsLoaded) {
                  return _buildTable(state.details, context);
                } else if (state is SameDeviceDetailsError) {
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
            'Same device Tracker  ',
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

  Widget _buildTable(List<SameDeviceDetailEntity> data, BuildContext context) {
    return PrefetchIpCityScope(
      rowSources: data
          .map((e) => (ip: e.ipAddress, backendCity: e.city))
          .toList(),
      builder: (ctx, resolvedCityByIp) {
        return ViewDataTable<SameDeviceDetailEntity>(
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
            ViewTableColumn(
              id: 'lot',
              label: 'LOT',
              width: 80,
              isNumeric: true,
            ),
            ViewTableColumn(
              id: 'pl',
              label: 'P/L',
              width: 100,
              isNumeric: true,
            ),
            ViewTableColumn(
              id: 't_price',
              label: 'T. PRICE',
              width: 100,
              isNumeric: true,
            ),
            ViewTableColumn(
              id: 'brk',
              label: 'BRK',
              width: 80,
              isNumeric: true,
            ),
            ViewTableColumn(
              id: 'r_price',
              label: 'R. PRICE',
              width: 80,
              isNumeric: true,
            ),
            ViewTableColumn(
              id: 'execution_time',
              label: 'EXECUTION D/T',
              width: 180,
            ),
            ViewTableColumn(id: 'device_id', label: 'DEVICE ID', width: 280),
            ViewTableColumn(id: 'ip_address', label: 'IP ADDRESS', width: 150),
            ViewTableColumn(id: 'city', label: 'CITY', width: 120),
          ],
          data: data,
          idExtractor: (item) => item.id.toString(),
          autoFit: true,
          isDarkMode: AppColors.isDarkMode(ctx),
          rowBackgroundBuilder: (item, index) => index % 2 == 0
              ? AppColors.getTableRowBackground(ctx)
              : AppColors.getTableAlternateRowBackground(ctx),
          cellBuilder: (item, col) =>
              _buildCell(ctx, item, col, resolvedCityByIp),
        );
      },
    );
  }

  Widget _buildCell(
    BuildContext context,
    SameDeviceDetailEntity item,
    ViewTableColumn col,
    Map<String, String> resolvedCityByIp,
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
          final dt = DateTime.parse(item.orderTime).toLocal();
          text =
              '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
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
      case 'execution_time':
        try {
          final dt = DateTime.parse(item.executionTime).toLocal();
          text =
              '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
        } catch (_) {
          text = item.executionTime;
        }
        break;
      case 'device_id':
        text = item.deviceId;
        break;
      case 'ip_address':
        text = item.ipAddress;
        break;
      case 'city':
        return buildCityFromIpCell(
          context,
          backendCity: item.city,
          ip: item.ipAddress,
          resolvedCityByIp: resolvedCityByIp,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          textColor: const Color(0xFF616161),
        );
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

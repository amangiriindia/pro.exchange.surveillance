import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widget/city_from_ip_table_cell.dart';
import '../../../../../core/widget/table/view_data_table.dart';
import '../../../../../injection_container.dart';

import '../../domain/entities/group_trade_details_entity.dart';
import '../bloc/details/group_trade_details_bloc.dart';
import '../bloc/details/group_trade_details_event.dart';
import '../bloc/details/group_trade_details_state.dart';

class GroupTradeDetailsView extends StatelessWidget {
  final int alertId;
  final String symbol;
  final VoidCallback onBack;

  const GroupTradeDetailsView({
    super.key,
    required this.alertId,
    required this.symbol,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<GroupTradeDetailsBloc>()
            ..add(LoadGroupTradeDetails(alertId: alertId)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: onBack,
                child: Text(
                  'Group Trade  ',
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
            child: BlocBuilder<GroupTradeDetailsBloc, GroupTradeDetailsState>(
              builder: (context, state) {
                if (state is GroupTradeDetailsLoading) {
                  return const SizedBox.shrink();
                } else if (state is GroupTradeDetailsLoaded) {
                  return _buildTable(
                    context,
                    state.details,
                    state.resolvedCityByIp,
                  );
                } else if (state is GroupTradeDetailsError) {
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

  Widget _buildTable(
    BuildContext context,
    List<GroupTradeDetailsEntity> data,
    Map<String, String> resolvedCityByIp,
  ) {
    return ViewDataTable<GroupTradeDetailsEntity>(
      columns: const [
        ViewTableColumn(id: 'uName', label: 'U. NAME', width: 100),
        ViewTableColumn(id: 'pUser', label: 'P USER', width: 100),
        ViewTableColumn(id: 'exch', label: 'EXCH', width: 80),
        ViewTableColumn(id: 'symbol', label: 'SYMBOL', width: 180),
        ViewTableColumn(id: 'orderTime', label: 'ORDER D/T', width: 180),
        ViewTableColumn(id: 'buySell', label: 'B/S', width: 160),
        ViewTableColumn(id: 'tradeType', label: 'tradeType', width: 100),
        ViewTableColumn(id: 'orderType', label: 'orderType', width: 110),
        ViewTableColumn(id: 'comment', label: 'comment', width: 180),
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
      cellBuilder: (item, col) =>
          _buildCell(context, item, col, resolvedCityByIp),
    );
  }

  Widget _buildCell(
    BuildContext context,
    GroupTradeDetailsEntity item,
    ViewTableColumn col,
    Map<String, String> resolvedCityByIp,
  ) {
    String text = '';
    Color textColor = const Color(0xFF616161);

    switch (col.id) {
      case 'uName':
        text = item.userName ?? '-';
        break;
      case 'pUser':
        text = item.parentUserName ?? '-';
        break;
      case 'exch':
        text = item.exchange;
        break;
      case 'symbol':
        text = item.symbol;
        break;
      case 'orderTime':
        text = item.orderDateTime;
        break;
      case 'buySell':
        text = item.buySell;
        textColor = item.tradeType.toLowerCase() == 'buy'
            ? AppColors.primaryBlue
            : AppColors.errorColor;
        break;
      case 'tradeType':
        text = item.tradeType.isEmpty ? '-' : item.tradeType;
        textColor = item.tradeType.toLowerCase() == 'buy'
            ? AppColors.primaryBlue
            : AppColors.errorColor;
        break;
      case 'orderType':
        text = item.orderType ?? '-';
        break;
      case 'comment':
        text = item.comment ?? '-';
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
        text = item.profitLoss.toStringAsFixed(2);
        textColor = item.profitLoss >= 0
            ? AppColors.primaryBlue
            : AppColors.errorColor;
        break;
      case 'tPrice':
        text = item.tradePrice.toStringAsFixed(2);
        break;
      case 'brk':
        text = item.brokerage.toStringAsFixed(2);
        break;
      case 'rPrice':
        text = item.referencePrice.toStringAsFixed(2);
        break;
      case 'executionTime':
        text = item.executionDateTime ?? '-';
        break;
      case 'deviceId':
        text = item.deviceId ?? '-';
        break;
      case 'ipAddress':
        text = item.ipAddress ?? '-';
        break;
      case 'city':
        return buildCityFromIpCell(
          context,
          backendCity: item.city,
          ip: item.ipAddress,
          resolvedCityByIp: resolvedCityByIp,
          fontSize: 12,
          textColor: textColor,
        );
    }

    return Text(
      text,
      style: GoogleFonts.openSans(fontSize: 12, color: textColor),
      overflow: TextOverflow.ellipsis,
    );
  }
}

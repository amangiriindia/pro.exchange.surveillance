import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget/city_from_ip_table_cell.dart';
import '../../../../core/widget/table/view_data_table.dart';
import '../../domain/entities/trade_comparison_entity.dart';

class TradeComparisonTable extends StatelessWidget {
  final List<TradeComparisonEntity> data;
  final Map<String, String> resolvedCityByIp;
  final VoidCallback? onNearBottom;
  final bool isLoadingMore;

  static const double _triggerThresholdPx = 1600;

  const TradeComparisonTable({
    super.key,
    required this.data,
    this.resolvedCityByIp = const {},
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
      child: ViewDataTable<TradeComparisonEntity>(
        columns: const [
          ViewTableColumn(id: 'u_name', label: 'U. NAME', width: 100),
          ViewTableColumn(id: 'p_user', label: 'P USER', width: 100),
          ViewTableColumn(id: 'exch', label: 'EXCH', width: 80),
          ViewTableColumn(id: 'symbol', label: 'SYMBOL', width: 220),
          ViewTableColumn(id: 'order_d_t', label: 'ORDER D/T', width: 180),
          ViewTableColumn(id: 'b_s', label: 'B/S', width: 180),
          ViewTableColumn(id: 'qty', label: 'QTY', width: 110, isNumeric: true),
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
          ViewTableColumn(
            id: 'execution_d_t',
            label: 'EXECUTION D/T',
            width: 180,
          ),
          ViewTableColumn(id: 'device_id', label: 'DEVICE ID', width: 150),
          ViewTableColumn(id: 'ip_address', label: 'IP ADDRESS', width: 150),
          ViewTableColumn(id: 'city', label: 'CITY', width: 100),
        ],
        data: data,
        idExtractor: (item) =>
            '${item.uName}_${item.orderDateTime}_${item.quantity}_${item.deviceId}',
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
    TradeComparisonEntity item,
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
        text = item.symbol.trim().isEmpty ? '-' : item.symbol;
        textColor = const Color(0xFFE27C00);
        break;
      case 'order_d_t':
        text = item.orderDateTime;
        break;
      case 'b_s':
        text = item.buySell;
        textColor = text.contains('SELL')
            ? AppColors.errorColor
            : AppColors.primaryBlue;
        break;
      case 'qty':
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
      case 'execution_d_t':
        text = item.executionDateTime;
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

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: SizedBox.shrink(),
    );
  }
}

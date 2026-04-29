import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget/city_from_ip_table_cell.dart';
import '../../../../core/widget/table/view_data_table.dart';
import '../../domain/entities/group_trade_entity.dart';

class GroupTradeTable extends StatelessWidget {
  final List<GroupTradeEntity> trades;
  final Map<String, String> resolvedCityByIp;
  final VoidCallback? onNearBottom;
  final bool isLoadingMore;

  const GroupTradeTable({
    super.key,
    required this.trades,
    this.resolvedCityByIp = const {},
    this.onNearBottom,
    this.isLoadingMore = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode(context);
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (onNearBottom != null &&
            notification.metrics.axis == Axis.vertical) {
          final remaining =
              notification.metrics.maxScrollExtent -
              notification.metrics.pixels;
          if (remaining < 2000) onNearBottom!();
        }
        return false;
      },
      child: ViewDataTable<GroupTradeEntity>(
        columns: _buildColumns(),
        data: trades,
        idExtractor: (item) => '${item.id}',
        autoFit: false,
        isDarkMode: isDark,
        rowBackgroundBuilder: (item, index) => index % 2 == 0
            ? AppColors.getTableRowBackground(context)
            : AppColors.getTableAlternateRowBackground(context),
        cellBuilder: (item, col) => _buildCell(context, item, col),
        footerBuilder: isLoadingMore ? (_) => const _LoadMoreFooter() : null,
      ),
    );
  }

  List<ViewTableColumn> _buildColumns() {
    return const [
      ViewTableColumn(id: 'userName', label: 'U. NAME', width: 160),
      ViewTableColumn(id: 'parentUserName', label: 'P USER', width: 160),
      ViewTableColumn(id: 'exchange', label: 'EXCH', width: 120),
      ViewTableColumn(id: 'symbol', label: 'SYMBOL', width: 220),
      ViewTableColumn(id: 'orderDateTime', label: 'ORDER D/T', width: 220),
      ViewTableColumn(id: 'buySell', label: 'B/S', width: 220),
      ViewTableColumn(
        id: 'quantity',
        label: 'QTY',
        width: 140,
        isNumeric: true,
      ),
      ViewTableColumn(id: 'lot', label: 'LOT', width: 120, isNumeric: true),
      ViewTableColumn(id: 'type', label: 'TYPE', width: 140),
      ViewTableColumn(
        id: 'profitLoss',
        label: 'P/L',
        width: 140,
        isNumeric: true,
      ),
      ViewTableColumn(
        id: 'tradePrice',
        label: 'T. PRICE',
        width: 160,
        isNumeric: true,
      ),
      ViewTableColumn(
        id: 'brokerage',
        label: 'BRK',
        width: 140,
        isNumeric: true,
      ),
      ViewTableColumn(
        id: 'referencePrice',
        label: 'R. PRICE',
        width: 140,
        isNumeric: true,
      ),
      ViewTableColumn(
        id: 'executionDateTime',
        label: 'EXECUTION D/T',
        width: 220,
      ),
      ViewTableColumn(id: 'deviceId', label: 'DEVICE ID', width: 450),
      ViewTableColumn(id: 'ipAddress', label: 'IP ADDRESS', width: 180),
      ViewTableColumn(id: 'city', label: 'CITY', width: 140),
    ];
  }

  Widget _buildCell(
    BuildContext context,
    GroupTradeEntity trade,
    ViewTableColumn col,
  ) {
    final isBuy = trade.tradeType.toLowerCase() == 'buy';
    final bsColor = isBuy ? AppColors.buyColor : AppColors.sellColor;

    String text = '';
    Color textColor = const Color(0xFF424242);

    switch (col.id) {
      case 'userName':
        text = _orDash(trade.userName);
        break;
      case 'parentUserName':
        text = _orDash(trade.parentUserName);
        break;
      case 'exchange':
        text = _orDash(trade.exchange);
        break;
      case 'symbol':
        text = _orDash(trade.symbol);
        break;
      case 'orderDateTime':
        text = _orDash(trade.orderDateTime);
        break;
      case 'buySell':
        text = _orDash(trade.buySell);
        textColor = bsColor;
        break;
      case 'quantity':
        text = trade.quantity.toStringAsFixed(2);
        textColor = bsColor;
        break;
      case 'lot':
        text = trade.lot.toStringAsFixed(2);
        break;
      case 'type':
        text = _orDash(trade.type);
        break;
      case 'profitLoss':
        text = trade.profitLoss.toStringAsFixed(2);
        textColor = bsColor;
        break;
      case 'tradePrice':
        text = trade.tradePrice.toStringAsFixed(2);
        textColor = bsColor;
        break;
      case 'brokerage':
        text = trade.brokerage.toStringAsFixed(2);
        textColor = AppColors.sellColor;
        break;
      case 'referencePrice':
        text = trade.referencePrice.toStringAsFixed(2);
        textColor = AppColors.buyColor;
        break;
      case 'executionDateTime':
        text = _orDash(trade.executionDateTime);
        break;
      case 'deviceId':
        text = _orDash(trade.deviceId);
        break;
      case 'ipAddress':
        text = _orDash(trade.ipAddress);
        break;
      case 'city':
        return buildCityFromIpCell(
          context,
          backendCity: trade.city,
          ip: trade.ipAddress,
          resolvedCityByIp: resolvedCityByIp,
        );
    }

    return Text(
      text,
      style: GoogleFonts.openSans(color: textColor, fontSize: 13),
    );
  }

  String _orDash(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? '-' : trimmed;
  }
}

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget/table/view_data_table.dart';
import '../../domain/entities/trade_entity.dart';

class TradeTable extends StatelessWidget {
  final List<TradeEntity> trades;
  final VoidCallback? onNearBottom;
  final bool isLoadingMore;

  // Trigger fetch when within ~50 rows from bottom (≈50 × 40px = 2000px)
  static const double _triggerThresholdPx = 2000;

  const TradeTable({
    super.key,
    required this.trades,
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
      child: ViewDataTable<TradeEntity>(
        columns: _buildColumns(),
        data: trades,
        idExtractor: (item) => '${item.id}',
        autoFit: false,
        isDarkMode: AppColors.isDarkMode(context),
        rowBackgroundBuilder: (item, index) => index % 2 == 0
            ? AppColors.getTableRowBackground(context)
            : AppColors.getTableAlternateRowBackground(context),
        cellBuilder: _buildCell,
        footerBuilder: isLoadingMore ? (_) => const _LoadMoreFooter() : null,
      ),
    );
  }

  List<ViewTableColumn> _buildColumns() {
    return const [
      ViewTableColumn(id: 'uName', label: 'U. NAME', width: 160),
      ViewTableColumn(id: 'pUser', label: 'P USER', width: 160),
      ViewTableColumn(id: 'exchange', label: 'EXCH', width: 120),
      ViewTableColumn(id: 'symbol', label: 'SYMBOL', width: 220),
      ViewTableColumn(id: 'orderDateTime', label: 'ORDER D/T', width: 220),
      ViewTableColumn(id: 'buySell', label: 'B/S', width: 250),
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
        id: 'rPrice',
        label: 'R. PRICE',
        width: 160,
        isNumeric: true,
      ),
      ViewTableColumn(id: 'brk', label: 'BRK', width: 140, isNumeric: true),
      ViewTableColumn(id: 'status', label: 'STATUS', width: 140),
      ViewTableColumn(
        id: 'executionDateTime',
        label: 'EXECUTION D/T',
        width: 220,
      ),
      ViewTableColumn(id: 'ipAddress', label: 'IP ADDRESS', width: 180),
      ViewTableColumn(id: 'deviceId', label: 'DEVICE ID', width: 380),
      ViewTableColumn(id: 'city', label: 'CITY', width: 140),
      ViewTableColumn(id: 'comment', label: 'COMMENT', width: 360),
    ];
  }

  Widget _buildCell(TradeEntity trade, ViewTableColumn col) {
    final isBuy = trade.buySell.toUpperCase().startsWith('BUY');
    final bsColor = isBuy ? AppColors.buyColor : AppColors.sellColor;

    String text = '';
    Color? textColor;
    FontWeight fontWeight = FontWeight.normal;
    Widget? customWidget;

    switch (col.id) {
      case 'uName':
        text = trade.uName;
        break;
      case 'pUser':
        text = trade.pUser;
        break;
      case 'exchange':
        text = trade.exchange;
        break;
      case 'symbol':
        text = trade.symbol.trim().isEmpty ? '-' : trade.symbol;
        break;
      case 'orderDateTime':
        text = trade.orderDateTime;
        break;
      case 'buySell':
        text = trade.buySell;
        textColor = bsColor;
        fontWeight = FontWeight.w600;
        break;
      case 'quantity':
        text = trade.quantity.toStringAsFixed(2);
        textColor = bsColor;
        break;
      case 'lot':
        text = trade.lot.toStringAsFixed(2);
        break;
      case 'type':
        text = trade.type;
        break;
      case 'profitLoss':
        text = trade.profitLoss.toStringAsFixed(2);
        textColor = bsColor;
        break;
      case 'tradePrice':
        text = trade.tradePrice.toStringAsFixed(2);
        break;
      case 'rPrice':
        text = (trade.rPrice ?? 0.0).toStringAsFixed(2);
        break;
      case 'brk':
        text = (trade.brk ?? 0.0).toStringAsFixed(2);
        break;
      case 'status':
        customWidget = _buildStatusChip(trade.status ?? '');
        break;
      case 'executionDateTime':
        text = trade.executionDateTime ?? '-';
        break;
      case 'ipAddress':
        text = trade.ipAddress ?? '-';
        break;
      case 'deviceId':
        text = trade.deviceId ?? '-';
        break;
      case 'city':
        text = trade.city ?? '-';
        break;
      case 'comment':
        text = trade.comment ?? '-';
        textColor = const Color(0xFFE57373);
        break;
    }

    if (customWidget != null) return customWidget;

    final cellText = Text(
      text,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.openSans(
        color: textColor,
        fontSize: 13,
        fontWeight: fontWeight,
      ),
    );

    if (col.id == 'comment') {
      return Tooltip(message: text, child: cellText);
    }

    return cellText;
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color fg;
    switch (status.toLowerCase()) {
      case 'executed':
        bg = const Color(0xFF1B4332);
        fg = const Color(0xFF52B788);
        break;
      case 'pending':
        bg = const Color(0xFF3D2B00);
        fg = const Color(0xFFFFC107);
        break;
      case 'rejected':
        bg = const Color(0xFF3B1111);
        fg = const Color(0xFFEF5350);
        break;
      case 'cancelled':
        bg = const Color(0xFF2A2A2A);
        fg = const Color(0xFF9E9E9E);
        break;
      default:
        bg = const Color(0xFF1A237E);
        fg = const Color(0xFF90CAF9);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.isEmpty
            ? '-'
            : '${status[0].toUpperCase()}${status.substring(1)}',
        style: GoogleFonts.openSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

// ─── Loading footer ────────────────────────────────────────────────────────
class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

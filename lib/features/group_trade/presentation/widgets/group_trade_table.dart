import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget/table/view_data_table.dart';
import '../../domain/entities/group_trade_entity.dart';

class GroupTradeTable extends StatelessWidget {
  final List<GroupTradeEntity> trades;

  const GroupTradeTable({super.key, required this.trades});

  @override
  Widget build(BuildContext context) {
    return ViewDataTable<GroupTradeEntity>(
      columns: _buildColumns(),
      data: trades,
      idExtractor: (item) => item.uName + item.orderDateTime, // Dummy composite ID
      autoFit: false,
      isDarkMode: false,
      rowBackgroundBuilder: (item, index) => index % 2 == 0 ? Colors.white : const Color(0xFFF5F6F8),
      cellBuilder: _buildCell,
    );
  }

  List<ViewTableColumn> _buildColumns() {
    return const [
      ViewTableColumn(id: 'uName', label: 'U. NAME', width: 160),
      ViewTableColumn(id: 'pUser', label: 'P USER', width: 160),
      ViewTableColumn(id: 'exchange', label: 'EXCH', width: 120),
      ViewTableColumn(id: 'symbol', label: 'SYMBOL', width: 200),
      ViewTableColumn(id: 'orderDateTime', label: 'ORDER D/T', width: 220),
      ViewTableColumn(id: 'buySell', label: 'B/S', width: 250),
      ViewTableColumn(id: 'quantity', label: 'QTY', width: 140, isNumeric: true),
      ViewTableColumn(id: 'lot', label: 'LOT', width: 120, isNumeric: true),
      ViewTableColumn(id: 'type', label: 'TYPE', width: 140),
      ViewTableColumn(id: 'profitLoss', label: 'P/L', width: 140, isNumeric: true),
      ViewTableColumn(id: 'tradePrice', label: 'T. PRICE', width: 140, isNumeric: true),
      ViewTableColumn(id: 'brk', label: 'BRK', width: 140, isNumeric: true),
      ViewTableColumn(id: 'rPrice', label: 'R. PRICE', width: 140, isNumeric: true),
      ViewTableColumn(id: 'executionDateTime', label: 'EXECUTION D/T', width: 220),
      ViewTableColumn(id: 'deviceId', label: 'DEVICE ID', width: 450),
      ViewTableColumn(id: 'ipAddress', label: 'IP ADDRESS', width: 180),
      ViewTableColumn(id: 'city', label: 'CITY', width: 140),
    ];
  }

  Widget _buildCell(GroupTradeEntity trade, ViewTableColumn col) {
    Color bsColor = trade.buySell.startsWith('BUY') ? AppColors.buyColor : AppColors.sellColor;
    
    String text = '';
    Color textColor = const Color(0xFF424242);
    FontWeight fontWeight = FontWeight.normal;

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
        text = trade.symbol;
        break;
      case 'orderDateTime':
        text = trade.orderDateTime;
        break;
      case 'buySell':
        text = trade.buySell;
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
        text = trade.type;
        break;
      case 'profitLoss':
        text = trade.profitLoss.toStringAsFixed(2);
        textColor = bsColor;
        break;
      case 'tradePrice':
        text = trade.tradePrice.toStringAsFixed(2);
        textColor = bsColor;
        break;
      case 'brk':
        text = (trade.brk ?? 0.0).toStringAsFixed(2);
        textColor = AppColors.sellColor;
        break;
      case 'rPrice':
        text = (trade.rPrice ?? 0.0).toStringAsFixed(2);
        textColor = AppColors.buyColor;
        break;
      case 'executionDateTime':
        text = trade.executionDateTime ?? '';
        break;
      case 'deviceId':
        text = trade.deviceId ?? '';
        break;
      case 'ipAddress':
        text = trade.ipAddress ?? '';
        break;
      case 'city':
        text = trade.city ?? '';
        break;
    }

    return Text(
      text,
      style: GoogleFonts.openSans(
        color: textColor,
        fontSize: 13,
        fontWeight: fontWeight,
      ),
    );
  }
}

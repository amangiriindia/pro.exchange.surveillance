import 'package:surveillance/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/widget/custom_input_field.dart';
import '../../../../../core/widget/table/view_data_table.dart';

class GroupTradeTab extends StatelessWidget {
  const GroupTradeTab({super.key});

  final List<String> exchanges = const [
    'NSE', 'MCX', 'CE/PE', 'OTHERS', 'COMEX FUTURE', 'COMEX SPOT', 'CRYPTO', 'GIFT', 'FOREX', 'CDS'
  ];

  @override
  Widget build(BuildContext context) {
    return ViewDataTable<String>(
      columns: const [
        ViewTableColumn(id: 'exchange', label: 'EXCHANGE', width: 250),
        ViewTableColumn(id: 'time', label: 'TIME', width: 700),
      ],
      data: exchanges,
      idExtractor: (item) => item,
      autoFit: true,
      isDarkMode: AppColors.isDarkMode(context),
      cellBuilder: _buildCell,
    );
  }

  Widget _buildCell(String exchange, ViewTableColumn col) {
    if (col.id == 'exchange') {
      return Text(
        exchange,
        style: GoogleFonts.openSans(fontSize: 13, color: Colors.black87),
      );
    }
    
    return CustomInputField(
      hintText: 'Time',
      height: 30,
      width: double.infinity,
      borderColor: Colors.grey.shade400,
      fillColor: const Color(0xFFF9F9F9),
      suffixIcon: Icons.access_time,
    );
  }
}

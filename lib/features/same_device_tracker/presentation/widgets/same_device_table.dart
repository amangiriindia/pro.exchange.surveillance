import 'package:surveillance/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widget/table/view_data_table.dart';
import '../../domain/entities/same_device_entity.dart';
import '../../../../core/widget/table_action_button.dart';

class SameDeviceTable extends StatelessWidget {
  final List<SameDeviceEntity> data;
  final ValueChanged<String> onViewSelected;

  const SameDeviceTable({super.key, required this.data, required this.onViewSelected});

  @override
  Widget build(BuildContext context) {
    return ViewDataTable<SameDeviceEntity>(
      columns: const [
        ViewTableColumn(id: 'time', label: 'Time', width: 220),
        ViewTableColumn(id: 'u_name', label: 'U. NAME', width: 600),
        ViewTableColumn(id: 'device_id', label: 'DEVICE ID', width: 300),
        ViewTableColumn(id: 'action', label: 'Action', width: 240),
      ],
      data: data,
      idExtractor: (item) => '${item.deviceId}_${item.uName}_${item.time}',
      autoFit: true,
      isDarkMode: AppColors.isDarkMode(context),
      rowBackgroundBuilder: (item, index) => index % 2 == 0 ? AppColors.getTableRowBackground(context) : AppColors.getTableAlternateRowBackground(context),
      cellBuilder: (item, col) => _buildCell(context, item, col),
    );
  }

  Widget _buildCell(BuildContext context, SameDeviceEntity item, ViewTableColumn col) {
    String text = '';
    Color textColor = const Color(0xFF616161);

    if (col.id == 'action') {
      return TableActionRow(
        onView: () => onViewSelected(item.uName),
      );
    }

    switch (col.id) {
      case 'time': text = item.time; break;
      case 'u_name': text = item.uName; break;
      case 'device_id': text = item.deviceId; break;
    }

    return Text(
      text,
      style: GoogleFonts.openSans(
        color: textColor,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

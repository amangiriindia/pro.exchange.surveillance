import 'package:surveillance/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widget/table/view_data_table.dart';
import '../../domain/entities/same_ip_entity.dart';
import '../../../../core/widget/table_action_button.dart';

class SameIPTable extends StatelessWidget {
  final List<SameIPEntity> data;
  final ValueChanged<SameIPEntity> onViewSelected;
  final VoidCallback? onNearBottom;
  final bool isLoadingMore;

  static const double _triggerThresholdPx = 1600;

  const SameIPTable({
    super.key,
    required this.data,
    required this.onViewSelected,
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
      child: ViewDataTable<SameIPEntity>(
        columns: const [
          ViewTableColumn(id: 'time', label: 'Time', width: 220),
          ViewTableColumn(id: 'u_name', label: 'U. NAME', width: 600),
          ViewTableColumn(id: 'ip_address', label: 'IP ADDRESS', width: 200),
          ViewTableColumn(id: 'action', label: 'Action', width: 120),
        ],
        data: data,
        idExtractor: (item) => item.id.toString(),
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
    SameIPEntity item,
    ViewTableColumn col,
  ) {
    String text = '';
    Color textColor = const Color(0xFF616161);

    if (col.id == 'action') {
      return TableActionRow(onView: () => onViewSelected(item));
    }

    switch (col.id) {
      case 'time':
        try {
          final dt = DateTime.parse(item.time).toLocal();
          text =
              '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
        } catch (_) {
          text = item.time;
        }
        break;
      case 'u_name':
        text = item.uName;
        break;
      case 'ip_address':
        text = item.ipAddress;
        break;
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

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: const SizedBox.shrink(),
    );
  }
}

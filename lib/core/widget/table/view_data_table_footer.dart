import 'package:surveillance/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'view_data_table.dart';
import 'view_table_cell_styles.dart';

class ViewDataTableFooter extends StatelessWidget {
  final List<ViewTableColumn> columns;
  final Map<String, String> values;
  final bool isDarkMode;
  final bool showDividers;
  final Color? textColor;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final TextAlign? textAlign;
  final Map<String, Color>? columnColors;
  const ViewDataTableFooter({
    Key? key,
    required this.columns,
    required this.values,
    this.isDarkMode = false,
    this.showDividers = true,
    this.textColor,
    this.backgroundColor,
    this.borderRadius,
    this.textAlign,
    this.columnColors,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Color dividerColor = isDarkMode
        ? DarkThemeColors.dividerColor
        : AppColors.white;
    Color defaultTextColor = isDarkMode
        ? DarkThemeColors.textColor
        : LightThemeColors.textColor;
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: Row(
        children: columns.asMap().entries.map((entry) {
          final index = entry.key;
          final column = entry.value;
          final value = values[column.id] ?? '';
          final isLast = index == columns.length - 1;
          final isNumeric = column.isNumeric;
          final alignment = isNumeric
              ? Alignment.centerRight
              : Alignment.centerLeft;
          return Container(
            height: 35.h,
            width: column.width,
            alignment: alignment,
            padding: EdgeInsets.only(
              left: 15.w + (alignment == Alignment.centerLeft ? 8.w : 0),
              right:
                  (isLast ? 14.w : 15.w) +
                  (alignment == Alignment.centerRight ? 8.w : 0),
            ),
            decoration: BoxDecoration(
              border: (isLast || !showDividers)
                  ? null
                  : Border(right: BorderSide(color: dividerColor, width: 1.5)),
            ),
            child: Text(
              value,
              style: ViewTableCellStyles.getTextStyle(
                isDark: isDarkMode,
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
                color:
                    columnColors?[column.id] ??
                    (column.isNumeric
                        ? ViewTableCellStyles.getValueColor(
                            double.tryParse(value.replaceAll(',', '')) ?? 0.0,
                            isDark: isDarkMode,
                          )
                        : defaultTextColor),
              ),
              textAlign: column.isNumeric ? TextAlign.end : TextAlign.start,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
      ),
    );
  }
}

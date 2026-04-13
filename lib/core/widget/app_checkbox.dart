import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppCheckbox extends StatelessWidget {
  final String? label;
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final double? size;
  final Color? activeColor;
  final Color? borderColor;
  final Color? labelColor;
  final double? labelFontSize;
  final bool enabled;
  const AppCheckbox({
    super.key,
    this.label,
    required this.value,
    this.onChanged,
    this.size,
    this.activeColor,
    this.borderColor,
    this.labelColor,
    this.labelFontSize,
    this.enabled = true,
  });
  @override
  Widget build(BuildContext context) {
    final checkboxSize = size ?? 22.w;
    final effectiveActiveColor = activeColor ?? AppColors.primaryBlue;
    final effectiveBorderColor = borderColor ?? AppColors.primaryBlue;
    final effectiveLabelColor = labelColor ?? AppColors.primaryBlue;
    final effectiveLabelFontSize = labelFontSize ?? 13.sp;
    return GestureDetector(
      onTap: enabled && onChanged != null ? () => onChanged!(!value) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: checkboxSize,
            height: checkboxSize,
            decoration: BoxDecoration(
              color: value ? effectiveActiveColor : AppColors.transparent,
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(
                color: value ? effectiveActiveColor : effectiveBorderColor,
                width: 2,
              ),
            ),
            child: value
                ? Icon(
                    Icons.check,
                    size: checkboxSize * 0.7,
                    color: AppColors.white,
                  )
                : null,
          ),
          if (label != null) ...[
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                label!,
                style: GoogleFonts.openSans(
                  fontSize: effectiveLabelFontSize,
                  fontWeight: FontWeight.w500,
                  color: enabled
                      ? effectiveLabelColor
                      : effectiveLabelColor.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AppCheckboxGroup extends StatelessWidget {
  final List<String> items;
  final Set<String> selectedItems;
  final ValueChanged<Set<String>>? onChanged;
  final bool showSelectAll;
  final String selectAllLabel;
  final int crossAxisCount;
  final bool enabled;
  const AppCheckboxGroup({
    super.key,
    required this.items,
    required this.selectedItems,
    this.onChanged,
    this.showSelectAll = true,
    this.selectAllLabel = 'Select All',
    this.crossAxisCount = 3,
    this.enabled = true,
  });
  bool get _isAllSelected =>
      items.isNotEmpty && selectedItems.length == items.length;
  void _onSelectAll(bool? value) {
    if (onChanged == null) return;
    if (value == true) {
      onChanged!(Set.from(items));
    } else {
      onChanged!({});
    }
  }

  void _onItemChanged(String item, bool? value) {
    if (onChanged == null) return;
    final newSelection = Set<String>.from(selectedItems);
    if (value == true) {
      newSelection.add(item);
    } else {
      newSelection.remove(item);
    }
    onChanged!(newSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryBlue, width: 1.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showSelectAll) ...[
            AppCheckbox(
              label: selectAllLabel,
              value: _isAllSelected,
              onChanged: enabled ? _onSelectAll : null,
              enabled: enabled,
            ),
            SizedBox(height: 16.h),
          ],
          Wrap(
            spacing: 24.w,
            runSpacing: 12.h,
            children: items.map((item) {
              return SizedBox(
                width:
                    (MediaQuery.of(context).size.width - 100.w) /
                        crossAxisCount -
                    24.w,
                child: AppCheckbox(
                  label: item,
                  value: selectedItems.contains(item),
                  onChanged: enabled
                      ? (value) => _onItemChanged(item, value)
                      : null,
                  enabled: enabled,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

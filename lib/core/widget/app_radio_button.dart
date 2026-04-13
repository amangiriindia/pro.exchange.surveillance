import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppRadioButton<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final String label;
  final ValueChanged<T?>? onChanged;
  final Color? activeColor;
  final Color? labelColor;
  final bool enabled;
  const AppRadioButton({
    super.key,
    required this.value,
    required this.groupValue,
    required this.label,
    this.onChanged,
    this.activeColor,
    this.labelColor,
    this.enabled = true,
  });
  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    final effectiveActiveColor = activeColor ?? AppColors.primaryBlue;
    final effectiveLabelColor = labelColor ?? AppColors.grey;
    return GestureDetector(
      onTap: enabled && onChanged != null ? () => onChanged!(value) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20.w,
            height: 20.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? effectiveActiveColor : AppColors.grey,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10.w,
                      height: 10.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: effectiveActiveColor,
                      ),
                    ),
                  )
                : null,
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: GoogleFonts.openSans(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: enabled
                  ? (isSelected ? effectiveActiveColor : effectiveLabelColor)
                  : effectiveLabelColor.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppRadioGroup<T> extends StatelessWidget {
  final List<RadioOption<T>> options;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final Color? activeColor;
  final Color? labelColor;
  final bool enabled;
  final double? spacing;
  final double? fontSize;
  final double? radioSize;
  const AppRadioGroup({
    super.key,
    required this.options,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.labelColor,
    this.enabled = true,
    this.spacing,
    this.fontSize,
    this.radioSize,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = value == option.value;
        return Padding(
          padding: EdgeInsets.only(
            right: index < options.length - 1 ? (spacing ?? 24.w) : 0,
          ),
          child: _buildRadioOption(context, option, isSelected),
        );
      }).toList(),
    );
  }

  Widget _buildRadioOption(
    BuildContext context,
    RadioOption<T> option,
    bool isSelected,
  ) {
    final effectiveActiveColor = activeColor ?? AppColors.primaryBlue;
    final effectiveLabelColor = labelColor ?? AppColors.grey;
    return GestureDetector(
      onTap: enabled && onChanged != null
          ? () => onChanged!(option.value)
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: radioSize ?? 20.w,
            height: radioSize ?? 20.h,
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
                      width: (radioSize ?? 20.w) / 2,
                      height: (radioSize ?? 20.h) / 2,
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
            option.label,
            style: GoogleFonts.openSans(
              fontSize: fontSize ?? 13.sp,
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

class RadioOption<T> {
  final T value;
  final String label;
  const RadioOption({required this.value, required this.label});
}

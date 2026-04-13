import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppSwitch extends StatelessWidget {
  final String? label;
  final Widget? icon;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? labelColor;
  final bool enabled;
  final double width;
  final double height;
  final double thumbSize;
  const AppSwitch({
    super.key,
    this.label,
    this.icon,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.labelColor,
    this.enabled = true,
    this.width = 44,
    this.height = 24,
    this.thumbSize = 20,
  });
  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? AppColors.primaryBlue;
    final effectiveInactiveColor =
        inactiveColor ?? AppColors.grey.withValues(alpha: 0.3);
    final effectiveLabelColor = labelColor ?? AppColors.textColor(context);
    return GestureDetector(
      onTap: enabled && onChanged != null ? () => onChanged!(!value) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, SizedBox(width: 8.w)],
          if (label != null) ...[
            Flexible(
              child: Text(
                label!,
                style: GoogleFonts.openSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: enabled
                      ? effectiveLabelColor
                      : effectiveLabelColor.withValues(alpha: 0.5),
                ),
              ),
            ),
            SizedBox(width: 12.w),
          ],
          _buildSwitch(effectiveActiveColor, effectiveInactiveColor),
        ],
      ),
    );
  }

  Widget _buildSwitch(Color activeColor, Color inactiveColor) {
    return Container(
      width: width.w,
      height: height.h,
      decoration: BoxDecoration(
        color: value ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(height.r / 2),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 150),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: thumbSize.w,
          height: thumbSize.h,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppSwitchRow extends StatelessWidget {
  final String label;
  final Widget? icon;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;
  const AppSwitchRow({
    super.key,
    required this.label,
    this.icon,
    required this.value,
    this.onChanged,
    this.enabled = true,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled && onChanged != null ? () => onChanged!(!value) : null,
      behavior: HitTestBehavior.translucent,
      child: Row(
        children: [
          if (icon != null) ...[icon!, SizedBox(width: 8.w)],
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.openSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textColor(context),
              ),
            ),
          ),
          IgnorePointer(
            ignoring: true,
            child: AppSwitch(
              value: value,
              onChanged: onChanged,
              enabled: enabled,
            ),
          ),
        ],
      ),
    );
  }
}

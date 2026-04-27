import 'package:surveillance/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final double? fontSize;
  final bool isLoading;
  final IconData? icon;
  final Color? iconColor;
  const CustomActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.fontSize,
    this.isLoading = false,
    this.icon,
    this.iconColor,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 4.r),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: (fontSize ?? 12.sp) + 4,
                color: iconColor ?? textColor ?? AppColors.white,
              ),
              SizedBox(width: 6.w),
            ],
            Text(
              text,
              style: GoogleFonts.openSans(
                fontSize: fontSize ?? 12.sp,
                fontWeight: FontWeight.w600,
                color: textColor ?? AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

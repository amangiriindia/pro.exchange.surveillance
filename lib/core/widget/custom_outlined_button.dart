import 'package:surveillance/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomOutlinedActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final Color? borderColor;
  final Color? textColor;
  final double? borderRadius;
  final double? fontSize;
  final bool isLoading;
  const CustomOutlinedActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.borderColor,
    this.textColor,
    this.borderRadius,
    this.fontSize,
    this.isLoading = false,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: borderColor ?? AppColors.primaryBlue,
            width: 1.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 4.r),
          ),
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
        ),
        child: Text(
          text,
          style: GoogleFonts.openSans(
            fontSize: fontSize ?? 12.sp,
            fontWeight: FontWeight.w600,
            color: textColor ?? AppColors.primaryBlue,
          ),
        ),
      ),
    );
  }
}

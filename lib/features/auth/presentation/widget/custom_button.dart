import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final Color? disabledBackgroundColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final double? fontSize;
  final FontWeight? fontWeight;
  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.disabledBackgroundColor,
    this.width,
    this.height,
    this.borderRadius,
    this.fontSize,
    this.fontWeight,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? AppColors.primaryBlue;
    final effectiveTextColor = textColor ?? AppColors.white;
    final effectiveBorderColor = borderColor ?? AppColors.primaryBlue;
    final effectiveDisabledColor =
        disabledBackgroundColor ?? AppColors.greyBorder;
    return SizedBox(
      width: width ?? 500,
      height: height ?? 45,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          disabledBackgroundColor: effectiveDisabledColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? AppDimensions.borderRadiusL,
            ),
            side: BorderSide(
              color: effectiveBorderColor,
              width: AppDimensions.borderWidthThin,
            ),
          ),
          elevation: 0,
          padding: EdgeInsets.all(AppDimensions.paddingM),
        ),
        child: isLoading
            ? SizedBox(
                width: AppDimensions.iconSizeM,
                height: AppDimensions.iconSizeM,
                child: CircularProgressIndicator(
                  color: effectiveTextColor,
                  strokeWidth: AppDimensions.borderWidthMedium,
                ),
              )
            : Text(
                text,
                style: GoogleFonts.openSans(
                  fontSize: fontSize ?? AppDimensions.fontSizeL,
                  fontWeight: fontWeight ?? FontWeight.w600,
                  color: effectiveTextColor,
                  letterSpacing: 0.1,
                  height: 1.0,
                ),
              ),
      ),
    );
  }
}

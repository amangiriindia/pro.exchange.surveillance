import 'package:surveillance/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'svg_icon.dart';

class CustomInputField extends StatelessWidget {
  final String hintText;
  final String? svgIconPath;
  final IconData? suffixIcon;
  final TextEditingController? controller;
  final bool obscureText;
  final VoidCallback? onSuffixIconPressed;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final double? height;
  final double? width;
  final String? prefixSvgPath;
  final bool showErrorBorder;
  final bool readOnly;
  final Color? borderColor;
  final Color? fillColor;
  final Color? textColor;
  final FocusNode? focusNode;
  final bool autofocus;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final VoidCallback? onTap;
  const CustomInputField({
    Key? key,
    required this.hintText,
    this.svgIconPath,
    this.suffixIcon,
    this.controller,
    this.obscureText = false,
    this.onSuffixIconPressed,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.height,
    this.width,
    this.prefixSvgPath,
    this.showErrorBorder = true,
    this.readOnly = false,
    this.borderColor,
    this.textColor,
    this.fillColor,
    this.focusNode,
    this.autofocus = false,
    this.onFieldSubmitted,
    this.textInputAction,
    this.onTap,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 250.w,
      height: height,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        maxLines: 1,
        enabled: enabled,
        readOnly: readOnly,
        style: GoogleFonts.openSans(
          fontSize: 14.sp, // improved legibility
          fontWeight: FontWeight.w600,
          height: 1.0,
          letterSpacing: 0.15,
          color: textColor ?? AppColors.primaryBlue,
        ),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          isDense: height != null ? true : false,
          filled: true,
          fillColor: fillColor ?? AppColors.white,
          hintText: hintText,
          hintStyle: GoogleFonts.openSans(
            fontSize: 14.sp, // improved legibility
            fontWeight: FontWeight.w600,
            height: 1.0,
            letterSpacing: 0.15,
            color: textColor?.withOpacity(0.6) ?? AppColors.primaryBlue.withOpacity(0.6),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 0,
            vertical: ((height ?? 35.h) - 10.sp) / 2,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: prefixSvgPath != null ? 35.w : 10.w,
            minHeight: height ?? 35.h,
            maxHeight: height ?? 35.h,
          ),
          suffixIconConstraints: BoxConstraints(
            minWidth: (suffixIcon != null || svgIconPath != null) ? 35.w : 10.w,
            minHeight: height ?? 35.h,
            maxHeight: height ?? 35.h,
          ),
          border: _buildBorder(),
          enabledBorder: _buildBorder(),
          focusedBorder: _buildBorder(),
          errorBorder: showErrorBorder
              ? _buildBorder(isError: true)
              : _buildBorder(),
          focusedErrorBorder: showErrorBorder
              ? _buildBorder(isError: true)
              : _buildBorder(),
          disabledBorder: _buildBorder(isDisabled: true),
          prefixIcon: prefixSvgPath != null
              ? _buildPrefixIcon()
              : SizedBox(width: 10.w),
          suffixIcon: (suffixIcon != null || svgIconPath != null)
              ? _buildSuffixIcon()
              : SizedBox(width: 10.w),
          errorStyle: showErrorBorder
              ? null
              : GoogleFonts.openSans(
                  color: AppColors.errorColor,
                  fontSize: 12.sp,
                ),
        ),
        validator: validator,
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        onTap: onTap,
      ),
    );
  }

  Widget? _buildPrefixIcon() {
    if (prefixSvgPath != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: SvgIcon(assetPath: prefixSvgPath!, isActive: true, size: 22.sp),
      );
    }
    return null;
  }

  Widget? _buildSuffixIcon() {
    if (suffixIcon != null) {
      return IconButton(
        icon: Icon(suffixIcon, size: 20.sp, color: textColor?.withOpacity(0.8) ?? AppColors.primaryBlue),
        splashRadius: 20.sp,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: onSuffixIconPressed,
      );
    }
    if (svgIconPath != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: SvgIcon(assetPath: svgIconPath!, isActive: true, size: 22.sp),
      );
    }
    return null;
  }

  OutlineInputBorder _buildBorder({
    bool isError = false,
    bool isDisabled = false,
  }) {
    Color finalBorderColor;
    if (isError) {
      finalBorderColor = AppColors.errorColor;
    } else if (isDisabled) {
      finalBorderColor = AppColors.greyBorder;
    } else {
      finalBorderColor = borderColor ?? AppColors.primaryBlue;
    }
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: BorderSide(color: finalBorderColor, width: 1.4),
    );
  }
}

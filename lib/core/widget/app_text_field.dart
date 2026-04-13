import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? helperText;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final Widget? suffixIcon;
  final bool enabled;
  final Color? borderColor;
  final Color? textColor;
  final Color? hintColor;
  final double? height;
  final TextInputType? keyboardType;
  final int maxLines;
  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.helperText,
    this.initialValue,
    this.onChanged,
    this.obscureText = false,
    this.suffixIcon,
    this.enabled = true,
    this.borderColor,
    this.textColor,
    this.hintColor,
    this.height,
    this.keyboardType,
    this.maxLines = 1,
  });
  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? AppColors.primaryBlue;
    final effectiveHintColor = hintColor ?? AppColors.primaryBlue;
    final effectiveHeight = height ?? 48.h;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: maxLines > 1 ? null : effectiveHeight,
          constraints: maxLines > 1
              ? BoxConstraints(minHeight: effectiveHeight)
              : null,
          decoration: BoxDecoration(
            border: Border.all(color: effectiveBorderColor, width: 1.5),
            borderRadius: BorderRadius.circular(8.r),
            color: enabled ? null : AppColors.grey.withValues(alpha: 0.1),
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            obscureText: obscureText,
            onChanged: onChanged,
            keyboardType: keyboardType,
            maxLines: obscureText ? 1 : maxLines,
            style: GoogleFonts.openSans(
              fontSize: 14.sp,
              color: textColor ?? AppColors.textColor(context),
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.openSans(
                fontSize: 14.sp,
                color: effectiveHintColor,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: maxLines > 1 ? 12.h : 0,
              ),
              border: InputBorder.none,
              suffixIcon: suffixIcon,
            ),
          ),
        ),
        if (helperText != null) ...[
          SizedBox(height: 8.h),
          Text(
            helperText!,
            style: GoogleFonts.openSans(
              fontSize: 12.sp,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ],
    );
  }
}

class AppPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  const AppPasswordField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.enabled = true,
  });
  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _isVisible = false;
  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      hintText: widget.hintText,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      obscureText: !_isVisible,
      suffixIcon: IconButton(
        icon: Icon(
          _isVisible ? Icons.visibility : Icons.visibility_off,
          size: 20.sp,
          color: AppColors.primaryBlue,
        ),
        onPressed: () => setState(() => _isVisible = !_isVisible),
      ),
    );
  }
}

class AppLabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final String? helperText;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final Color? labelColor;
  const AppLabeledTextField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.helperText,
    this.onChanged,
    this.enabled = true,
    this.labelColor,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.openSans(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: labelColor ?? AppColors.white,
          ),
        ),
        SizedBox(height: 5.h),
        AppTextField(
          controller: controller,
          hintText: hintText ?? label,
          helperText: helperText,
          onChanged: onChanged,
          enabled: enabled,
        ),
      ],
    );
  }
}

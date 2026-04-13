import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';

class SuccessDialog {
  static void show({
    required BuildContext context,
    required String title,
    required String subtitle,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _SuccessNotification(
        title: title,
        subtitle: subtitle,
        onClose: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
    Timer(const Duration(seconds: 2), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }
}

class _SuccessNotification extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onClose;
  const _SuccessNotification({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.onClose,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    const statusColor = Color(0xFF0052FF);
    return Positioned(
      right: 16.w,
      bottom: 12.h,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 260.w,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: statusColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: statusColor,
                offset: Offset(3.w, 3.h),
                blurRadius: 0,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 11.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

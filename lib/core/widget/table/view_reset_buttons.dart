import 'package:surveillance/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../custom_action_button.dart';
import '../custom_outlined_button.dart';

class ViewResetButtons extends StatelessWidget {
  final VoidCallback? onView;
  final VoidCallback? onReset;
  final bool isLoading;
  final String viewText;
  final String resetText;
  final bool showReset;
  const ViewResetButtons({
    Key? key,
    this.onView,
    this.onReset,
    this.isLoading = false,
    this.viewText = 'View',
    this.resetText = 'Reset',
    this.showReset = true,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showReset) ...[_buildResetButton(), SizedBox(width: 8.w)],
        _buildViewButton(),
      ],
    );
  }

  Widget _buildResetButton() {
    return CustomOutlinedActionButton(
      text: resetText,
      onPressed: onReset ?? () {},
      width: 90.w,
      height: 35.h,
      isLoading: isLoading,
    );
  }

  Widget _buildViewButton() {
    return CustomActionButton(
      text: viewText,
      onPressed: onView ?? () {},
      width: 90.w,
      height: 35.h,
      isLoading: isLoading,
    );
  }
}

class RecordCountWidget extends StatelessWidget {
  final int count;
  final String label;
  const RecordCountWidget({
    Key? key,
    required this.count,
    this.label = 'RECORD',
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Text(
      '$label : $count',
      style: GoogleFonts.openSans(
        fontSize: 10.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryBlue,
      ),
    );
  }
}

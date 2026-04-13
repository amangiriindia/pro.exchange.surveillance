import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;
  final Color? activeColor;
  final Color? completedColor;
  final Color? inactiveColor;
  final Color? completedLineColor;
  final Color? incompleteLineColor;
  const AppStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitles,
    this.activeColor,
    this.completedColor,
    this.inactiveColor,
    this.completedLineColor,
    this.incompleteLineColor,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps * 2 - 1, (index) {
          if (index.isEven) {
            final stepIndex = index ~/ 2;
            return _buildStepItem(stepIndex);
          } else {
            final beforeStepIndex = index ~/ 2;
            return _buildConnectorLine(beforeStepIndex);
          }
        }),
      ),
    );
  }

  Widget _buildStepItem(int stepIndex) {
    final isActive = stepIndex == currentStep;
    final isCompleted = stepIndex < currentStep;
    final effectiveActiveColor = activeColor ?? AppColors.primaryBlue;
    final effectiveCompletedColor = completedColor ?? AppColors.primaryBlue;
    final effectiveInactiveColor = inactiveColor ?? AppColors.primaryBlue;
    if (isActive) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: effectiveActiveColor,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          stepTitles[stepIndex],
          style: GoogleFonts.openSans(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      );
    } else {
      return Container(
        width: 18.w,
        height: 18.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCompleted ? effectiveCompletedColor : effectiveInactiveColor,
        ),
      );
    }
  }

  Widget _buildConnectorLine(int beforeStepIndex) {
    final isCompleted = beforeStepIndex < currentStep;
    final effectiveCompletedColor = completedLineColor ?? AppColors.primaryBlue;
    final effectiveIncompleteColor =
        incompleteLineColor ?? AppColors.grey.withValues(alpha: 0.3);
    return Container(
      width: 30.w,
      height: 2.h,
      color: isCompleted ? effectiveCompletedColor : effectiveIncompleteColor,
    );
  }
}

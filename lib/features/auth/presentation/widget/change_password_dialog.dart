import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widget/common_dilog_box.dart';
import '../../../../core/widget/custom_action_button.dart';
import '../../../../core/widget/custom_input_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ChangePasswordDialog {
  static void show({required BuildContext context, VoidCallback? onUpdated}) {
    CommonDialog.show(
      context: context,
      title: 'Change Password',
      width: 520.w,
      backgroundColor: AppColors.white,
      showButtons: false,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      contentBuilder: (dialogContext, closeDialog) =>
          _ChangePasswordDialogContent(
            parentContext: context,
            closeDialog: closeDialog,
            onUpdated: onUpdated,
          ),
    );
  }
}

class _ChangePasswordDialogContent extends StatefulWidget {
  final BuildContext parentContext;
  final VoidCallback closeDialog;
  final VoidCallback? onUpdated;

  const _ChangePasswordDialogContent({
    required this.parentContext,
    required this.closeDialog,
    this.onUpdated,
  });

  @override
  State<_ChangePasswordDialogContent> createState() =>
      _ChangePasswordDialogContentState();
}

class _ChangePasswordDialogContentState
    extends State<_ChangePasswordDialogContent> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(widget.parentContext).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  Future<void> _handleUpdate() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage('Please fill all password fields');
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage('New password and confirm password must match');
      return;
    }

    final authBloc = widget.parentContext.read<AuthBloc>();
    final authState = authBloc.state;

    if (authState is! AuthAuthenticated) {
      _showMessage('Please login again');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    authBloc.add(
      ChangePasswordEvent(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );

    final nextState = await authBloc.stream.firstWhere(
      (state) =>
          state is AuthUnauthenticated ||
          (state is AuthAuthenticated && !state.isProcessing),
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (nextState is AuthUnauthenticated) {
      widget.closeDialog();
      final message =
          nextState.message ??
          'Password changed successfully, please login again';
      _showMessage(message);
      Navigator.of(
        widget.parentContext,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      return;
    }

    if (nextState is AuthAuthenticated && nextState.errorMessage != null) {
      _showMessage(nextState.errorMessage!);
      return;
    }

    if (widget.onUpdated != null) {
      widget.onUpdated!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomInputField(
          hintText: 'Current Password',
          controller: _currentPasswordController,
          obscureText: _obscureCurrentPassword,
          suffixIcon: _obscureCurrentPassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          onSuffixIconPressed: () {
            setState(() {
              _obscureCurrentPassword = !_obscureCurrentPassword;
            });
          },
          width: double.infinity,
          height: 52.h,
          borderColor: AppColors.primaryBlue,
        ),
        SizedBox(height: 16.h),
        CustomInputField(
          hintText: 'New Password',
          controller: _newPasswordController,
          obscureText: _obscureNewPassword,
          suffixIcon: _obscureNewPassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          onSuffixIconPressed: () {
            setState(() {
              _obscureNewPassword = !_obscureNewPassword;
            });
          },
          width: double.infinity,
          height: 52.h,
          borderColor: AppColors.primaryBlue,
        ),
        SizedBox(height: 16.h),
        CustomInputField(
          hintText: 'Confirm Password',
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          suffixIcon: _obscureConfirmPassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          onSuffixIconPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
          width: double.infinity,
          height: 52.h,
          borderColor: AppColors.primaryBlue,
        ),
        SizedBox(height: 24.h),
        CustomActionButton(
          text: 'Update',
          onPressed: _handleUpdate,
          isLoading: _isSubmitting,
          width: double.infinity,
          height: 52.h,
          backgroundColor: AppColors.primaryBlue,
          borderRadius: 16.r,
          fontSize: 16.sp,
        ),
      ],
    );
  }
}

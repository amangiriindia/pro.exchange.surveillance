import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import 'change_password_dialog.dart';
import '../../../../core/widget/common_dilog_box.dart';
import '../../../../core/widget/custom_action_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ProfileDialog {
  static void show({
    required BuildContext context,
    required String username,
    VoidCallback? onChangePassword,
  }) {
    CommonDialog.show(
      context: context,
      title: 'Profile',
      width: 420.w,
      backgroundColor: AppColors.white,
      showButtons: false,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      contentBuilder: (dialogContext, closeDialog) => _ProfileDialogContent(
        parentContext: context,
        closeDialog: closeDialog,
        username: username,
        onChangePassword: () {
          closeDialog();
          if (onChangePassword != null) {
            onChangePassword();
            return;
          }
          ChangePasswordDialog.show(context: context);
        },
      ),
    );
  }
}

class _ProfileDialogContent extends StatefulWidget {
  final BuildContext parentContext;
  final VoidCallback closeDialog;
  final String username;
  final VoidCallback onChangePassword;

  const _ProfileDialogContent({
    required this.parentContext,
    required this.closeDialog,
    required this.username,
    required this.onChangePassword,
  });

  @override
  State<_ProfileDialogContent> createState() => _ProfileDialogContentState();
}

class _ProfileDialogContentState extends State<_ProfileDialogContent> {
  bool _isSubmitting = false;
  bool _requestedProfile = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requestedProfile) return;
    _requestedProfile = true;

    final authState = widget.parentContext.read<AuthBloc>().state;
    if (authState is AuthAuthenticated &&
        authState.profile == null &&
        !authState.isProfileLoading) {
      widget.parentContext.read<AuthBloc>().add(const FetchProfileEvent());
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(widget.parentContext).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return '-';
    return DateFormat('dd MMM, hh:mm a').format(value);
  }

  Future<void> _handleLogout() async {
    final authBloc = widget.parentContext.read<AuthBloc>();
    final authState = authBloc.state;

    if (authState is! AuthAuthenticated) {
      widget.closeDialog();
      Navigator.of(
        widget.parentContext,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    authBloc.add(const LogoutEvent());

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
      final message = nextState.message ?? 'Logout successful';
      _showMessage(message);
      Navigator.of(
        widget.parentContext,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      return;
    }

    if (nextState is AuthAuthenticated && nextState.errorMessage != null) {
      _showMessage(nextState.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = widget.parentContext.watch<AuthBloc>().state;
    final profile = authState is AuthAuthenticated ? authState.profile : null;
    final profileError = authState is AuthAuthenticated
        ? authState.profileErrorMessage
        : null;
    final isProfileLoading =
        authState is AuthAuthenticated && authState.isProfileLoading;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.primaryBgColor,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile Details',
                style: GoogleFonts.openSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlue,
                ),
              ),
              SizedBox(height: 12.h),
              _ProfileDetailRow(
                label: 'Username',
                value: profile?.username ?? widget.username,
              ),
              SizedBox(height: 8.h),
              _ProfileDetailRow(
                label: 'User ID',
                value: profile?.id.isNotEmpty == true ? profile!.id : '-',
              ),
              SizedBox(height: 8.h),
              _ProfileDetailRow(
                label: 'Status',
                value: profile == null
                    ? (isProfileLoading ? 'Loading...' : '-')
                    : (profile.isActive ? 'Active' : 'Inactive'),
              ),
              SizedBox(height: 8.h),
              _ProfileDetailRow(
                label: 'Created At',
                value: _formatDateTime(profile?.createdAt),
              ),
              SizedBox(height: 8.h),
              _ProfileDetailRow(
                label: 'Token Generated',
                value: _formatDateTime(profile?.tokenGeneratedAt),
              ),
              if (profileError != null && profileError.isNotEmpty) ...[
                SizedBox(height: 10.h),
                Text(
                  profileError,
                  style: GoogleFonts.openSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.errorColor,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            Expanded(
              child: CustomActionButton(
                text: 'Change Password',
                onPressed: widget.onChangePassword,
                height: 40.h,
                backgroundColor: AppColors.primaryBlue,
                borderRadius: 26.r,
                fontSize: 12.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: CustomActionButton(
                text: 'Logout',
                onPressed: _handleLogout,
                isLoading: _isSubmitting,
                height: 40.h,
                backgroundColor: AppColors.red,
                borderRadius: 26.r,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 118.w,
          child: Text(
            label,
            style: GoogleFonts.openSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryTextColor,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.openSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
      ],
    );
  }
}

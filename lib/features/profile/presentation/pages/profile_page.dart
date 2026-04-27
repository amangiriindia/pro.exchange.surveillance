import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widget/page_header.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationTap;

  const ProfilePage({super.key, this.onSettingsTap, this.onNotificationTap});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(child: _buildUserDetailsSection()),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return PageHeader(
      title: 'User Profile',
      subtitle: 'Manage your account details and security settings',
      onRefresh: () {},
      onSettingsTap: widget.onSettingsTap,
      onNotificationTap: widget.onNotificationTap,
    );
  }

  Widget _buildUserDetailsSection() {
    final authState = context.watch<AuthBloc>().state;
    final name = authState is AuthAuthenticated
        ? (authState.user.name.isNotEmpty
              ? authState.user.name
              : authState.user.username)
        : 'N/A';
    final role = authState is AuthAuthenticated ? authState.user.role : 'N/A';
    final email = authState is AuthAuthenticated
        ? (authState.user.email.isNotEmpty
              ? authState.user.email
              : authState.user.username)
        : 'N/A';
    final username = authState is AuthAuthenticated
        ? authState.user.username
        : 'N/A';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Details',
            style: GoogleFonts.openSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Name', name),
          const Divider(height: 32),
          _buildInfoRow('Role', role),
          const Divider(height: 32),
          _buildInfoRow('Username', username),
          const Divider(height: 32),
          _buildInfoRow('Email', email),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: GoogleFonts.openSans(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.openSans(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget/custom_input_field.dart';
import '../../../../core/widget/custom_action_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildUserDetailsSection(context),
            const SizedBox(height: 32),
            _buildChangePasswordSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User Profile',
          style: GoogleFonts.openSans(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage your account details and security settings',
          style: GoogleFonts.openSans(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildUserDetailsSection(BuildContext context) {
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
            style: GoogleFonts.openSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Name', 'DEMO 12'),
          const Divider(height: 32),
          _buildInfoRow('Role', 'Administrator'),
          const Divider(height: 32),
          _buildInfoRow('Username', 'demo_admin_12'),
          const Divider(height: 32),
          _buildInfoRow('Email', 'demo12@surveillance.com'),
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
            style: GoogleFonts.openSans(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.openSans(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildChangePasswordSection(BuildContext context) {
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
            'Change Password',
            style: GoogleFonts.openSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 400,
            child: Column(
              children: [
                CustomInputField(
                  hintText: 'Current Password',
                  controller: _currentPasswordController,
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                CustomInputField(
                  hintText: 'New Password',
                  controller: _newPasswordController,
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                CustomInputField(
                  hintText: 'Confirm New Password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                ),
                const SizedBox(height: 32),
                CustomActionButton(
                  text: 'Update Password',
                  width: 200,
                  height: 45,
                  onPressed: () {
                    // Logic to update password would go here
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password updated successfully (Mock)')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

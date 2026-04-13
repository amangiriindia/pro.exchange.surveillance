import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import 'package:google_fonts/google_fonts.dart';

class SideMenuItem {
  final String title;
  final IconData? iconData;
  final String? iconAsset;
  
  SideMenuItem({required this.title, this.iconData, this.iconAsset});
}

class SideMenu extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onProfileTap;

  SideMenu({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.selectedIndex,
    required this.onSelect,
    required this.onProfileTap,
  });

  // Dummy icons to match screenshot visually
  final List<SideMenuItem> items = [
    SideMenuItem(title: 'Trade', iconData: Icons.insert_chart_outlined),
    SideMenuItem(title: 'Group Trade', iconData: Icons.group_outlined),
    SideMenuItem(title: 'Bulk Order Tracker', iconData: Icons.bar_chart_outlined),
    SideMenuItem(title: 'Profit % Cross', iconData: Icons.trending_up_outlined),
    SideMenuItem(title: 'Jobber Tracker', iconData: Icons.person_search_outlined),
    SideMenuItem(title: 'BTST/STBT', iconData: Icons.history_toggle_off_outlined),
    SideMenuItem(title: 'Same IP Tracker', iconData: Icons.dns_outlined),
    SideMenuItem(title: 'Same device Tracker', iconData: Icons.devices_outlined),
    SideMenuItem(title: 'Trade comparison', iconData: Icons.compare_arrows_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isExpanded ? 240 : 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor(context),
            AppColors.primaryColor(context).withBlue((AppColors.primaryColor(context).blue * 0.7).round()).withGreen((AppColors.primaryColor(context).green * 0.7).round()).withRed((AppColors.primaryColor(context).red * 0.7).round()),
          ],
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildMenuItem(context, index);
              },
            ),
          ),
          _buildUserProfile(context),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Image.asset(AppImages.appLogo, width: 32, height: 32),
            if (isExpanded) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Surveillance',
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.arrow_circle_left_outlined, color: Colors.white54, size: 20),
            ] else ...[
              const Spacer(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, int index) {
    final item = items[index];
    final isSelected = selectedIndex == index;
    final bgColor = isSelected ? AppColors.secondaryColor(context).withOpacity(0.9) : Colors.transparent;
    final textColor = isSelected ? Colors.white : Colors.white70;

    return InkWell(
      onTap: () => onSelect(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(item.iconData, color: textColor, size: 24),
            if (isExpanded) ...[
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item.title,
                  style: GoogleFonts.openSans(color: textColor, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    return InkWell(
      onTap: onProfileTap,
      child: Container(
      padding: EdgeInsets.symmetric(
        vertical: 12, 
        horizontal: isExpanded ? 16 : 0,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isExpanded ? Colors.white.withOpacity(0.05) : Colors.transparent, 
        borderRadius: BorderRadius.circular(12),
        border: isExpanded ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
      ),
      child: Row(
        mainAxisAlignment: isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.secondaryColor(context),
            child: const Icon(Icons.person, size: 20, color: Colors.white),
          ),
          if (isExpanded) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DEMO 12',
                    style: GoogleFonts.openSans(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Administrator',
                    style: GoogleFonts.openSans(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.normal),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Colors.white70, size: 20),
            if (isExpanded) ...[
              const SizedBox(width: 8),
              Text(
                'Log Out',
                style: GoogleFonts.openSans(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:surveillance/features/dashboard/presentation/widgets/side_menu.dart';

import '../../../trade/presentation/pages/trade_page.dart';
import '../../../trade/presentation/pages/setting_page.dart';
import '../../../group_trade/presentation/pages/group_trade_page.dart';
import '../../../bulk_order/presentation/pages/bulk_order_tracker_page.dart';
import '../../../profit_cross/presentation/pages/profit_cross_page.dart';
import '../../../jobber_tracker/presentation/pages/jobber_tracker_page.dart';
import '../../../btst/presentation/pages/btst_page.dart';
import '../../../same_ip_tracker/presentation/pages/same_ip_page.dart';
import '../../../same_device_tracker/presentation/pages/same_device_page.dart';
import '../../../trade_comparison/presentation/pages/trade_comparison_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isMenuExpanded = true;
  int selectedIndex = 0;
  bool showSettings = false;
  bool showProfile = false;

  void toggleMenu() {
    setState(() {
      isMenuExpanded = !isMenuExpanded;
    });
  }

  void onMenuSelect(int index) {
    setState(() {
      selectedIndex = index;
      showSettings = false;
      showProfile = false;
    });
  }

  Widget _buildContentArea() {
    if (showProfile) {
      return const ProfilePage();
    }
    if (showSettings) {
      return const SettingPage();
    }
    if (selectedIndex == 0) {
      return TradePage(onSettingsTap: () {
        setState(() {
          showSettings = true;
        });
      });
    }
    if (selectedIndex == 1) {
      return GroupTradePage(onSettingsTap: () {
        setState(() {
          showSettings = true;
        });
      });
    }
    if (selectedIndex == 2) {
      return BulkOrderTrackerPage(onSettingsTap: () {
        setState(() {
          showSettings = true;
        });
      });
    }
    if (selectedIndex == 3) {
      return ProfitCrossPage(onSettingsTap: () {
        setState(() {
          showSettings = true;
        });
      });
    }
    if (selectedIndex == 4) {
      return JobberTrackerPage(onSettingsTap: () {
        setState(() {
          showSettings = true;
        });
      });
    }
    if (selectedIndex == 5) {
      return BTSTPage(onSettingsTap: () {
        setState(() {
          showSettings = true;
        });
      });
    }
    if (selectedIndex == 6) {
      return SameIPPage(onSettingsTap: () {
        setState(() {
          showSettings = true;
        });
      });
    }
    if (selectedIndex == 7) {
      return SameDevicePage(onSettingsTap: () {
        setState(() {
          showSettings = true;
        });
      });
    }
    if (selectedIndex == 8) {
      return TradeComparisonPage(onSettingsTap: () {
        setState(() {
          showSettings = true;
        });
      });
    }
    return const Center(child: Text('Content coming soon'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.isDarkMode(context) ? AppColors.backgroundColor(context) : Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.pageBackgroundGradient(context),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SideMenu(
              isExpanded: isMenuExpanded,
              onToggle: toggleMenu,
              selectedIndex: selectedIndex,
              onSelect: onMenuSelect,
              onProfileTap: () {
                setState(() {
                  showProfile = true;
                  showSettings = false;
                });
              },
            ),
            Expanded(
              child: _buildContentArea(),
            ),
          ],
        ),
      ),
    );
  }
}

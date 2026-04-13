import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widget/app_tab_bar.dart';
import '../widgets/setting_tabs/group_trade_tab.dart';
import '../widgets/setting_tabs/bulk_order_tab.dart';
import '../widgets/setting_tabs/profit_cross_tab.dart';
import '../widgets/setting_tabs/jobber_tracker_tab.dart';
import '../../../../core/widget/custom_action_button.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  int _activeTabIndex = 0;

  final List<String> _tabs = [
    'Group Trade',
    'Bulk Order Tracker',
    'Profit % Cross',
    'Jobber Tracker',
    'BTST/STBT',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildTabBar(),
          const SizedBox(height: 24),
          Expanded(
            child: _buildSelectedTabContent(),
          ),
          const SizedBox(height: 16),
          CustomActionButton(
            text: 'Submit',
            onPressed: () {},
            width: 200,
            height: 48,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Setting',
          style: GoogleFonts.openSans(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Monitor users who exceeded configured trade quantity limits',
          style: GoogleFonts.openSans(
            fontSize: 14,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return AppTabBar(
      tabs: _tabs,
      activeTab: _activeTabIndex,
      onTabChanged: (index) {
        setState(() {
          _activeTabIndex = index;
        });
      },
      style: AppTabBarStyle.pill,
      autoFocus: false,
    );
  }

  Widget _buildSelectedTabContent() {
    switch (_activeTabIndex) {
      case 0:
        return const GroupTradeTab();
      case 1:
        return const BulkOrderTab();
      case 2:
        return const ProfitCrossTab();
      case 3:
        return const JobberTrackerTab();
      case 4:
        return const GroupTradeTab(); // BTST/STBT shares the identical UI structure
      default:
        return const SizedBox();
    }
  }
}

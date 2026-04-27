import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget/app_tab_bar.dart';
import '../../../../core/widget/page_header.dart';
import '../../../../core/widget/gradient_submit_button.dart';
import '../widgets/setting_tabs/group_trade_tab.dart';
import '../widgets/setting_tabs/bulk_order_tab.dart';
import '../widgets/setting_tabs/profit_cross_tab.dart';
import '../widgets/setting_tabs/jobber_tracker_tab.dart';
import '../widgets/setting_tabs/btst_stbt_tab.dart';

class SettingPage extends StatefulWidget {
  final VoidCallback? onNotificationTap;
  const SettingPage({super.key, this.onNotificationTap});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  int _activeTabIndex = 0;
  final GlobalKey<GroupTradeTabState> _groupTradeTabKey =
      GlobalKey<GroupTradeTabState>();
  final GlobalKey<BulkOrderTabState> _bulkOrderTabKey =
      GlobalKey<BulkOrderTabState>();
  final GlobalKey<ProfitCrossTabState> _profitCrossTabKey =
      GlobalKey<ProfitCrossTabState>();
  final GlobalKey<JobberTrackerTabState> _jobberTrackerTabKey =
      GlobalKey<JobberTrackerTabState>();
  final GlobalKey<BtstStbtTabState> _btstStbtTabKey =
      GlobalKey<BtstStbtTabState>();

  final List<String> _tabs = [
    'Group Trade',
    'Bulk Order Tracker',
    'Profit % Cross',
    'Jobber Tracker',
    'BTST/STBT',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode(context);

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Modern Branded Header ──
          PageHeader(
            title: 'Setting',
            subtitle:
                'Monitor users who exceeded configured trade quantity limits',
            onRefresh: () {},
            onNotificationTap: widget.onNotificationTap,
          ),

          const SizedBox(height: 16),

          // ── Compact Tab Bar ──
          _buildTabBar(isDark),

          const SizedBox(height: 16),

          // ── Tab Content ──
          Expanded(child: _buildSelectedTabContent()),

          const SizedBox(height: 20),

          // ── Modern Action Button ──
          GradientSubmitButton(
            text: 'Submit Preferences',
            onPressed: _handleSubmit,
            width: 220,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
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
      useExpanded: false, // Reduced gap as requested
      isDarkMode: isDark,
    );
  }

  Widget _buildSelectedTabContent() {
    switch (_activeTabIndex) {
      case 0:
        return GroupTradeTab(key: _groupTradeTabKey);
      case 1:
        return BulkOrderTab(key: _bulkOrderTabKey);
      case 2:
        return ProfitCrossTab(key: _profitCrossTabKey);
      case 3:
        return JobberTrackerTab(key: _jobberTrackerTabKey);
      case 4:
        return BtstStbtTab(key: _btstStbtTabKey);
      default:
        return const SizedBox();
    }
  }

  Future<void> _handleSubmit() async {
    if (_activeTabIndex == 0) {
      await _groupTradeTabKey.currentState?.saveChanges();
      return;
    }

    if (_activeTabIndex == 1) {
      await _bulkOrderTabKey.currentState?.saveChanges();
      return;
    }

    if (_activeTabIndex == 2) {
      await _profitCrossTabKey.currentState?.saveChanges();
      return;
    }

    if (_activeTabIndex == 3) {
      await _jobberTrackerTabKey.currentState?.saveChanges();
      return;
    }

    if (_activeTabIndex == 4) {
      await _btstStbtTabKey.currentState?.saveChanges();
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Submit is currently wired for Group Trade, Bulk Order, Profit % Cross, Jobber Tracker, and BTST/STBT.',
        ),
      ),
    );
  }
}

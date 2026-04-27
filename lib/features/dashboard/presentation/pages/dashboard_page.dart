import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import 'package:surveillance/features/dashboard/presentation/widgets/side_menu.dart';
import '../../../trade/presentation/pages/trade_page.dart';
import '../../../trade/presentation/pages/setting_page.dart';
import '../../../trade/presentation/pages/notification_page.dart';
import '../../../group_trade/presentation/pages/group_trade_page.dart';
import '../../../bulk_order/presentation/pages/bulk_order_tracker_page.dart';
import '../../../profit_cross/presentation/pages/profit_cross_page.dart';
import '../../../jobber_tracker/presentation/pages/jobber_tracker_page.dart';
import '../../../btst/presentation/pages/btst_page.dart';
import '../../../same_ip_tracker/presentation/pages/same_ip_page.dart';
import '../../../same_device_tracker/presentation/pages/same_device_page.dart';
import '../../../trade_comparison/presentation/pages/trade_comparison_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/alert_bloc.dart';
import '../bloc/alert_event.dart';
import '../bloc/dashboard_ui_cubit.dart';
import '../utils/alert_navigation_bus.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardUiCubit _dashboardUiCubit = DashboardUiCubit();
  late final _navBusSub = AlertNavigationBus.instance.stream.listen((
    alertType,
  ) {
    _dashboardUiCubit.openNotifications(initialAlertType: alertType);
  });

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final alertBloc = context.read<AlertBloc>();
      alertBloc.add(const AlertDisconnectEvent());
      alertBloc.add(const AlertConnectEvent());
    });
  }

  Widget _buildContentArea(DashboardUiState state) {
    if (state.showProfile) {
      return ProfilePage(
        onSettingsTap: _dashboardUiCubit.openSettings,
        onNotificationTap: _onNotificationTap,
      );
    }
    if (state.showSettings) {
      return SettingPage(onNotificationTap: _onNotificationTap);
    }
    if (state.showNotifications) {
      return NotificationPage(
        initialTabAlertType: state.notificationInitialType,
      );
    }
    if (state.selectedIndex == 0) {
      return TradePage(
        onSettingsTap: _dashboardUiCubit.openSettings,
        onNotificationTap: _onNotificationTap,
      );
    }
    if (state.selectedIndex == 1) {
      return GroupTradePage(
        onSettingsTap: _dashboardUiCubit.openSettings,
        onNotificationTap: _onNotificationTap,
      );
    }
    if (state.selectedIndex == 2) {
      return BulkOrderTrackerPage(
        onSettingsTap: _dashboardUiCubit.openSettings,
        onNotificationTap: _onNotificationTap,
      );
    }
    if (state.selectedIndex == 3) {
      return ProfitCrossPage(
        onSettingsTap: _dashboardUiCubit.openSettings,
        onNotificationTap: _onNotificationTap,
      );
    }
    if (state.selectedIndex == 4) {
      return JobberTrackerPage(
        onSettingsTap: _dashboardUiCubit.openSettings,
        onNotificationTap: _onNotificationTap,
      );
    }
    if (state.selectedIndex == 5) {
      return BTSTPage(
        onSettingsTap: _dashboardUiCubit.openSettings,
        onNotificationTap: _onNotificationTap,
      );
    }
    if (state.selectedIndex == 6) {
      return SameIPPage(
        onSettingsTap: _dashboardUiCubit.openSettings,
        onNotificationTap: _onNotificationTap,
      );
    }
    if (state.selectedIndex == 7) {
      return SameDevicePage(
        onSettingsTap: _dashboardUiCubit.openSettings,
        onNotificationTap: _onNotificationTap,
      );
    }
    if (state.selectedIndex == 8) {
      return TradeComparisonPage(
        onSettingsTap: _dashboardUiCubit.openSettings,
        onNotificationTap: _onNotificationTap,
      );
    }
    return const Center(child: Text('No dashboard module selected.'));
  }

  void _onNotificationTap() {
    _dashboardUiCubit.openNotifications();
  }

  @override
  void dispose() {
    _navBusSub.cancel();
    _dashboardUiCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
        }
      },
      child: BlocProvider.value(
        value: _dashboardUiCubit,
        child: Scaffold(
          backgroundColor: AppColors.isDarkMode(context)
              ? AppColors.backgroundColor(context)
              : Colors.transparent,
          body: Builder(
            builder: (context) {
              final authState = context.watch<AuthBloc>().state;
              final userName = authState is AuthAuthenticated
                  ? authState.user.username
                  : 'Unknown User';
              final userRole = authState is AuthAuthenticated
                  ? authState.user.role
                  : 'User';

              return BlocBuilder<DashboardUiCubit, DashboardUiState>(
                builder: (context, state) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.pageBackgroundGradient(context),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SideMenu(
                          isExpanded: state.isMenuExpanded,
                          onToggle: _dashboardUiCubit.toggleMenu,
                          selectedIndex: state.selectedIndex,
                          onSelect: _dashboardUiCubit.selectMenu,
                          onProfileTap: _dashboardUiCubit.openProfile,
                          onLogoutTap: () {
                            context.read<AuthBloc>().add(const LogoutEvent());
                          },
                          userName: userName,
                          userRole: userRole,
                        ),
                        Expanded(child: _buildContentArea(state)),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

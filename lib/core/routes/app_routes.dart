import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';


class AppRoutes {
  static const String login = '/';
  static const String marketWatch = '/market-watch';
  static const String scriptSetting = '/script-setting';
  static const String feederSetting = '/feeder-setting';
  static const String users = '/users';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginPage(),
      '/dashboard': (context) => const DashboardPage(),
    };
  }
}


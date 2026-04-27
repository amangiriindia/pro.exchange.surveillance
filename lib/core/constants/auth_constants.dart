class AuthConstants {
  AuthConstants._();

  static const String baseUrl = 'http://13.48.251.17:4000';
  // WebSocket / Socket.IO server URL — change this for production
  static const String socketUrl = 'ws://13.48.251.17:4000';
  static const String socketAlertEvent = 'surveillance_alert';
  static const String alertListEndpoint = '/user/alert/list';
  static const String alertMarkReadEndpoint = '/user/alert/read';
  static const String alertUnreadCountEndpoint = '/user/alert/unread-count';
  static const String loginEndpoint = '/user/auth/login';
  static const String profileEndpoint = '/api/profile';
  static const String changePasswordEndpoint = '/admin/change-password';
  static const String logoutEndpoint = '/admin/logout';
  static const String tradeListEndpoint = '/user/modules/trade';
  static const String groupTradeListEndpoint = '/user/modules/group-trade';
  static const String bulkOrderListEndpoint = '/user/modules/bulk-order';
  static const String bulkOrderTradesEndpoint = '/user/modules/bulk-order';
  static const String profitCrossListEndpoint = '/user/modules/profit-cross';
  static const String profitCrossTradesEndpoint = '/user/modules/profit-cross';
  static const String jobberTrackerListEndpoint =
      '/user/modules/jobber-tracker';
  static const String jobberTrackerTradesEndpoint =
      '/user/modules/jobber-tracker';
  static const String btstListEndpoint = '/user/modules/btst-stbt';
  static const String btstTradesEndpoint = '/user/modules/btst-stbt';
  static const String sameIPListEndpoint = '/user/modules/same-ip';
  static const String sameIPTradesEndpoint = '/user/modules/same-ip';
  static const String sameDeviceListEndpoint = '/user/modules/same-device';
  static const String sameDeviceTradesEndpoint = '/user/modules/same-device';
  static const String tradeComparisonListEndpoint =
      '/user/modules/trade-comparison';
  static const String surveillanceSettingsTypeEndpoint =
      '/user/surveillance/settings/type';
  static const String instrumentsEndpoint = '/admin/instruments';
  static const String globalInstrumentsEndpoint = '/admin/global-instruments';
  static const String instrumentsImportEndpoint = '/admin/instruments/import';
  static const String indiaMarketFeedEndpoint =
      'wss://equity.bazaarpro.app/feed/one';
  static const String globalMarketFeedEndpoint =
      'wss://equity.bazaarpro.app/globalfeed/one';

  static const String indiaMarketFeedBulkEndpoint =
      'wss://equity.bazaarpro.app/feed/bulk';
  static const String globalMarketFeedBulkEndpoint =
      'wss://equity.bazaarpro.app/globalfeed/bulk';
  static const int tokenExpiryMinutes = 30;
  static const String appName = 'BAZAAR';
  static const String loginTitle = 'Log In';
  static const String loginSubtitle = 'Glad you\'re back.!';
  static const String usernameLabel = 'Email';
  static const String passwordLabel = 'Password';
  static const String loginButtonText = 'Login';
  static const String educationPurposeText =
      'This application is Used for Education Purpose Only.';
  static const String versionText = 'Version 1.2.2';
  static const String termsAndConditionsText = 'Terms & Conditions';
  static const String privacyPolicyText = 'Privacy Policy';
  static const String emptyUsernameError = 'Please enter email';
  static const String emptyPasswordError = 'Please enter password';
  static const String loginSuccessMessage = 'Login successful!';
  static const String loginFailedMessage = 'Login failed. Please try again.';
  static const String invalidCredentialsMessage =
      'Invalid username or password';
  static const String termsComingSoon = 'Terms & Conditions page coming soon!';
  static const String privacyComingSoon = 'Privacy Policy page coming soon!';
}

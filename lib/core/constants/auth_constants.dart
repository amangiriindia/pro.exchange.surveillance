class AuthConstants {
  AuthConstants._();
  static const String baseUrl = 'https://equity.bazaarpro.app';
  static const String loginEndpoint = '/auth/login';
  static const String profileEndpoint = '/api/profile';
  static const String changePasswordEndpoint = '/admin/change-password';
  static const String logoutEndpoint = '/admin/logout';
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
  static const String usernameLabel = 'Username';
  static const String passwordLabel = 'Password';
  static const String loginButtonText = 'Login';
  static const String educationPurposeText =
      'This application is Used for Education Purpose Only.';
  static const String versionText = 'Version 1.2.2';
  static const String termsAndConditionsText = 'Terms & Conditions';
  static const String privacyPolicyText = 'Privacy Policy';
  static const String emptyUsernameError = 'Please enter username';
  static const String emptyPasswordError = 'Please enter password';
  static const String loginSuccessMessage = 'Login successful!';
  static const String loginFailedMessage = 'Login failed. Please try again.';
  static const String invalidCredentialsMessage =
      'Invalid username or password';
  static const String termsComingSoon = 'Terms & Conditions page coming soon!';
  static const String privacyComingSoon = 'Privacy Policy page coming soon!';
}

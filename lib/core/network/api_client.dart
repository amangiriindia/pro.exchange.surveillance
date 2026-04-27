import 'dart:async';
import 'package:dio/dio.dart';
import '../constants/auth_constants.dart';
import '../routes/app_routes.dart';
import '../routes/navigator_key.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  static bool _isRedirectingToLogin = false;
  late final Dio dio;

  factory ApiClient() => _instance;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: AuthConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    // API response logging disabled — uncomment to re-enable verbose HTTP logs.
    // dio.interceptors.add(
    //   LogInterceptor(requestBody: true, responseBody: true, error: true),
    // );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AuthLocalDataSource.instance.getAuthToken();
          if (token != null &&
              token.isNotEmpty &&
              options.headers['authorization'] == null) {
            options.headers['authorization'] = token;
          }
          handler.next(options);
        },
        onError: (error, handler) {
          final hadToken =
              error.requestOptions.headers['authorization'] != null;
          if (hadToken && _shouldRedirectToLogin(error)) {
            _redirectToLogin();
          }
          handler.next(error);
        },
      ),
    );
  }

  Dio get client => dio;

  bool _shouldRedirectToLogin(DioException error) {
    final statusCode = error.response?.statusCode;

    if (statusCode == 401) {
      return true;
    }

    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      final message = (responseData['message'] ?? responseData['error'] ?? '')
          .toString()
          .toLowerCase();
      if (message.contains('token') &&
          (message.contains('expired') ||
              message.contains('invalid') ||
              message.contains('unauthorized') ||
              message.contains('login again'))) {
        return true;
      }
    }

    final errorMessage = (error.message ?? '').toLowerCase();
    return errorMessage.contains('token expired') ||
        errorMessage.contains('unauthorized') ||
        errorMessage.contains('login again');
  }

  void _redirectToLogin() {
    if (_isRedirectingToLogin) return;

    final navigator = globalNavigatorKey.currentState;
    if (navigator == null) return;

    _isRedirectingToLogin = true;
    unawaited(AuthLocalDataSource.instance.clearUserSession());
    navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);

    Future<void>.delayed(const Duration(milliseconds: 300), () {
      _isRedirectingToLogin = false;
    });
  }
}

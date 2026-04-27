import 'dart:convert';
import '../../../../core/utils/shared_preferences_helper.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';

class AuthLocalDataSource {
  AuthLocalDataSource._();

  static final AuthLocalDataSource instance = AuthLocalDataSource._();

  static const String _userSessionKey = 'auth_user_session';
  static const String _authTokenKey = 'auth_token';

  Future<void> saveUserSession(User user) async {
    final model = LoginUserModel.fromEntity(user);
    await SharedPreferencesHelper.instance.setString(
      _userSessionKey,
      jsonEncode(model.toJson()),
    );
    await SharedPreferencesHelper.instance.setString(
      _authTokenKey,
      user.jwtToken,
    );
  }

  Future<User?> getUserSession() async {
    final rawSession = await SharedPreferencesHelper.instance.getString(
      _userSessionKey,
    );
    if (rawSession == null || rawSession.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawSession);
      if (decoded is! Map<String, dynamic>) {
        await clearUserSession();
        return null;
      }
      return LoginUserModel.fromStorageJson(decoded);
    } catch (_) {
      await clearUserSession();
      return null;
    }
  }

  Future<String?> getAuthToken() async {
    final token = await SharedPreferencesHelper.instance.getString(
      _authTokenKey,
    );
    if (token == null || token.isEmpty) {
      return null;
    }
    return token;
  }

  Future<void> clearUserSession() async {
    await SharedPreferencesHelper.instance.remove(_userSessionKey);
    await SharedPreferencesHelper.instance.remove(_authTokenKey);
  }
}

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user.dart';
import '../models/user_model.dart';

class AuthLocalDataSource {
  AuthLocalDataSource._();

  static final AuthLocalDataSource instance = AuthLocalDataSource._();

  static const String _userSessionKey = 'auth_user_session';

  Future<void> saveUserSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final model = LoginUserModel.fromEntity(user);
    await prefs.setString(_userSessionKey, jsonEncode(model.toJson()));
  }

  Future<User?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final rawSession = prefs.getString(_userSessionKey);
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

  Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userSessionKey);
  }
}

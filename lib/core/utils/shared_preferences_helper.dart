import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  SharedPreferencesHelper._();

  static final SharedPreferencesHelper instance = SharedPreferencesHelper._();

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<bool> setString(String key, String value) async {
    final prefs = await _prefs;
    return prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await _prefs;
    return prefs.getString(key);
  }

  Future<bool> remove(String key) async {
    final prefs = await _prefs;
    return prefs.remove(key);
  }
}

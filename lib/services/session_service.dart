//qudas\lib\services\session_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {

  static const String userKey = "logged_in_username";

  static Future<void> saveUser(String username) async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(userKey, username);
  }

  static Future<String?> getUser() async {

    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(userKey);
  }

  static Future<void> logout() async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();
  }
}
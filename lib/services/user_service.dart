import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _userDataKey = 'user_data';

  static Future<String?> getUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_userDataKey);
      if (jsonStr == null) return null;

      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      return data['username'] as String?;
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {'username': username, 'createdAt': DateTime.now().toIso8601String()};
    await prefs.setString(_userDataKey, jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_userDataKey);
      if (jsonStr == null) return null;

      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateUserData(Map<String, dynamic> updates) async {
    final existing = await getUserData() ?? {};
    existing.addAll(updates);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(existing));
  }
}

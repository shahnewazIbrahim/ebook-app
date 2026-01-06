import 'package:shared_preferences/shared_preferences.dart';

class TokenStore {
  static const _practiceKey = 'practice_token';

  static Future<void> savePracticeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_practiceKey, token);
  }

  static Future<String?> practiceToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_practiceKey);
  }

  static Future<String> attachPracticeToken(String endpoint) async {
    final token = await practiceToken();
    if (token == null || token.isEmpty) return endpoint;
    final separator = endpoint.contains('?') ? '&' : '?';
    return '$endpoint${separator}token=${Uri.encodeQueryComponent(token)}';
  }
}

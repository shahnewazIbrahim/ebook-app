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

  static String? extractTokenFromUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final match = RegExp(r'[?&]token=([^&]+)').firstMatch(url);
    if (match == null) return null;
    return Uri.decodeComponent(match.group(1) ?? '');
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class TokenStore {
  static const _key = 'jwt_token';
  SharedPreferences? _prefs;
  String? _cachedToken;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> saveToken(String token) async {
    _cachedToken = token;
    final prefs = await _getPrefs();
    await prefs.setString(_key, token);
  }

  Future<String?> readToken() async {
    if (_cachedToken != null) return _cachedToken;
    final prefs = await _getPrefs();
    _cachedToken = prefs.getString(_key);
    return _cachedToken;
  }

  Future<void> deleteToken() async {
    _cachedToken = null;
    final prefs = await _getPrefs();
    await prefs.remove(_key);
  }
}

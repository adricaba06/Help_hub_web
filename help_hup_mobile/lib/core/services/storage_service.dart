import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_response.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveUser(UserResponse user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', user.toJson());
  }

  Future<UserResponse?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) return null;
    return UserResponse.fromJson(userJson);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

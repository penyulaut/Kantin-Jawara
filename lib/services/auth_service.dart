import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.userTokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.userTokenKey);
  }

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.userDataKey, jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(Constants.userDataKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.userTokenKey);
    await prefs.remove(Constants.userDataKey);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

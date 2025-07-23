import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = Constants.baseUrl;

  Map<String, String> _getHeaders({String? token}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${Constants.loginEndpoint}'),
        headers: _getHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 422) {
        // Validation error
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Email atau password salah',
        };
      } else {
        return {
          'success': false,
          'message': 'Login failed. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Login Error: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${Constants.registerEndpoint}'),
        headers: _getHeaders(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      print('Register Response Status: ${response.statusCode}');
      print('Register Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 422) {
        // Validation error
        final data = jsonDecode(response.body);
        String message = 'Registration failed';
        if (data['errors'] != null) {
          // Laravel validation errors format
          final errors = data['errors'] as Map<String, dynamic>;
          message = errors.values.first[0];
        } else if (data['message'] != null) {
          message = data['message'];
        }
        return {'success': false, 'message': message};
      } else if (response.statusCode == 403) {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Registration not allowed',
        };
      } else {
        return {
          'success': false,
          'message': 'Registration failed. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Register Error: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${Constants.logoutEndpoint}'),
        headers: _getHeaders(token: token),
      );

      print('Logout Response Status: ${response.statusCode}');
      print('Logout Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Logged out successfully'};
      } else {
        return {'success': false, 'message': 'Logout failed'};
      }
    } catch (e) {
      print('Logout Error: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl${Constants.profileEndpoint}'),
        headers: _getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to get profile'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}

// lib/core/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';

class AuthService {
  static const String baseUrl = "http://192.168.7.103:9000"; // Change this

  static Future<RegisterResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/register?name=$name&email=$email&password=$password');
    final response = await http.post(url);

    final json = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return RegisterResponse.fromJson(json);
    } else {
      throw Exception(json['message'] ?? 'Registration failed');
    }
  }

  static Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/login?email=$email&password=$password');
    final response = await http.post(url);

    final json = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final loginResponse = LoginResponse.fromJson(json);

      // Save token & user
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', loginResponse.token);
      await prefs.setString('user_name', loginResponse.user.name);
      await prefs.setInt('user_id', loginResponse.user.id);
      await prefs.setString('user_email', loginResponse.user.email);

      return loginResponse;
    } else {
      throw Exception(json['message'] ?? 'Login failed');
    }
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return token != null
        ? {'Authorization': 'Bearer $token', 'Accept': 'application/json'}
        : {'Accept': 'application/json'};
  }
}
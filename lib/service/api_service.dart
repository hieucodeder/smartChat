import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_chat/model/login_model.dart';
import 'package:smart_chat/service/app_config.dart';

class ApiService {
  /// Lấy Google accessToken từ SharedPreferences rồi gọi API /users/login-google
  static Future<Map<String, dynamic>?> loginWithToken() async {
    try {
      // 1. Lấy token từ prefs
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('googleAccessToken');
      debugPrint('🔑 Retrieved accessToken: $accessToken');

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Invalid Google access token');
      }

      // 2. Gọi API backend
      final url = Uri.parse('${ApiConfig.baseUrlBasic}users/login-google');
      final headers = await ApiConfig.getHeaders();
      final response = await http
          .post(
            url,
            headers: {
              ...headers,
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'access_token': accessToken,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('Response: ${response.body}');
      // 3. Xử lý kết quả
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final account = LoginModel.fromJson(jsonResponse);

        // 4. Lưu thông tin user vào prefs
        await prefs.setString('userid', account.userId ?? '');
        await prefs.setString('username', account.username ?? '');
        await prefs.setString('full_name', account.fullName ?? '');
        await prefs.setString('email', account.email ?? '');
        await prefs.setString('picture', account.picture ?? '');
        await prefs.setString('token', account.token ?? '');

        return {
          'account': account,
          'token': account.token,
        };
      } else {
        debugPrint('🔴 API Error: ${response.statusCode} - ${response.body}');
        throw Exception('API failed with status ${response.statusCode}');
      }
    } on TimeoutException {
      debugPrint('🔴 API Request timeout');
      rethrow;
    } catch (e) {
      debugPrint('🔴 API Exception: $e');
      rethrow;
    }
  }

  /// Lấy full_name, email, picture đã lưu
  Future<Map<String, String>?> getAccountFullNameAndUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userid');
    final userName = prefs.getString('full_name');
    final email = prefs.getString('email');
    final picture = prefs.getString('picture');

    if (userId == null ||
        (userName == null && email == null && picture == null)) {
      return null;
    }

    return {
      'full_name': userName ?? '',
      'email': email ?? 'Không có email',
      'picture': picture ?? ''
    };
  }
}

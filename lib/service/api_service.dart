import 'dart:async';

import 'package:chatbotbnn/model/login_model.dart';
import 'package:chatbotbnn/service/app_config.dart';
import 'package:chatbotbnn/service/user_singin_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static Future<Map<String, dynamic>?> loginWithToken() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrlBasic}users/login-google');
      final headers = await ApiConfig.getHeaders();
      final accessToken = AuthTokens.googleAccessToken;
      print('AccessToken ${AuthTokens.googleAccessToken}');

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Invalid Google access token');
      }

      // Gửi access_token dưới dạng JSON đúng chuẩn
      final response = await http
          .post(
            url,
            headers: {
              ...headers,
              'Content-Type': 'application/json', // Thêm header JSON
            },
            body: json.encode({
              'access_token': accessToken, // Đúng cấu trúc server yêu cầu
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final account = LoginModel.fromJson(jsonResponse);

        // Lưu thông tin user
        final prefs = await SharedPreferences.getInstance();
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

  // getAccountFullNameAndUsername function
  Future<Map<String, String>?> getAccountFullNameAndUsername() async {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getString('userid');
    final userName = prefs.getString('full_name');
    final email = prefs.getString('email');
    final picture = prefs.getString('picture');
    if (userId == null ||
        userName == null && email == null && picture == null) {
      return null;
    }

    return {
      'full_name': userName ?? '', // Return default text if null
      'email': email ?? 'Không có email', // Return default text if null
      'picture': picture ?? ""
    };
  }
}

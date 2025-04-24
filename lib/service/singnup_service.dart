// file: services/signup_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_chat/model/body_signup.dart';
import 'package:smart_chat/model/body_create_group.dart';
import 'package:smart_chat/model/body_signup_activation.dart';
import 'package:smart_chat/service/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_chat/service/storage_service.dart';

class SignupService {
  /// Signup user, create group, send activation email.
  Future<Map<String, dynamic>?> signup({
    required String address,
    required String email,
    required String fullName,
    required String password,
    required String passwordConfirmation,
    required String phoneNumber,
    String? picture,
    required String userName,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrlBasic}users/signup');
    final headers = await ApiConfig.getHeaders();
    final bodySignup = BodySignup(
      address: address,
      email: email,
      fullName: fullName,
      passwordConfirmation: passwordConfirmation,
      passwordHash: password,
      phoneNumber: phoneNumber,
      picture: picture,
      username: userName,
    );
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(bodySignup.toJson()),
      );
      if (response.statusCode != 200) return null;

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final message = jsonResponse['message'] as String?;
      final results = jsonResponse['results'] as String?;
      if (message == null || results == null) {
        throw FormatException('Invalid signup response');
      }

      // Lưu và dùng trực tiếp biến results
      final userId = results;
      await StorageService.saveUserId(userId);

      // Tạo group ngay sau signup
      await createGroup(
        BodyCreateGroup(
          groupName: fullName,
          groupUrl: '',
          role: 'owner',
          userId: userId,
        ),
      );

      // Gửi mail kích hoạt
      await signUpActivation(
        BodySignupActivation(
          email: email,
          user: User(fullName: fullName),
        ),
      );

      return {
        'message': message,
        'results': results,
      };
    } catch (e, st) {
      if (kDebugMode) debugPrint('Signup error: $e\n$st');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createGroup(BodyCreateGroup data) async {
    final url = Uri.parse('${ApiConfig.baseUrlBasic}group/create');
    final headers = await ApiConfig.getHeaders();
    try {
      final resp = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data.toJson()),
      );
      if (resp.statusCode != 200) return null;
      final j = jsonDecode(resp.body) as Map<String, dynamic>;
      return {
        'message': j['message'] as String? ?? '',
        'success': j['success'] as bool? ?? false,
      };
    } catch (e, st) {
      if (kDebugMode) debugPrint('CreateGroup error: $e\n$st');
      return null;
    }
  }

  Future<Map<String, dynamic>?> signUpActivation(
      BodySignupActivation data) async {
    final url = Uri.parse('${ApiConfig.baseUrlBasic}email/signup-activation');
    final headers = await ApiConfig.getHeaders();
    try {
      final resp = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data.toJson()),
      );
      if (resp.statusCode != 200) return null;
      final j = jsonDecode(resp.body) as Map<String, dynamic>;
      return {
        'message': j['message'] as String? ?? '',
        'success': j['success'] as bool? ?? false,
      };
    } catch (e, st) {
      if (kDebugMode) debugPrint('Activation error: $e\n$st');
      return null;
    }
  }
}

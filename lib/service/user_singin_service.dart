import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_chat/service/api_service.dart';

class AuthTokens {
  static String? googleAccessToken;
  static String? firebaseIdToken;
}

class UserSinginService {
  static Future<User?> loginWithGoogle() async {
    try {
      // 1. Khởi tạo GoogleSignIn với đầy đủ các scope
      final googleSignIn = GoogleSignIn(
        scopes: [
          'openid',
          'email',
          'profile',
          'https://www.googleapis.com/auth/user.phonenumbers.read',
          'https://www.googleapis.com/auth/user.addresses.read',
        ],
      );

      // 2. Hiển thị màn đăng nhập Google
      final account = await googleSignIn.signIn();
      if (account == null) {
        debugPrint('🔴 User cancelled Google sign in');
        return null;
      }

      // 3. Lấy accessToken & idToken từ Google
      final auth = await account.authentication;
      final accessToken = auth.accessToken;
      final idToken = auth.idToken;
      if (accessToken == null || idToken == null) {
        debugPrint('🔴 Missing Google tokens');
        return null;
      }

      // --- MỚI: lưu accessToken vào SharedPreferences ---
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('googleAccessToken', accessToken);

      AuthTokens.googleAccessToken = accessToken;
      debugPrint('🟢 Google auth succeeded, token saved');

      // 4. Firebase sign-in
      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );
      final userCred =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCred.user;
      if (user == null) throw Exception('Firebase sign-in failed');
      debugPrint('🟢 Firebase auth succeeded');

      // 5. Refresh accessToken (silent) và update prefs
      final silent = await googleSignIn.signInSilently();
      if (silent != null) {
        final refreshed = await silent.authentication;
        if (refreshed.accessToken != null) {
          await prefs.setString('googleAccessToken', refreshed.accessToken!);
          AuthTokens.googleAccessToken = refreshed.accessToken;
          debugPrint('🔄 Refreshed Google token saved');
        }
      }

      // 6. Lấy fresh Firebase ID token (nếu cần lưu)
      AuthTokens.firebaseIdToken = await user.getIdToken(true);
      // Nếu bạn cũng muốn lưu Firebase ID token:
      // await prefs.setString('firebaseIdToken', AuthTokens.firebaseIdToken!);

      // 7. Gọi People API 1 lần để lấy phone + address
      await _fetchProfile(AuthTokens.googleAccessToken!);

      // 8. Gọi API backend với token đã lưu
      await ApiService.loginWithToken();

      return user;
    } catch (e) {
      debugPrint('🔴 SignIn error: $e');
      rethrow;
    }
  }

  static Future<void> _fetchProfile(String accessToken) async {
    final url = Uri.parse(
      'https://people.googleapis.com/v1/people/me'
      '?personFields=phoneNumbers,addresses',
    );
    final resp = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    debugPrint('📦 People API status: ${resp.statusCode}');
    debugPrint('📦 Body: ${resp.body}');

    if (resp.statusCode != 200) return;
    final data = json.decode(resp.body);
    final phones = (data['phoneNumbers'] as List<dynamic>?) ?? [];
    if (phones.isNotEmpty) {
      debugPrint('📱 Phone: ${phones.first['value']}');
    }
    final addrs = (data['addresses'] as List<dynamic>?) ?? [];
    if (addrs.isNotEmpty) {
      final first = addrs.first;
      final formatted = first['formattedValue'] ?? first['streetAddress'];
      debugPrint('🏠 Address: $formatted');
    }
  }
}

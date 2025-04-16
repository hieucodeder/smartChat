import 'dart:convert';
import 'package:chatbotbnn/service/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthTokens {
  static String? googleAccessToken;
  static String? firebaseIdToken;
}

class UserSigninService {
  static Future<User?> loginWithGoogle() async {
    try {
      // 1. Đăng nhập Google với scope yêu cầu
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
          'openid',
          'https://www.googleapis.com/auth/user.phonenumbers.read',
        ],
      );

      final GoogleSignInAccount? googleAccount = await googleSignIn.signIn();
      if (googleAccount == null) {
        debugPrint('🔴 Google sign in cancelled by user');
        return null;
      }

      // 2. Lấy token xác thực từ Google
      final googleAuth = await googleAccount.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        debugPrint('🔴 Failed to get Google tokens');
        return null;
      }

      AuthTokens.googleAccessToken = accessToken;
      debugPrint('🟢 Google auth successful');
      debugPrint('🔵 Google Access Token: $accessToken');
      debugPrint('🔵 Google ID Token: $idToken');

      // 3. Đăng nhập Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      debugPrint('🟢 Firebase auth successful');

      // 4. Lấy lại accessToken mới từ Google (signInSilently)
      final refreshedUser = await googleSignIn.signInSilently();
      if (refreshedUser != null) {
        final refreshedAuth = await refreshedUser.authentication;
        AuthTokens.googleAccessToken = refreshedAuth.accessToken;
        debugPrint(
            '🔄 Refreshed Google Access Token: ${refreshedAuth.accessToken}');
      } else {
        debugPrint('🔴 Failed to refresh Google access token');
        await FirebaseAuth.instance.signOut();
        return null;
      }

      // 5. Lấy Firebase ID Token (bắt buộc force refresh)
      final freshIdToken = await user?.getIdToken(true);
      if (freshIdToken == null) {
        debugPrint('🔴 Failed to get Firebase ID Token');
        await FirebaseAuth.instance.signOut();
        return null;
      }
      AuthTokens.firebaseIdToken = freshIdToken;
      debugPrint('🔵 Firebase ID Token: $freshIdToken');

      // 6. Gọi Google People API để lấy số điện thoại
      final phoneNumber = await fetchPhoneNumber(accessToken);
      if (phoneNumber != null) {
        debugPrint('📱 User phone number from Google People API: $phoneNumber');
      } else {
        debugPrint('📱 No phone number found or permission denied');
      }

      // 7. Gọi API backend với Firebase ID Token
      final apiResult = await ApiService.loginWithToken();
      if (apiResult == null) {
        debugPrint('🔴 API login failed');
        await FirebaseAuth.instance.signOut();
        return null;
      }

      debugPrint('🟢 API login successful');
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('🔴 Firebase Auth Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('🔴 Unexpected Error: $e');
      rethrow;
    }
  }
}

Future<String?> fetchPhoneNumber(String accessToken) async {
  final url = Uri.parse(
      'https://people.googleapis.com/v1/people/me?personFields=phoneNumbers');
  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final phones = data['phoneNumbers'] as List<dynamic>?;
    if (phones != null && phones.isNotEmpty) {
      return phones.first['value'];
    }
  } else {
    debugPrint(
        '🔴 Failed to fetch phone number: ${response.statusCode} - ${response.body}');
  }

  return null;
}

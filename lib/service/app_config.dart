import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_chat/service/helper/secure_storage_helper.dart';

class ApiConfig {
  static const String domain = 'https://app.smartchat.com.vn';

  static String get baseUrlBasic {
    return '$domain/api/';
  }

  static String get baseUrl {
    return '$domain/api/chatbot/';
  }

  static String get baseUrlDasboard {
    return '$domain/api/dashboard/';
  }

  static String get baseUrlHistory {
    return '$domain/api/chatbot-history/';
  }

  // static Future<String?> getToken() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('token');
  // }
  static Future<String?> getToken() async {
    // Thử lấy từ Secure Storage trước
    final secureToken = await SecureStorageHelper.getToken();
    if (secureToken != null) return secureToken;
    print("đã đăng nhập bằng secureToken");

    // Nếu không có trong Secure Storage thì lấy từ SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> getHeaders() async {
    String? token = await getToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // Thêm phương thức mới để lưu token sau khi đăng nhập
  static Future<void> saveToken(String token) async {
    await SecureStorageHelper.saveToken(token);
  }

  // Thêm phương thức xóa token khi đăng xuất
  static Future<void> clearToken() async {
    await SecureStorageHelper.deleteToken();
  }
}

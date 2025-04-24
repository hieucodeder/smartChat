import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyUserId = 'user_results';

  /// Lưu UUID (hoặc bất kỳ chuỗi nào) vào SharedPreferences
  static Future<bool> saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_keyUserId, id);
  }

  /// Đọc UUID đã lưu, trả về null nếu chưa có
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  /// Xoá UUID đã lưu
  static Future<bool> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_keyUserId);
  }
}

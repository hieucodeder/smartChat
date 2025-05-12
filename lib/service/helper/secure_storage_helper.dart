import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  static const _storage = FlutterSecureStorage();

  // Key for token
  static const _keyToken = 'auth_token';

  // Lưu token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  // Lấy token
  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  // Xóa token (khi đăng xuất)
  static Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
  }
}
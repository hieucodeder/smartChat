import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_chat/service/app_config.dart';

class SendEmailPassword {
  /// Gửi email quên mật khẩu, trả về true nếu thành công
  static Future<bool> sendMessage(String email) async {
    final String urlString = '${ApiConfig.baseUrlBasic}email/forgot-password';
    final uri = Uri.parse(urlString);
    final Map<String, String> headers = await ApiConfig.getHeaders();

    try {
      final response = await http.post(uri,
          headers: headers, body: jsonEncode({'email': email}));
      print('HTTP ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else if (response.statusCode == 502) {
        // Show message đặc biệt cho 502
        throw Exception('Lỗi máy chủ (502). Vui lòng thử lại sau.');
      } else {
        throw Exception('Lỗi ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
      return false;
    }
  }
}

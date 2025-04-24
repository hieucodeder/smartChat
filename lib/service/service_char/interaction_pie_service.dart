import 'dart:convert';
import 'package:smart_chat/model/char/body_char.dart';
import 'package:smart_chat/model/char/response_interactionpie.dart';
import 'package:smart_chat/service/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<List<ResponseInteractionpie>> fetchAllInteractionpie(
    String? chatbotCode, String? startDate, String? endDate) async {
  final String apiUrl =
      '${ApiConfig.baseUrlDasboard}/dashboard-interaction-with-platform';

  try {
    // Lấy userId từ SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userid');

    if (userId == null || userId.isEmpty) {
      throw Exception('User ID is not available in SharedPreferences');
    }

    // Tạo object request
    final requestBody = BodyChar(
      chatbotCode: chatbotCode,
      startDate: startDate,
      endDate: endDate,
      userId: userId,
    );

    // Chuyển requestBody thành JSON
    final String body = jsonEncode(requestBody.toJson());

    // Lấy headers từ ApiConfig
    final Map<String, String> headers = await ApiConfig.getHeaders();

    // Gửi request đến API
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      print("API Response: $jsonResponse");

      if (jsonResponse is List) {
        return jsonResponse
            .map((item) => ResponseInteractionpie.fromJson(item))
            .toList();
      } else if (jsonResponse is Map<String, dynamic>) {
        return [ResponseInteractionpie.fromJson(jsonResponse)];
      }
    } else {
      print("Error: ${response.statusCode}, Body: ${response.body}");
    }
  } catch (e, stacktrace) {
    print("Exception: $e");
    print("Stacktrace: $stacktrace");
  }

  return []; // Trả về danh sách rỗng nếu có lỗi
}

import 'dart:convert';
import 'package:chatbotbnn/model/response_total_count.dart';
import 'package:chatbotbnn/model/resquest_total_question.dart';
import 'package:chatbotbnn/service/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<ResponseTotalCount> fetchAllTotalCount(
    String? chatbotCode, String? startDate, String? endDate) async {
  final String apiUrl = '${ApiConfig.baseUrlDasboard}/dashboard-count-chatbots';

  try {
    // Lấy userId từ SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userid');

    if (userId == null || userId.isEmpty) {
      throw Exception('User ID is not available in SharedPreferences');
    }

    // Tạo object request
    final requestBody = ResquestTotal(
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

    // Kiểm tra response
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);

      // Nếu API trả về một danh sách, lấy phần tử đầu tiên
      if (jsonResponse is List && jsonResponse.isNotEmpty) {
        return ResponseTotalCount.fromJson(jsonResponse[0]);
      } else if (jsonResponse is Map<String, dynamic>) {
        return ResponseTotalCount.fromJson(jsonResponse);
      } else {
        throw Exception("Unexpected response format");
      }
    } else {
      throw Exception(
          "Failed to fetch data. Status code: ${response.statusCode}, Body: ${response.body}");
    }
  } catch (e) {
    throw Exception('An error occurred: $e');
  }
}

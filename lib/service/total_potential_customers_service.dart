import 'dart:convert';
import 'package:smart_chat/model/body_potential_customers.dart';
import 'package:smart_chat/model/response_total_potential_customers.dart';
import 'package:smart_chat/model/resquest_total_question.dart';
import 'package:smart_chat/service/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<ResponseTotalPotentialCustomers> fetchAllTotalPotentialCustomer(
    String? chatbotCode, String? startDate, String? endDate) async {
  final String apiUrl =
      '${ApiConfig.baseUrlDasboard}/dashboard-slots-with-platform';

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
      print("Raw API Response: ${response.body}");

      try {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse is List && jsonResponse.isNotEmpty) {
          return ResponseTotalPotentialCustomers.fromJson(jsonResponse[0]);
        } else if (jsonResponse is Map<String, dynamic>) {
          return ResponseTotalPotentialCustomers.fromJson(jsonResponse);
        } else {
          throw Exception("Unexpected response format: $jsonResponse");
        }
      } catch (jsonError) {
        throw Exception("Failed to parse JSON: ${response.body}");
      }
    } else {
      throw Exception(
          "Failed to fetch data. Status: ${response.statusCode}, Response: ${response.body}");
    }
  } catch (e) {
    throw Exception('An error occurred: $e');
  }
}

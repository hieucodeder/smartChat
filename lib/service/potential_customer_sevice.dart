import 'dart:convert';
import 'package:chatbotbnn/model/body_potential_customers.dart';
import 'package:chatbotbnn/model/body_slot_intent.dart';
import 'package:chatbotbnn/model/reponse_potential_customer.dart';
import 'package:chatbotbnn/service/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:chatbotbnn/provider/chatbot_provider.dart';

Future<List<DataPotentialCustomer>> fetchAllPotentialCustomer(
    BuildContext context, String? searchContent, String? slotsStatus) async {
  final String apiUrl = '${ApiConfig.baseUrl}/search-slots-by-intent';

  try {
    // Lấy chatbotCode từ ChatbotProvider
    final chatbotCode =
        Provider.of<ChatbotProvider>(context, listen: false).currentChatbotCode;

    if (chatbotCode == null || chatbotCode.isEmpty) {
      throw Exception('Chatbot code is null or empty');
    }

    // Lấy userId từ SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userid');

    if (userId == null || userId.isEmpty) {
      throw Exception('User ID is not available in SharedPreferences');
    }

    // Tạo object request
    final requestBody = BodySlotIntent(
      chatbotCode: chatbotCode,
      intentQueue: "",
      pageIndex: "1",
      pageSize: "10",
      searchContent: searchContent,
      slotStatus: slotsStatus,
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
      final jsonResponse = jsonDecode(response.body);
      print("API Response: $jsonResponse");

      if (jsonResponse is Map<String, dynamic>) {
        // Kiểm tra nếu response chứa danh sách data
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
          return (jsonResponse['data'] as List)
              .map((item) => DataPotentialCustomer.fromJson(item))
              .toList();
        } else {
          print("Error: 'data' field is missing or incorrect format.");
        }
      } else {
        print("Error: Unexpected API response format.");
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

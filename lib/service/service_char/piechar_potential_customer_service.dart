import 'dart:convert';
import 'package:chatbotbnn/model/body_potential_customers.dart';
import 'package:chatbotbnn/model/char/response_potential_customer.dart';
import 'package:chatbotbnn/model/char/response_potential_customerpie.dart';
import 'package:chatbotbnn/service/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<List<ResponsePotentialCustomerpie>>
    fetchAllTotalPotentialCustomerPieChar(
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
    final requestBody = BodyPotentialCustomers(
      chatbotCode: chatbotCode,
      startDate: startDate,
      endDate: endDate,
      intentQueue: null,
      pageIndex: 1,
      pageSize: "1000000000",
      searchContent: "",
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
            .map((item) => ResponsePotentialCustomerpie.fromJson(item))
            .toList();
      } else if (jsonResponse is Map<String, dynamic>) {
        return [ResponsePotentialCustomerpie.fromJson(jsonResponse)];
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

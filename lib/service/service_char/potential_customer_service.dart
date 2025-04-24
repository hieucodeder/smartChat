import 'dart:convert';
import 'package:smart_chat/model/body_potential_customers.dart';
import 'package:smart_chat/model/char/response_potential_customer.dart';
import 'package:smart_chat/service/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<List<ResponsePotentialCustomer>> fetchAllPotentialCustomerChar(
    String? chatbotCode, String? startDate, String? endDate) async {
  final String apiUrl = '${ApiConfig.baseUrlDasboard}/dashboard-column-slots';
  // Gán giá trị mặc định nếu tham số rỗng hoặc null
  startDate =
      (startDate == null || startDate.isEmpty) ? "2025-03-01" : startDate;
  endDate = (endDate == null || endDate.isEmpty) ? "2025-03-31" : endDate;
  try {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userid');

    if (userId == null || userId.isEmpty) {
      throw Exception('User ID is not available in SharedPreferences');
    }

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

    final String body = jsonEncode(requestBody.toJson());
    final Map<String, String> headers = await ApiConfig.getHeaders();

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: body,
    );
    print(response.body);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      print("API Response: $jsonResponse");

      if (jsonResponse is List) {
        return jsonResponse
            .map((item) => ResponsePotentialCustomer.fromJson(item))
            .toList();
      } else if (jsonResponse is Map<String, dynamic>) {
        return [ResponsePotentialCustomer.fromJson(jsonResponse)];
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

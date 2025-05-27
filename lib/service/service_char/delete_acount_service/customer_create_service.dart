import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_chat/model/delete_acount/request_customer_create.dart';
import 'package:smart_chat/model/delete_acount/response_search.dart';
import 'package:smart_chat/service/app_config.dart';

Future<ResponseSearch?> customerCreate(
    RequestCustomerCreate requestCustomerCreate) async {
  const String apiUrl = 'https://admin.smartchat.com.vn/api/customers/create';

  try {
    final String body = jsonEncode(requestCustomerCreate.toJson());
    final Map<String, String> headers = await ApiConfig.getHeaders();

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final ResponseSearch res = ResponseSearch.fromJson(responseData);
      return res;
    } else {
      print('Status Code != 200: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error in customerCreate: $e');
    return null;
  }
}

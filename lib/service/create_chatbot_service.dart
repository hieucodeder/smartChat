import 'dart:convert';
import 'package:chatbotbnn/model/body_create_chatbot.dart';
import 'package:chatbotbnn/model/response_createchatbot.dart';
import 'package:chatbotbnn/service/app_config.dart';
import 'package:http/http.dart' as http;

Future<ResponseCreatechatbot?> fetchApiResponseCreateChatbot(
    BodyCreateChatbot chatbotRequest) async {
  final String apiUrl = '${ApiConfig.baseUrl}create-by-group';

  try {
    final requestBody = json.encode(chatbotRequest.toJson());
    final Map<String, String> headers = await ApiConfig.getHeaders();
    print("Headers: $headers");

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      // Kiểm tra nếu JSON chứa `data` và `results`
      if (jsonResponse.containsKey('data') && jsonResponse['results'] == true) {
        return ResponseCreatechatbot.fromJson(
            jsonResponse['data']); // Lấy dữ liệu từ `data`
      } else {
        print("Lỗi: ${jsonResponse['message']}");
      }
    } else {
      final Map<String, dynamic> errorResponse = json.decode(response.body);
      if (errorResponse['message'] == 'Chatbot Code not found') {
        print("Chatbot Code not found");
      } else {
        print("Lỗi API: ${errorResponse['message']}");
      }
    }
  } catch (e) {
    print('Lỗi kết nối API: $e');
  }

  return null;
}

import 'dart:convert';
import 'package:smart_chat/model/resquest_update_chatbot.dart';
import 'package:smart_chat/model/response_update_chatbot.dart';
import 'package:smart_chat/service/app_config.dart';
import 'package:http/http.dart' as http;

Future<ResponseUpdateChatbot?> fetchApiResponseUpdateChatbot(
    ResquestUpdateChatbot updateChatbotRequest) async {
  final String apiUrl = '${ApiConfig.baseUrl}update-chatbot';

  try {
    final requestBody = json.encode(updateChatbotRequest.toJson());
    final Map<String, String> headers = await ApiConfig.getHeaders();

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final updateResponse = ResponseUpdateChatbot.fromJson(jsonResponse);

      if (updateResponse.message == 'Chatbot Code not found') {
        print("Chatbot Code not found");
        return updateResponse; // Vẫn trả về response để xử lý ở tầng trên nếu cần
      }

      return updateResponse; // Trả về response thành công
    } else {
      print(
          "Failed to update chatbot: ${response.statusCode}, Response: ${response.body}");
      return null;
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:chatbotbnn/model/response_get_code.dart';
import 'package:chatbotbnn/service/app_config.dart';
import 'package:http/http.dart' as http;

Future<ResponseGetCode?> fetchGetChatBotCode(String? chatbotCode) async {
  try {
    if (chatbotCode == null) {
      print("Error: chatbotCode is null");
      return null;
    }

    final Uri apiUrl =
        Uri.parse('${ApiConfig.baseUrl}get-by-code/$chatbotCode');

    final response = await http.get(apiUrl);
    print('Ket qua: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return ResponseGetCode.fromJson(jsonData);
    } else {
      print(
          "Failed to load data: ${response.statusCode}, Response: ${response.body}");
      return null;
    }
  } on SocketException {
    print("Error: No Internet connection.");
    return null;
  } on FormatException {
    print("Error: Invalid JSON format.");
    return null;
  } catch (e) {
    print("Unexpected Error: $e");
    return null;
  }
}

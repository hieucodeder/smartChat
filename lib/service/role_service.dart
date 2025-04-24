import 'dart:convert';
import 'package:smart_chat/model/body_role.dart';
import 'package:smart_chat/model/response_get_code.dart';
import 'package:smart_chat/model/role_model.dart';
import 'package:smart_chat/service/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<RoleModel?> fetchRoles(BodyRole bodyRole) async {
  final String apiUrl = '${ApiConfig.baseUrl}search';
  try {
    final String body = jsonEncode(bodyRole.toJson());
    final Map<String, String> headers = await ApiConfig.getHeaders();

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      RoleModel roleModel = RoleModel.fromJson(responseData);
      final prefs = await SharedPreferences.getInstance();

      if (roleModel.data != null && roleModel.data!.isNotEmpty) {
        // Lưu chatbotName đầu tiên
        String chatbotName =
            roleModel.data!.first.chatbotName ?? 'Default Chatbot Name';
        await prefs.setString('chatbot_name', chatbotName);

        // Lấy tất cả chatbotCode và lưu vào SharedPreferences
        List<String> chatbotCodes = roleModel.data!
            .map((data) => data.chatbotCode ?? 'Default Chatbot Code')
            .toList();

        // Lưu danh sách chatbotCodes dưới dạng JSON string
        await prefs.setString('chatbot_codes', jsonEncode(chatbotCodes));
      } else {
        await prefs.setString('chatbot_name', 'Default Chatbot Name');
      }

      return roleModel;
    } else {
      return null;
    }
  } catch (e) {
    print('Error in fetchRoles: $e');
    return null;
  }
}

import 'dart:convert';

import 'package:smart_chat/model/response_get_by_id.dart';
import 'package:smart_chat/service/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<ResponseGetById?> fetchGetById() async {
  final prefs = await SharedPreferences.getInstance();
  final String? savedUserId = prefs.getString('userid'); // Lấy đúng key và kiểu

  print('userId: $savedUserId');
  if (savedUserId == null) {
    return null;
  }

  final String apiUrl = '${ApiConfig.baseUrlBasic}users/get-by-id/$savedUserId';

  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return ResponseGetById.fromJson(jsonData);
    } else {
      print("Failed to load data: ${response.statusCode}");
    }
  } catch (e) {
    print("Error: $e");
  }
  return null;
}

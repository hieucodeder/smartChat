import 'dart:convert';
import 'package:smart_chat/model/get_code_model.dart';
import 'package:smart_chat/service/app_config.dart';
import 'package:http/http.dart' as http;

Future<GetCodeModel?> fetchGetCodeModel(String code) async {
  final String apiUrl = '${ApiConfig.baseUrl}get-by-code/$code';

  try {
    final response = await http.get(Uri.parse(apiUrl));
    print(response.body);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return GetCodeModel.fromJson(jsonData);
    } else {
      print("Failed to load data: ${response.statusCode}");
    }
  } catch (e) {
    print("Error: $e");
  }
  return null;
}

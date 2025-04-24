import 'dart:convert';
import 'dart:io';
import 'package:smart_chat/model/get_package_product_response.dart';
import 'package:smart_chat/service/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<GetPackageProductResponse?> fetchGetPackageProduct() async {
  try {
    // Retrieve userId from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userid');

    if (userId == null || userId.isEmpty) {
      print("Error: User ID is null or empty");
      return null;
    }

    final Uri apiUrl = Uri.parse(
        '${ApiConfig.baseUrlBasic}user-package/get-user-active-package/$userId');

    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return GetPackageProductResponse.fromJson(jsonData);
    } else {
      print(
          "Failed to load data: ${response.statusCode}, Response: ${response.body}");
    }
  } on SocketException {
    print("Error: No Internet connection.");
  } on FormatException {
    print("Error: Invalid JSON format.");
  } catch (e) {
    print("Unexpected Error: $e");
  }

  return null;
}

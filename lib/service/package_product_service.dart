import 'dart:convert';
import 'package:smart_chat/model/body_package_product.dart';
import 'package:smart_chat/model/package_product_response.dart';
import 'package:smart_chat/service/app_config.dart';
import 'package:http/http.dart' as http;

Future<PackageProductResponse?> fetchAllPackageProduct(
    String? searchContent, String? packageProductName) async {
  final String apiUrl = '${ApiConfig.baseUrlBasic}/package-product/search';

  try {
    // Tạo request body
    final requestBody = BodyPackageProduct(
      pageIndex: 1,
      pageSize: 100000,
      searchContent: searchContent,
      packageProductName: packageProductName,
    );

    final String body = jsonEncode(requestBody.toJson());
    final Map<String, String> headers = await ApiConfig.getHeaders();

    // Gửi request
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse is Map<String, dynamic>) {
        return PackageProductResponse.fromJson(jsonResponse);
      } else {
        throw Exception("Unexpected response format: ${response.body}");
      }
    } else {
      throw Exception(
          "Failed to fetch data. Status code: ${response.statusCode}, Body: ${response.body}");
    }
  } catch (e) {
    print('Error fetching package product: $e');
    return null;
  }
}

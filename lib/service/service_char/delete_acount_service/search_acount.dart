import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_chat/model/delete_acount/request_seach.dart';
import 'package:smart_chat/model/delete_acount/response_search.dart';
import 'package:smart_chat/service/app_config.dart';

Future<Data?> fetchCurrentUserFromSearch(RequestSeach requestSearch) async {
  const String apiUrl = 'https://admin.smartchat.com.vn/api/customers/search';

  try {
    // Lấy userId đã lưu sau khi đăng nhập
    final prefs = await SharedPreferences.getInstance();
    final String? currentUserId = prefs.getString('userid');

    if (currentUserId == null) {
      print('UserId not found in SharedPreferences');
      return null;
    }

    // Gọi API tìm kiếm
    final String body = jsonEncode(requestSearch.toJson());
    final Map<String, String> headers = await ApiConfig.getHeaders();

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final ResponseSearch res = ResponseSearch.fromJson(responseData);

      // Tìm user trùng userId
      final matchedUser = res.data?.firstWhere(
        (user) => user.userId == currentUserId,
        orElse: () => Data(), // trả về rỗng nếu không tìm thấy
      );

      if (matchedUser?.userId == null) {
        print('Không tìm thấy userId khớp trong kết quả tìm kiếm');
        return null;
      }

      return matchedUser;
    } else {
      print('Status Code != 200: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error in fetchCurrentUserFromSearch: $e');
    return null;
  }
}

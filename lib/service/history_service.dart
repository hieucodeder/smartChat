import 'dart:convert';
import 'package:chatbotbnn/service/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:chatbotbnn/model/body_history.dart';
import 'package:chatbotbnn/model/history_model.dart';

List<Map<String, dynamic>> tempHistory = []; // Mảng toàn cục lưu history

Future<List<Map<String, dynamic>>> fetchChatHistory(String historyId) async {
  final String apiUrl = '${ApiConfig.baseUrlHistory}get-chatbot-messages';

  final bodyHistory = BodyHistory(history: historyId);
  final body = jsonEncode(bodyHistory.toJson());
  final Map<String, String> headers = await ApiConfig.getHeaders();

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: headers,
    body: body,
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = jsonDecode(response.body);
    final historyModel = HistoryModel.fromJson(responseData);

    tempHistory.clear();

    // Tạo danh sách kết quả
    final List<Map<String, dynamic>> result = [];
    String lastQuery = ''; // Lưu câu hỏi gần nhất để ghép với câu trả lời

    // Duyệt qua từng phần tử trong historyModel.data
    for (var e in historyModel.data ?? []) {
      if (e.messageType == 'question') {
        // Lưu câu hỏi để sử dụng cho câu trả lời tiếp theo
        lastQuery = e.content ?? '';
        print('Câu hỏi: $lastQuery');

        // Thêm câu hỏi vào danh sách kết quả
        result.add({
          'type': 'question',
          'text': lastQuery,
          'query': lastQuery,
          'table': null,
          'suggestions': [],
        });
      } else if (e.messageType == 'answer') {
        final contentJson = jsonDecode(e.content ?? '{}');
        String message = contentJson['message'] ?? '';
        print('Câu trả lời: $message');

        // Xử lý suggestions nếu có
        List<String> suggestions = [];
        if (contentJson.containsKey('suggestions')) {
          if (contentJson['suggestions'] is List) {
            suggestions = List<String>.from(contentJson['suggestions']);
          }
        }

        // Thêm cặp query-answer vào result
        result.add({
          'type': 'answer',
          'query': lastQuery, // Dùng câu hỏi trước đó
          'text': message,
          'table': (contentJson['table'] as List?)
              ?.map((item) => (item as Map<String, dynamic>))
              .toList(),
          'suggestions': suggestions,
        });
      }
    }

    tempHistory.addAll(result);
    return result;
  } else {
    throw Exception('Failed to load chat history: ${response.statusCode}');
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:smart_chat/service/app_config.dart';
import 'package:smart_chat/model/response_bot_config.dart';

Future<List<Data>> fetchChatbotConfigPotential(
    String chatbotCode, String? isForm) async {
  try {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrlBasic}chatbot-config/get-chatbot-config'),
      headers: await ApiConfig.getHeaders(),
      body: jsonEncode({'chatbot_code': chatbotCode, 'is_form': isForm}),
    );

    if (response.statusCode == 200) {
      String responseBody = response.body.trim();
      debugPrint("📥 JSON từ API: ${responseBody.length} ký tự");

      if (responseBody.isEmpty ||
          responseBody.startsWith('<!DOCTYPE') ||
          responseBody.startsWith('<html')) {
        throw Exception('❌ Phản hồi không hợp lệ hoặc lỗi từ server.');
      }

      if (!(responseBody.startsWith('{') || responseBody.startsWith('['))) {
        throw Exception('❌ Dữ liệu không phải JSON hợp lệ.');
      }

      try {
        final decodedJson = jsonDecode(responseBody);

        if (decodedJson is! Map<String, dynamic>) {
          throw Exception('❌ JSON không đúng cấu trúc mong đợi.');
        }

        final responseBotConfig = ResponseBotConfig.fromJson(decodedJson);
        final result = responseBotConfig.data ?? [];

        // Xử lý slots_config cho mỗi Data item
        for (var data in result) {
          if (data.slotsConfig != null && data.slotsConfig!.isNotEmpty) {
            try {
              final slotsConfigJson = jsonDecode(data.slotsConfig!);
              if (slotsConfigJson is List) {
                data.slots =
                    slotsConfigJson.map((e) => SlotConfig.fromJson(e)).toList();
              }
            } catch (e) {
              debugPrint("❌ Lỗi khi parse slots_config: $e");
            }
          }
        }

        return result;
      } on FormatException catch (jsonError) {
        debugPrint("❌ JSON không hợp lệ: $jsonError");
        debugPrint("📄 Nội dung JSON lỗi: $responseBody");
        throw Exception('❌ Lỗi giải mã JSON.');
      }
    } else {
      throw Exception(
          '❌ Lỗi HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  } catch (e) {
    debugPrint("❌ Lỗi xử lý: $e");
    return [];
  }
}

extension DataExtension on Data {
  List<Map<String, dynamic>> getIntentSlotsWithCount() {
    if (slots is List<SlotConfig>) {
      return (slots as List<SlotConfig>)
          .where((slot) => (slot.intentSlots ?? '').isNotEmpty)
          .map((slot) => {
                'intentSlot': slot.intentSlots!,
                'count': slot.count ?? 0,
              })
          .toList();
    }
    return [];
  }
}

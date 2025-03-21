import 'dart:convert';

import 'package:chatbotbnn/model/body_create_chatbot.dart';
import 'package:chatbotbnn/model/chatbot_config.dart';
import 'package:chatbotbnn/model/response_createchatbot.dart';
import 'package:chatbotbnn/provider/chatbot_provider.dart';
import 'package:chatbotbnn/service/chatbot_config_service.dart';
import 'package:chatbotbnn/service/create_chatbot_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateChatbotPage extends StatefulWidget {
  const CreateChatbotPage({super.key});

  @override
  State<CreateChatbotPage> createState() => _CreateChatbotPageState();
}

class _CreateChatbotPageState extends State<CreateChatbotPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadChatbotConfig();
  }

  Future<DataConfig?> loadChatbotConfig() async {
    final chatbotCode =
        Provider.of<ChatbotProvider>(context, listen: false).currentChatbotCode;

    try {
      List<DataConfig> chatbotConfig = await fetchChatbotConfig(chatbotCode!);

      if (chatbotConfig.isEmpty) {
        throw Exception('❌ Không tìm thấy cấu hình chatbot.');
      }

      final config = chatbotConfig.first;
      return config;
    } catch (error) {
      debugPrint("❌ Lỗi khi tải cấu hình chatbot: $error");
      return null;
    }
  }

  void callApiCreateChatbot(BuildContext context) async {
    if (_controller.text.trim().isEmpty) {
      return;
    }

    String userQuery = _controller.text.trim();
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userid');
    // Lấy cấu hình chatbot
    DataConfig? chatbotConfig = await loadChatbotConfig();

    if (chatbotConfig == null) {
      debugPrint("⚠️ Không thể tải cấu hình chatbot.");
      return;
    }
    // Dữ liệu gửi lên API
    BodyCreateChatbot chatbotRequest = BodyCreateChatbot(
        chatbotName: userQuery,
        userIndustry: chatbotConfig.userIndustry,
        systemPrompt: chatbotConfig.systemPrompt,
        userId: userId,
        groupId: -1,
        totalCount: 0,
        files: [],
        text: "",
        websites: [],
        qa: [],
        picture: "",
        lang: chatbotConfig.lang,
        chatModel: chatbotConfig.modelGenerate,
        fallbackResponse: chatbotConfig.fallbackResponse);
    debugPrint('Body: ${jsonEncode(chatbotRequest.toJson())}');

    // Gọi API
    ResponseCreatechatbot? response =
        await fetchApiResponseCreateChatbot(chatbotRequest);

    // Kiểm tra phản hồi từ API
    if (response != null && response.results == true) {
      // Hiển thị thông báo khi tạo chatbot thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Chatbot đã tạo thành công: ${response.message}")),
      );
    } else {
      // Hiển thị lỗi nếu API thất bại
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tạo chatbot!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Taọ trợ lý AI',
              style: GoogleFonts.robotoCondensed(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // Thanh nhập tên trợ lý AI
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Nhập tên Trợ lý AI của bạn",
                      hintStyle: GoogleFonts.robotoCondensed(fontSize: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    callApiCreateChatbot(context);
                  },
                  icon: Icon(Icons.add),
                  label: Text("Khởi tạo"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),

            // Danh sách các bước
            Expanded(
              child: ListView(
                children: [
                  buildStepItem(
                      "01. Tạo Trợ lý AI",
                      "Nhập tên trợ lý AI theo mong muốn của bạn.",
                      LucideIcons.plus),
                  buildStepItem(
                      "02. Nhập dữ liệu",
                      "Cung cấp tài liệu, câu hỏi mẫu hoặc kết nối dữ liệu.",
                      LucideIcons.folder),
                  buildStepItem(
                      "03. Huấn luyện",
                      "Huấn luyện AI với dữ liệu bạn đã nhập.",
                      LucideIcons.play),
                  buildStepItem(
                      "04. Trải nghiệm thử",
                      "Trò chuyện để kiểm tra và tinh chỉnh AI.",
                      LucideIcons.messageCircle),
                  buildStepItem(
                      "05. Triển khai",
                      "Tích hợp AI vào web, Messenger, Zalo OA.",
                      LucideIcons.link),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStepItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.black),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

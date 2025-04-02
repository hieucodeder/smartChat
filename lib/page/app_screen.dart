import 'package:chatbotbnn/model/body_history.dart';
import 'package:chatbotbnn/navigation/drawer.dart';
import 'package:chatbotbnn/page/chat_page.dart';
import 'package:chatbotbnn/page/chatbot_page.dart';
import 'package:chatbotbnn/page/create_chatbot_page.dart';
import 'package:chatbotbnn/page/dasboard_page.dart';
import 'package:chatbotbnn/page/information_page.dart';
import 'package:chatbotbnn/page/potential_customers.dart';
import 'package:chatbotbnn/page/package_product_page.dart';
import 'package:chatbotbnn/page/setting_page.dart';
import 'package:chatbotbnn/provider/chat_provider.dart';
import 'package:chatbotbnn/provider/navigation_provider.dart';
import 'package:chatbotbnn/provider/provider_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  Widget _getPage(
    int index, {
    String history = '',
  }) {
    switch (index) {
      case 0:
        return ChatPage(
          historyId: history,
        );
      case 1:
        return ChatbotPage(
          onSelected: (int selectedIndex) {
            setState(() {
              final navigationProvider =
                  Provider.of<NavigationProvider>(context, listen: false);
              navigationProvider.setCurrentIndex(selectedIndex);
            });
          },
        );
      case 2:
        return const SettingPage();
      case 3:
        return const InformationPage();
      case 4:
        return const DasboardPage();
      case 5:
        return const PackageProductPage();
      case 6:
        return const PotentialCustomers();
      case 7:
        return const CreateChatbotPage();
      default:
        return const Center(
          child: Text(
            'Trang không tồn tại',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        );
    }
  }

  Future<String?> getChatbotName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('chatbot_name');
  }

  Future<String> _getAppBarTitle(BuildContext context, int index) async {
    switch (index) {
      case 0:
        String? chatbotName = await getChatbotName();

        return chatbotName ?? 'TRỢ LÝ AI'; // Nếu không có, hiển thị mặc định
      case 1:
        return 'DANH SÁCH TRỢ LÝ AI';
      case 2:
        return 'CÀI ĐẶT';
      case 3:
        return 'THÔNG TIN CÁ NHÂN';
      case 4:
        return 'BẢNG ĐIỀU KHIỂN';
      case 5:
        return 'GÓI DỊCH VỤ';
      case 6:
        return 'KHÁCH HÀNG TIỀM NĂNG';
      case 7:
        return 'TẠO TRỢ LÝ AI';
      default:
        return 'activity_report';
    }
  }

  bool isExpanded = false;

  void _toggleButtons() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  BodyHistory bodyHistory = BodyHistory();
  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final currentIndex = navigationProvider.currentIndex;
    final selectedColor = Provider.of<Providercolor>(context).selectedColor;

    return Scaffold(
      drawer: DrawerCustom(
        onItemSelected: (index) {
          navigationProvider.setCurrentIndex(index);
          Navigator.pop(context);
        },
        bodyHistory: bodyHistory,
      ),
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: _getAppBarTitle(context, currentIndex),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Đang tải...');
            } else if (snapshot.hasError) {
              return const Text('Lỗi tải tên');
            } else {
              return Text(
                (snapshot.data ?? 'TRỢ LÝ AI').toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 17,
                  color: selectedColor == Colors.white
                      ? Colors.white
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () {
                Provider.of<ChatProvider>(context, listen: false)
                    .loadInitialMessage(context);
              },
              icon: const Icon(Icons.replay_outlined),
            ),
          )
        ],
        iconTheme: IconThemeData(
          color: selectedColor == Colors.white ? Colors.white : Colors.white,
        ),
        centerTitle: true,
        backgroundColor: selectedColor == Colors.white
            ? Color(0xFFFef6622)
            : selectedColor, // 🌟 Thay đổi màu toàn bộ AppBar
      ),
      body: _getPage(currentIndex),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

import 'package:chatbotbnn/model/chatbot_info.dart';
import 'package:chatbotbnn/page/create_chatbot_page.dart';
import 'package:chatbotbnn/provider/chatbot_provider.dart';
import 'package:chatbotbnn/provider/chatbotcolors_provider.dart';
import 'package:chatbotbnn/provider/chatbotname_provider.dart';
import 'package:chatbotbnn/provider/draw_selected_color_provider.dart';
import 'package:chatbotbnn/provider/historyid_provider.dart';
import 'package:chatbotbnn/provider/navigation_provider.dart';
import 'package:chatbotbnn/provider/provider_color.dart';
import 'package:chatbotbnn/provider/selected_item_provider.dart';
import 'package:chatbotbnn/service/app_config.dart';
import 'package:chatbotbnn/service/chatbot_service.dart';
import 'package:chatbotbnn/service/role_service.dart';
import 'package:flutter/material.dart';
import 'package:chatbotbnn/model/body_role.dart';
import 'package:chatbotbnn/model/role_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatbotPage extends StatefulWidget {
  final Function(int) onSelected;
  const ChatbotPage({super.key, required this.onSelected});

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  List<Data> chatbotList = [];
  bool isLoading = true;
  int? selectedIndex;
  bool isActive = true;
  List<String> chatbotNames = [];

  @override
  void initState() {
    super.initState();
    _loadChatbots();
  }

  void loadChatbotNames() {
    if (chatbotList.isNotEmpty) {
      List<ChatbotInfo> chatbotData = chatbotList.map((chatbot) {
        return ChatbotInfo(
            name: chatbot.chatbotName ?? "No Name",
            code: chatbot.chatbotCode ?? "",
            createdAt: chatbot.createdAt ?? "",
            updatedAt: chatbot.updatedAt ?? "",
            userId: chatbot.userId ?? "");
      }).toList();

      Provider.of<ChatbotnameProvider>(context, listen: false)
          .updateChatbotList(chatbotData);

      print('Danh sách chatbot: $chatbotData');
    }
  }

  Future<void> _loadChatbots() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userid');

    BodyRole bodyRole = BodyRole(
      pageIndex: 1,
      pageSize: '10000000',
      userId: userId,
      searchText: '',
    );

    RoleModel? roleModel = await fetchRoles(bodyRole);

    if (roleModel != null && roleModel.data != null) {
      setState(() {
        chatbotList = roleModel.data!;
        isLoading = false;
      });
      loadChatbotNames();

      if (chatbotList.isNotEmpty) {
        String? savedChatbotName = prefs.getString('chatbot_name');

        // Tìm chatbot có tên trùng với chatbot đã lưu
        int selectedIndex = chatbotList
            .indexWhere((chatbot) => chatbot.chatbotName == savedChatbotName);

        // Nếu không tìm thấy, chọn chatbot đầu tiên
        if (selectedIndex == -1) selectedIndex = 0;

        await prefs.setString('chatbot_name',
            chatbotList[selectedIndex].chatbotName ?? 'no name');
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAndNavigate() async {
    final chatbotCode =
        Provider.of<ChatbotProvider>(context, listen: false).currentChatbotCode;
    final drawProvider =
        Provider.of<DrawSelectedColorProvider>(context, listen: false);
    final selectedItemProvider =
        Provider.of<SelectedItemProvider>(context, listen: false);

    if (chatbotCode != null) {
      setState(() {
        isLoading = true;
      });

      try {
        final result = await fetchGetCodeModel(chatbotCode);
        // Điều hướng về ChatPage (index 0)
        Provider.of<NavigationProvider>(context, listen: false)
            .setCurrentIndex(0);

        if (result != null) {
          drawProvider.setSelectedIndex(0);
          selectedItemProvider.setSelectedIndex(-1);
        } else {
          // Xử lý khi result là null
          selectedItemProvider.setSelectedIndex(-1);
        }
      } catch (e) {
        // Xử lý lỗi nếu cần
        print('Error fetching code model: $e');
        selectedItemProvider.setSelectedIndex(-1);
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      // Xử lý khi chatbotCode là null nếu cần
      selectedItemProvider
          .setSelectedIndex(-1); // Đặt trạng thái chưa chọn item nào
    }
  }

  String formatDateTime(String dateTimeStr) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return 'Không xác định';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Provider.of<Providercolor>(context).selectedColor;
    return LayoutBuilder(builder: (context, contraints) {
      double maxWidth = contraints.maxWidth;
      return Container(
        width: maxWidth,
        color: Colors.white,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : chatbotList.isEmpty
                ? const Center(
                    child: Text('No chatbots found.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: chatbotList.length,
                    itemBuilder: (context, index) {
                      final chatbot = chatbotList[index];
                      return GestureDetector(
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();

                          Provider.of<ChatbotcolorsProvider>(context,
                                  listen: false)
                              .setSelectedIndex(index);

                          setState(() {
                            selectedIndex = index;
                          });
                          await prefs.setString(
                              'chatbot_name', chatbot.chatbotName ?? '');
                          await prefs.setString(
                              'chatbot_picture', chatbot.picture ?? "");
                          if (chatbot.chatbotCode != null) {
                            Provider.of<ChatbotProvider>(context, listen: false)
                                .setChatbotCode(chatbot.chatbotCode!);

                            Provider.of<HistoryidProvider>(context,
                                    listen: false)
                                .setChatbotHistoryId('');
                            _fetchAndNavigate();
                          }
                        },
                        child: SizedBox(
                          width: maxWidth,
                          child: Consumer<ChatbotcolorsProvider>(
                            builder: (context, chatbotcolorsProvider, child) {
                              bool isSelected =
                                  chatbotcolorsProvider.selectedIndex == index;

                              return Card(
                                color: isSelected
                                    ? Color.fromARGB(
                                        255, 255, 245, 234) // Màu cam sáng
                                    : Colors.white,
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,

                                          border: Border.all(
                                              color: Colors.grey.shade400,
                                              width: 1), // Viền trắng
                                        ),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          foregroundImage: chatbot.picture !=
                                                      null &&
                                                  chatbot.picture!.isNotEmpty
                                              ? NetworkImage(
                                                  "${ApiConfig.baseUrlBasic}${chatbot.picture!}",
                                                )
                                              : const AssetImage(
                                                  'resources/Smartchat.png',
                                                ) as ImageProvider,
                                          radius: 30,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    chatbot.chatbotName ??
                                                        'No Name',
                                                    style: GoogleFonts.inter(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isSelected
                                                            ? Color(0xFFF28411)
                                                            : Colors.black),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:
                                                      40, // Điều chỉnh kích thước phù hợp
                                                  height: 40,
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      // Vòng tròn nền (màu xám)
                                                      CircularProgressIndicator(
                                                        value:
                                                            1, // Vòng tròn nền luôn đầy
                                                        strokeWidth: 4,
                                                        backgroundColor: Colors
                                                            .grey.shade300,
                                                        valueColor:
                                                            const AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Colors
                                                                    .transparent),
                                                      ),
                                                      // Vòng tròn tiến trình (màu cam)
                                                      CircularProgressIndicator(
                                                        value: 80 /
                                                            100, // Giá trị từ 0-1
                                                        strokeWidth: 3,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                isSelected
                                                                    ? Color(
                                                                        0xFFF04A23)
                                                                    : color ==
                                                                            Colors
                                                                                .white
                                                                        ? Color(
                                                                            0xFFF04A23)
                                                                        : color),
                                                      ),
                                                      // Hiển thị phần trăm ở giữa
                                                      Text(
                                                        "80%",
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              (chatbot.description
                                                          ?.isNotEmpty ==
                                                      true)
                                                  ? chatbot.description!
                                                  : 'Trợ lý AI thông minh, sẵn sàng hỗ trợ bạn 24/7!',
                                              maxLines: 1,
                                              overflow: TextOverflow
                                                  .ellipsis, // Thêm để tránh tràn chữ
                                              style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  color: isSelected
                                                      ? Color(0xFFF28411)
                                                      : Colors.black),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Icon(Icons.access_time,
                                                    size: 14,
                                                    color: isSelected
                                                        ? Color(0xFFF28411)
                                                        : Colors.blueGrey),
                                                const SizedBox(
                                                  width: 4,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    'Lần cập nhật cuối: ${formatDateTime(chatbot.updatedAt ?? '')}',
                                                    style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        color: isSelected
                                                            ? Color(0xFFF28411)
                                                            : Colors.blueGrey),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),

                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Switch(
                                                    value: (chatbot.isActive ??
                                                            0) ==
                                                        1, // Ép kiểu int -> bool
                                                    onChanged: (bool value) {
                                                      setState(() {
                                                        isActive = value;
                                                      });
                                                      // Cập nhật trạng thái mới (1 = hoạt động, 0 = không hoạt động)
                                                      int newStatus =
                                                          value ? 1 : 0;
                                                      print(
                                                          "Trạng thái mới: $newStatus");
                                                    },
                                                    activeColor: isSelected
                                                        ? Color(0xFFF04A23)
                                                        : color == Colors.white
                                                            ? Color(0xFFF04A23)
                                                            : color,
                                                  ),
                                                ),
                                                // const Icon(
                                                //   Icons.edit_outlined,
                                                //   size: 20,
                                                // ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
      );
    });
  }
}

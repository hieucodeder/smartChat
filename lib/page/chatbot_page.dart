import 'dart:convert';

import 'package:chatbotbnn/model/chatbot_info.dart';
import 'package:chatbotbnn/model/response_get_code.dart';
import 'package:chatbotbnn/model/resquest_update_chatbot.dart';
import 'package:chatbotbnn/provider/chatbot_provider.dart';
import 'package:chatbotbnn/provider/chatbotcolors_provider.dart';
import 'package:chatbotbnn/provider/chatbotname_provider.dart';
import 'package:chatbotbnn/provider/draw_selected_color_provider.dart';
import 'package:chatbotbnn/provider/historyid_provider.dart';
import 'package:chatbotbnn/provider/menu_state_provider.dart';
import 'package:chatbotbnn/provider/navigation_provider.dart';
import 'package:chatbotbnn/provider/platform_provider.dart';
import 'package:chatbotbnn/provider/provider_color.dart';
import 'package:chatbotbnn/provider/selected_item_provider.dart';
import 'package:chatbotbnn/service/app_config.dart';
import 'package:chatbotbnn/service/chatbot_service.dart';
import 'package:chatbotbnn/service/get_code_service.dart';
import 'package:chatbotbnn/service/role_service.dart';
import 'package:chatbotbnn/service/update_chatbot_service.dart';
import 'package:flutter/material.dart';
import 'package:chatbotbnn/model/body_role.dart';
import 'package:chatbotbnn/model/role_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
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

  List<String> chatbotNames = [];
  Map<String, List<Map<String, dynamic>>> chatbotProgress = {};
  bool isActive = true;
  ResponseGetCode? chatbotData;
  List<ResponseGetCode> chatbotListData = [];
  @override
  void initState() {
    super.initState();
    _loadChatbots();
    _loadChatbotsCode();
  }

  // Modified _loadChatbotsCode
  Future<void> _loadChatbotsCode() async {
    chatbotListData = []; // Clear existing data

    // Load data for all chatbots in parallel
    final futures = chatbotList.map((chatbot) async {
      try {
        return await fetchGetChatBotCode(chatbot.chatbotCode ?? '');
      } catch (e) {
        print('Error loading chatbot ${chatbot.chatbotCode}: $e');
        return null;
      }
    }).toList();

    final results = await Future.wait(futures);

    setState(() {
      chatbotListData = results.whereType<ResponseGetCode>().toList();
    });
  }

  Future<void> _updateChatbotStatusForItem(ResponseGetCode chatbotData) async {
    try {
      print(
          "🔄 Đang cập nhật trạng thái cho chatbot: ${chatbotData.chatbotName}");

      // Tạo request với dữ liệu của chatbot hiện tại
      final request = ResquestUpdateChatbot(
        chatIcon: chatbotData.chatIcon,
        chatbotCode: chatbotData.chatbotCode,
        chatbotName: chatbotData.chatbotName,
        createdAt: chatbotData.createdAt,
        description: chatbotData.description,
        displayName: chatbotData.displayName,
        footer: chatbotData.footer,
        groupId: chatbotData.groupId,
        id: chatbotData.id,
        initialMessages: chatbotData.initialMessages,
        isActive: chatbotData.isActive, // Sử dụng trạng thái của item hiện tại
        isEmbed: chatbotData.isEmbed,
        isRemoved: chatbotData.isRemoved,
        isSyncHeader: chatbotData.isSyncHeader,
        messagePlaceholder: chatbotData.messagePlaceholder,
        picture: chatbotData.picture,
        progress: chatbotData.progress,
        suggestedMessages: chatbotData.suggestedMessages,
        theme: chatbotData.theme,
        totalCount: chatbotData.totalCount,
        totalMessages: chatbotData.totalMessages,
        updatedAt: chatbotData.updatedAt,
        userId: chatbotData.userId,
        userMessageColor: chatbotData.userMessageColor,
      );
      print("isActive: ${chatbotData.isActive}");

      // Gọi API để cập nhật
      final response = await fetchApiResponseUpdateChatbot(request);

      if (response != null && response.results == true) {
        print("✅ Cập nhật thành công: ${response.message}");
      } else {
        print(
            "❌ Cập nhật thất bại: ${response?.message ?? 'Không có phản hồi từ API'}");
        // Nếu thất bại, có thể khôi phục trạng thái cũ
        setState(() {
          chatbotData.isActive =
              (chatbotData.isActive == 1) ? 0 : 1; // Đảo ngược lại
        });
      }
    } catch (e) {
      print("⚠️ Lỗi khi cập nhật chatbot: $e");
      setState(() {
        chatbotData.isActive =
            (chatbotData.isActive == 1) ? 0 : 1; // Đảo ngược lại nếu lỗi
      });
    }
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

      // Load chatbot names
      loadChatbotNames();
      _loadChatbotsCode();

      if (chatbotList.isNotEmpty) {
        String? savedChatbotName = prefs.getString('chatbot_name');

        // Xử lý trường hợp savedChatbotName null hoặc rỗng
        int selectedIndex = -1; // Mặc định chọn index 0

        if (savedChatbotName != null && savedChatbotName.isNotEmpty) {
          selectedIndex = chatbotList
              .indexWhere((chatbot) => chatbot.chatbotName == savedChatbotName);

          // Nếu không tìm thấy hoặc index không hợp lệ, chọn mặc định
          if (selectedIndex == -1 || selectedIndex >= chatbotList.length) {
            selectedIndex = -1;
          }
        }

        // Lưu lại chatbot đã chọn
        await prefs.setString('chatbot_name',
            chatbotList[selectedIndex].chatbotName ?? 'no name');
      } else {
        await prefs.setString(
            'chatbot_name', 'default_chatbot'); // Giá trị mặc định
      }

      // Run background API calls to fetch progress for each chatbot
      List<String> chatbotCodes =
          chatbotList.map((chatbot) => chatbot.chatbotCode ?? '').toList();
      await _runBackgroundApiCalls(chatbotCodes);
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _runBackgroundApiCalls(List<String> chatbotCodes) async {
    final prefs = await SharedPreferences.getInstance();
    for (String code in chatbotCodes) {
      try {
        final String apiUrl = '${ApiConfig.baseUrl}get-by-code/$code';
        final Map<String, String> headers = await ApiConfig.getHeaders();

        final response = await http.get(
          Uri.parse(apiUrl),
          headers: headers,
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          // Parse response into class ResponseGetCode
          ResponseGetCode chatbotData = ResponseGetCode.fromJson(responseData);

          print('Success for chatbotCode $code:');
          print('isActive: ${chatbotData.isActive}');
          print('progress: ${chatbotData.progress}');

          await _updateChatbotStatusForItem(chatbotData);

          // Store the chatbotData temporarily
          await prefs.setString(
              'chatbot_data_$code', jsonEncode(chatbotData.toJson()));

          if (chatbotData.progress != null) {
            try {
              List<dynamic> progressList = jsonDecode(chatbotData.progress!);

              List<Map<String, dynamic>> progressItems = progressList
                  .map((item) => {
                        'id': item['id'] as String?,
                        'value': item['value'] as int?,
                      })
                  .toList();

              // Calculate total progress
              int totalProgress = progressItems.fold(
                0,
                (sum, item) => sum + ((item['value'] as num?)?.toInt() ?? 0),
              );

              print('Progress for $code:');
              for (var item in progressItems) {
                print('${item['id']}: ${item['value']}');
              }

              print('Total progress for $code: $totalProgress');

              // Update UI with progress information
              setState(() {
                // You can use this to store progress per chatbot code or globally
                chatbotProgress[code] = progressItems;
              });
            } catch (e) {
              print('Error parsing progress for $code: $e');
            }
          } else {
            print('No progress data found for $code');
          }
        } else {
          print('Failed for chatbotCode $code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error processing chatbotCode $code: $e');
      }
    }
  }

  Future<void> _fetchAndNavigate() async {
    final chatbotCode =
        Provider.of<ChatbotProvider>(context, listen: false).currentChatbotCode;
    final drawProvider =
        Provider.of<DrawSelectedColorProvider>(context, listen: false);
    final selectedItemProvider =
        Provider.of<SelectedItemProvider>(context, listen: false);
    Provider.of<PlatformProvider>(context, listen: false).resetPlatform();
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
                      String code = chatbotList[index].chatbotCode ?? '';
                      double progress = chatbotProgress[code]?.fold(
                              0, (sum, item) => sum! + (item['value'] ?? 0)) ??
                          0;
                      // Check if we have data for this index
                      bool hasData = index < chatbotListData.length;
                      int isActive =
                          hasData ? (chatbotListData[index].isActive ?? 0) : 0;
                      return GestureDetector(
                        onTap: () async {
                          try {
                            // Lấy SharedPreferences instance
                            final prefs = await SharedPreferences.getInstance();

                            // Cập nhật các provider
                            Provider.of<MenuStateProvider>(context,
                                    listen: false)
                                .setPotentialCustomer(true);
                            Provider.of<ChatbotcolorsProvider>(context,
                                    listen: false)
                                .setSelectedIndex(index);

                            // Cập nhật state
                            setState(() {
                              selectedIndex = index;
                            });

                            // Lưu vào SharedPreferences
                            await prefs.setString(
                                'chatbot_name', chatbot.chatbotName ?? '');
                            await prefs.setString(
                                'chatbot_picture', chatbot.picture ?? "");

                            // Kiểm tra và xử lý chatbotCode
                            if (chatbot.chatbotCode != null) {
                              Provider.of<ChatbotProvider>(context,
                                      listen: false)
                                  .setChatbotCode(chatbot.chatbotCode!);
                              Provider.of<HistoryidProvider>(context,
                                      listen: false)
                                  .setChatbotHistoryId('');

                              // Gọi hàm fetch và navigate
                              await _fetchAndNavigate();

                              // Đóng màn hình sau khi hoàn thành
                              if (context.mounted) {
                                // Kiểm tra context còn hợp lệ không
                                Navigator.pop(context);
                              }
                            }
                          } catch (e) {
                            // Xử lý lỗi nếu có
                            print('Error in onTap: $e');
                            if (context.mounted) {
                              Navigator.pop(context); // Vẫn đóng nếu cần
                            }
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
                                    ? const Color.fromARGB(
                                        255, 255, 245, 234) // Màu cam sáng
                                    : Colors.white,
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(
                                    color: Colors.grey, // Màu viền
                                    width: 0.5, // Độ dày viền
                                  ),
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
                                                            ? const Color(
                                                                0xFFFef6622)
                                                            : Colors.black),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:
                                                      35, // Adjust size as needed
                                                  height: 35,
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      // Background circle (gray)
                                                      CircularProgressIndicator(
                                                        value:
                                                            1, // Always full for background circle
                                                        strokeWidth: 4,
                                                        backgroundColor: Colors
                                                            .grey.shade300,
                                                        valueColor:
                                                            const AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Colors
                                                                    .transparent),
                                                      ),
                                                      // Progress circle (orange)
                                                      CircularProgressIndicator(
                                                        value: progress != null
                                                            ? progress / 100
                                                            : 0, // Dynamic progress from 0-1
                                                        strokeWidth: 4,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        valueColor: AlwaysStoppedAnimation<Color>(
                                                            isSelected
                                                                ? const Color(
                                                                    0xFFFef6622)
                                                                : color ==
                                                                        Colors
                                                                            .white
                                                                    ? const Color(
                                                                        0xFFFef6622)
                                                                    : color),
                                                      ),
                                                      // Display percentage in the center
                                                      Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          '${progress != null ? progress.toStringAsFixed(0) : 0}%', // Display percentage
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize:
                                                                10, // Adjust font size
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: color ==
                                                                    Colors.white
                                                                ? const Color(
                                                                    0xFFFef6622)
                                                                : color,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              width: 250,
                                              child: Text(
                                                (chatbot.description
                                                            ?.isNotEmpty ==
                                                        true)
                                                    ? chatbot.description!
                                                    : 'Trợ lý AI thông minh, sẵn sàng hỗ trợ bạn 24/7!',
                                                maxLines: 2,
                                                overflow: TextOverflow
                                                    .ellipsis, // Thêm để tránh tràn chữ
                                                style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    color: isSelected
                                                        ? const Color(
                                                            0xFFFef6622)
                                                        : Colors.black),
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Icon(Icons.access_time,
                                                    size: 13,
                                                    color: isSelected
                                                        ? const Color(
                                                            0xFFF28411)
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
                                                            ? const Color(
                                                                0xFFFef6622)
                                                            : Colors.blueGrey),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),

                                                // Update the switch widget in your ListView.builder:
                                                // In your ListView.builder, add safety checks:
                                                if (hasData)
                                                  SizedBox(
                                                    width: 40,
                                                    child: Transform.scale(
                                                      scale: 0.8,
                                                      child: Switch(
                                                          value: isActive == 1,
                                                          onChanged: (_) {
                                                            setState(() {
                                                              chatbotListData[
                                                                          index]
                                                                      .isActive =
                                                                  (isActive ==
                                                                          1)
                                                                      ? 0
                                                                      : 1;
                                                            });
                                                            _updateChatbotStatusForItem(
                                                                chatbotListData[
                                                                    index]);
                                                          },
                                                          activeColor: color ==
                                                                  Colors.white
                                                              ? const Color(
                                                                  0xFFFef6622)
                                                              : color),
                                                    ),
                                                  )
                                                else
                                                  const SizedBox(
                                                    width: 35,
                                                    height: 35,
                                                    child:
                                                        CircularProgressIndicator(
                                                            strokeWidth: 2),
                                                  ),
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

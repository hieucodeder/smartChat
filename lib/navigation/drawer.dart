// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:chatbotbnn/model/body_history.dart';
import 'package:chatbotbnn/model/delete_model.dart';
import 'package:chatbotbnn/model/history_all_model.dart';
import 'package:chatbotbnn/provider/chat_provider.dart';
import 'package:chatbotbnn/provider/chatbot_provider.dart';
import 'package:chatbotbnn/provider/draw_selected_color_provider.dart';
import 'package:chatbotbnn/provider/historyid_provider.dart';
import 'package:chatbotbnn/provider/provider_color.dart';
import 'package:chatbotbnn/provider/selected_history_provider.dart';
import 'package:chatbotbnn/provider/selected_item_provider.dart';
import 'package:chatbotbnn/service/app_config.dart';
import 'package:chatbotbnn/service/delete_service.dart';
import 'package:chatbotbnn/service/get_package_product_service.dart';
import 'package:chatbotbnn/service/history_all_service.dart';
import 'package:chatbotbnn/service/login_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerCustom extends StatefulWidget {
  final BodyHistory bodyHistory;
  final Function(int) onItemSelected;
  const DrawerCustom(
      {super.key, required this.onItemSelected, required this.bodyHistory});

  @override
  State<DrawerCustom> createState() => _DrawerCustomState();
}

class _DrawerCustomState extends State<DrawerCustom> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<HistoryAllModel> _historyAllModel;
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  String? _selectedKey; // Lưu ID của item được chọn
  String packageProductName = "Đang tải..."; // Mặc định là "Đang tải..."
  Widget packageIcon =
      const Icon(Icons.help_outline, size: 20, color: Colors.white);
  int _selectedIndex = -1; // -1 nghĩa là không có mục nào được chọn ban đầu
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true; // Đánh dấu state đang hoạt động

    _fetchHistoryAllModel();
    fetchPackageProduct();
  }

  Future<void> fetchPackageProduct() async {
    final response = await fetchGetPackageProduct();
    if (!_isMounted) return;

    if (response != null && response.packageProductName != null) {
      setState(() {
        packageProductName = response.packageProductName!;
        packageIcon = getIconForPackage(packageProductName);
      });
    } else {
      setState(() {
        packageProductName = "Gói hết hạn";
      });

      // Hiển thị thông báo và mở drawer
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scaffoldKey.currentState != null) {
          _scaffoldKey.currentState!.openDrawer(); // Mở drawer
        }

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Gói sử dụng của bạn đã hết hạn!',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.asset(
                            'resources/rocket.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Để sử dụng tính năng / dịch vụ, hãy đăng ký gói bên dưới hoặc liên hệ trực tiếp với chúng tôi!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            widget.onItemSelected(5);
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Xem gói khác',
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final url = Uri.parse('https://smartchat.com.vn/');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          child: Text(
                            'Liên hệ',
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      });
    }
  }
  // Future<void> fetchPackageProduct() async {
  //   final response = await fetchGetPackageProduct();
  //   if (!_isMounted) return; // Nếu state bị dispose, không cập nhật UI

  //   if (response != null && response.packageProductName != null) {
  //     setState(() {
  //       packageProductName = response.packageProductName!;
  //       packageIcon = getIconForPackage(packageProductName);
  //     });
  //   } else {
  //     setState(() {
  //       packageProductName = "Gói hết hạn";
  //     });
  //   }
  // }

  Widget getIconForPackage(String name) {
    double iconSize = 18.0; // Điều chỉnh kích thước tại đây

    if (name == "Tùy biến") {
      return SvgPicture.asset(
        'resources/package.svg',
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      );
    }
    if (name == "Cơ bản") {
      return SvgPicture.asset(
        'resources/iconbasic.svg',
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      );
    }
    if (name == "Nâng cao") {
      return SvgPicture.asset(
        'resources/diamond.svg',
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      );
    }
    if (name == "Trải nghiệm") {
      return SvgPicture.asset(
        'resources/iconfree.svg',
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      );
    }

    return Icon(Icons.help_outline, size: iconSize, color: Colors.grey);
  }

  Future<Map<String, String?>> getChatbotInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('chatbot_name'),
      'picture': prefs.getString('chatbot_picture'),
    };
  }

  void _fetchHistoryAllModel() {
    final chatbotCode =
        Provider.of<ChatbotProvider>(context, listen: false).currentChatbotCode;
    setState(() {
      _historyAllModel = fetchChatHistoryAll(chatbotCode, startDate, endDate);
    });
  }

  Future<void> _loadChatHistoryAndNavigate(String? historyId) async {
    try {
      if (historyId != null) {
        Provider.of<HistoryidProvider>(context, listen: false)
            .setChatbotHistoryId(historyId);
      } else {}
    } catch (e) {}
  }

  void _deleteRest() {
    setState(() {
      _fetchHistoryAllModel();
      Navigator.pop(context);
    });
  }

  Future<void> deleteChatHistory(
      BuildContext context, String? historyId) async {
    final styleText = GoogleFonts.inter(fontSize: 14);
    try {
      // Nếu historyId null, lấy từ Provider
      String? historyIdString = historyId ??
          Provider.of<HistoryidProvider>(context, listen: false)
              .chatbotHistoryId;

      // Kiểm tra historyIdString có hợp lệ không
      if (historyIdString == null || historyIdString.isEmpty) {
        print('Lỗi: historyId không hợp lệ');
        return;
      }

      // Chuyển đổi `String` sang `int`
      int? historyIdInt = int.tryParse(historyIdString);
      if (historyIdInt == null || historyIdInt <= 0) {
        print('Lỗi: Không thể chuyển đổi historyId');
        return;
      }

      // Hiển thị hộp thoại xác nhận xóa
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Xác nhận xóa',
            style: styleText,
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa lịch sử chat này không?',
            style: styleText,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Đóng',
                style: styleText,
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Gọi API xóa lịch sử chat
                  DeleteModel result =
                      await fetchChatHistoryDelete(historyIdInt);
                  print(result.message);
                  _deleteRest();

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Thông báo',
                        style: styleText,
                      ),
                      content: Text(
                        'Xóa thành công',
                        style: styleText,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'OK',
                            style: styleText,
                          ),
                        ),
                      ],
                    ),
                  );
                } catch (e) {
                  print('Error: $e');
                  Navigator.of(context).pop();

                  // Hiển thị thông báo lỗi
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Lỗi',
                        style: styleText,
                      ),
                      content: Text(
                        'Có lỗi xảy ra trong quá trình xóa lịch sử.',
                        style: styleText,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Đóng',
                            style: styleText,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('Xóa'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  String? startDate;
  String? endDate;
  final TextEditingController _controller = TextEditingController();
  void _selectDateRange() async {
    try {
      // Chọn ngày bắt đầu
      final DateTime? startPicked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        helpText: "📅 CHỌN NGÀY BẮT ĐẦU", // Viết hoa toàn bộ để dễ đọc

        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.blue, // Màu chính (nút chọn)
                onPrimary: Colors.white, // Màu chữ trên nền chính
                onSurface: Colors.black, // Màu chữ trên nền trắng
              ),
            ),
            child: child == null
                ? const SizedBox() // Tránh lỗi nếu child null
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DefaultTextStyle.merge(
                        style: GoogleFonts.inter(
                          fontSize: 24, // Kích thước lớn hơn
                          fontWeight: FontWeight.bold, // Chữ đậm
                          color: Colors.red, // Màu chữ đỏ
                        ),
                        child: child,
                      ),
                    ],
                  ),
          );
        },
      );

      if (startPicked != null) {
        // Chọn ngày kết thúc
        final DateTime? endPicked = await showDatePicker(
          context: context,
          initialDate: startPicked.add(const Duration(days: 1)),
          firstDate: startPicked,
          lastDate: DateTime(2101),
          helpText: "📅 CHỌN NGÀY KẾT THÚC",
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.green,
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: child == null
                  ? const SizedBox()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DefaultTextStyle.merge(
                          style: GoogleFonts.roboto(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue, // Đổi màu chữ
                          ),
                          child: child,
                        ),
                      ],
                    ),
            );
          },
        );

        if (endPicked != null) {
          setState(() {
            startDate = DateFormat('yyyy-MM-dd').format(startPicked);
            endDate = DateFormat('yyyy-MM-dd').format(endPicked);
            _controller.text = '$startDate - $endDate';
          });

          await _updateDocumentsByDateRange();
        }
      }
    } catch (e) {
      print("Lỗi chọn ngày: $e");
    }
  }

  Future<void> _updateDocumentsByDateRange() async {
    if (startDate != null && endDate != null) {
      final chatbotCode = Provider.of<ChatbotProvider>(context, listen: false)
          .currentChatbotCode;

      setState(() {
        _historyAllModel =
            fetchChatHistoryAll(chatbotCode, startDate!, endDate!);
      });
    }
  }

  void _clearDateRange() {
    if (mounted) {
      final chatbotCode = Provider.of<ChatbotProvider>(context, listen: false)
          .currentChatbotCode;
      setState(() {
        _historyAllModel = fetchChatHistoryAll(chatbotCode, null, null);
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = Provider.of<Providercolor>(context).selectedColor;
    final selectedChatProvider = context.watch<SelectedHistoryProvider>();

    return Drawer(
      key: _scaffoldKey,
      backgroundColor: selectedColor,
      child: SafeArea(
        minimum: const EdgeInsets.only(left: 10, top: 20, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Container(
              width: double.infinity,
              height: 45,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: selectedColor == Colors.white
                      ? Colors.white
                      : Colors.transparent),
              child: Row(
                children: [
                  FutureBuilder<Map<String, String?>>(
                    future: getChatbotInfo(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return Row(
                          children: [
                            const CircleAvatar(
                              backgroundImage:
                                  AssetImage('resources/Smartchat.png'),
                              radius: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'No Name',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: selectedColor == Colors.white
                                    ? Colors.blueGrey
                                    : Colors.white,
                              ),
                            ),
                          ],
                        );
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 3, horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          color: selectedColor == Colors.white
                              ? const Color(0xFFED5113)
                              : Colors.white,
                        ),
                        height: 30,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            packageIcon,
                            const SizedBox(width: 5),
                            Text(
                              packageProductName,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: selectedColor == Colors.white
                                    ? Colors.white
                                    : selectedColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: _buildListTile(
                        context: context,
                        icon: TablerIcons.dashboard,
                        title: 'Bảng điều khiển',
                        index: 4,
                        onTap: () => widget.onItemSelected(4),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: _buildListTile(
                        context: context,
                        icon: TablerIcons.message_dots,
                        index: 0,
                        title: 'Trải nghiệm thử',
                        onTap: () => widget.onItemSelected(0),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: _buildListTile(
                        context: context,
                        icon: TablerIcons.calendar,
                        title: 'Danh sách Trợ lý AI',
                        index: 1,
                        onTap: () => widget.onItemSelected(1),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: _buildListTile(
                        context: context,
                        icon: TablerIcons.user_circle,
                        title: 'Khách hàng tiềm năng',
                        index: 6,
                        onTap: () => widget.onItemSelected(6),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: _buildListTile(
                          context: context,
                          icon: TablerIcons.crown,
                          title: 'Gói dịch vụ',
                          index: 5,
                          onTap: () => widget.onItemSelected(5)),
                    ),
                    Divider(
                      color: selectedColor == Colors.white
                          ? const Color(0xFFED8113).withOpacity(0.6)
                          : Colors.white,
                    ),

                    // Padding(
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 10, vertical: 10),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.start,
                    //     children: [
                    //       CircleAvatar(
                    //         radius: 12,
                    //         backgroundColor: selectedColor == Colors.white
                    //             ? Colors.white
                    //             : selectedColor,
                    //         child: Icon(
                    //           TablerIcons.history,
                    //           color: selectedColor == Colors.white
                    //               ? Colors.black
                    //               : Colors.white,
                    //           size: 20,
                    //         ),
                    //       ),
                    //       const SizedBox(
                    //         width: 6,
                    //       ),
                    //       Text(
                    //         'Lịch sử chat',
                    //         style: GoogleFonts.inter(
                    //             fontSize: 15,
                    //             color: selectedColor == Colors.white
                    //                 ? Colors.black
                    //                 : Colors.white,
                    //             fontWeight: FontWeight.w500),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        FutureBuilder<Map<String, String?>>(
                          future: getChatbotInfo(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            if (snapshot.hasError || !snapshot.hasData) {
                              return Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundImage:
                                        AssetImage('resources/logo_smart.png'),
                                    radius: 20,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'No Name',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              );
                            }

                            final chatbotName =
                                snapshot.data?['name'] ?? 'No Name';
                            final chatbotPicture = snapshot.data?['picture'];

                            return Row(
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  padding: const EdgeInsets.only(
                                    left: 0,
                                    right: 0,
                                    top: 0,
                                    bottom: 0,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(
                                        25), // Adding rounded corners here
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    foregroundImage: chatbotPicture != null &&
                                            chatbotPicture.isNotEmpty
                                        ? NetworkImage(
                                            "${ApiConfig.baseUrlBasic}$chatbotPicture")
                                        : const AssetImage(
                                                'resources/SmartChat.png')
                                            as ImageProvider,
                                    radius: 30,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  chatbotName,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    color: selectedColor == Colors.white
                                        ? const Color(0xFFED3113)
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: _selectDateRange,
                          child: Container(
                            width: double.infinity,
                            height: 38,
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.black38),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: TextField(
                                      controller: _controller,
                                      readOnly: true,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(fontSize: 13),
                                      decoration: InputDecoration(
                                        hintText:
                                            'Chọn ngày bắt đầu và kết thúc',
                                        hintStyle: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: Colors.black45,
                                        ),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_controller.text.isNotEmpty)
                                  GestureDetector(
                                    onTap: _clearDateRange,
                                    child: const Icon(
                                      Icons.close_sharp,
                                      color: Colors.black54,
                                      size: 23,
                                    ),
                                  ),
                                const VerticalDivider(
                                  width: 20,
                                  thickness: 1,
                                  color: Colors.black38,
                                ),
                                GestureDetector(
                                  onTap: _selectDateRange,
                                  child: const Icon(
                                    Icons.calendar_today,
                                    color: Colors.black54,
                                    size: 23,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    FutureBuilder<HistoryAllModel>(
                      future: _historyAllModel,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data == null) {
                          return const Center(child: Text('No data available'));
                        } else {
                          final List<Map<String, String>> contents =
                              (snapshot.data?.data ?? []).map((history) {
                            final chatbotHistoryId =
                                history.chatbotHistoryId?.toString() ??
                                    'Không có ID';

                            final userMessage = (history.messages?.isNotEmpty ??
                                    false)
                                ? history.messages!.lastWhere(
                                    (msg) => msg.messageType != 'bot',
                                    orElse: () =>
                                        Messages(content: 'Không có dữ liệu'),
                                  )
                                : Messages(content: 'Không có dữ liệu');

                            final rawContent =
                                userMessage.content ?? 'Không có dữ liệu';

                            String content;
                            try {
                              final decoded = jsonDecode(rawContent);
                              content = decoded['query'] ?? 'Không có dữ liệu';
                            } catch (e) {
                              content =
                                  rawContent; // Nếu không phải JSON, giữ nguyên
                            }

                            return {
                              'key': chatbotHistoryId,
                              'value': content,
                            };
                          }).toList();

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: contents.length,
                            itemBuilder: (context, index) {
                              final String itemKey =
                                  contents[index]['key'] ?? "";
                              final bool isSelected =
                                  selectedChatProvider.selectedChatId ==
                                      itemKey;
                              return GestureDetector(
                                onTap: () {
                                  selectedChatProvider
                                      .setSelectedChatId(itemKey);
                                  Provider.of<SelectedItemProvider>(context,
                                          listen: false)
                                      .setSelectedIndex(
                                          index); // Lưu index của item được chọn
                                  Future.delayed(
                                      const Duration(milliseconds: 100), () {
                                    _loadChatHistoryAndNavigate(itemKey);
                                    Navigator.pop(context);
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Provider.of<SelectedItemProvider>(
                                                    context)
                                                .selectedIndex ==
                                            index
                                        ? (selectedColor == Colors.white
                                            ? const Color(0xFFEDEDED)
                                            : Colors.white.withOpacity(
                                                0.1)) // Màu khi được chọn với nền tối
                                        : (selectedColor == Colors.white
                                            ? Colors.white
                                            : Colors.transparent),
                                  ),
                                  padding: const EdgeInsets.only(left: 10),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    tileColor: Colors.transparent,
                                    visualDensity: VisualDensity.compact,
                                    minVerticalPadding: 0,
                                    dense: true,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    title: Text(
                                      contents[index]['value'] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 14.0,
                                        color:
                                            Provider.of<SelectedItemProvider>(
                                                            context)
                                                        .selectedIndex ==
                                                    index
                                                ? (selectedColor == Colors.white
                                                    ? const Color(0xFF000000)
                                                    : Colors.white)
                                                : (selectedColor == Colors.white
                                                    ? const Color(0xFF333333)
                                                    : Colors.white),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    trailing: GestureDetector(
                                      onTap: () {
                                        deleteChatHistory(
                                            context, contents[index]['key']);
                                      },
                                      child: Icon(
                                        Icons.more_horiz,
                                        color: selectedColor == Colors.white
                                            ? Colors.black
                                            : Colors.white,
                                        size: 20.0,
                                      ),
                                    ),
                                    onTap: () {
                                      Provider.of<SelectedItemProvider>(context,
                                              listen: false)
                                          .setSelectedIndex(
                                              index); // Cập nhật index khi tap vào ListTile
                                      _loadChatHistoryAndNavigate(
                                          contents[index]['key']);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            _buildUserAccount(),
            // _buildColorSelector(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final selectedColor = Provider.of<Providercolor>(context).selectedColor;
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.menu,
              color: selectedColor == Colors.white
                  ? const Color(0xfffe64f13)
                  : Colors.white,
            ),
            iconSize: 23,
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(
              width: 100,
              height: 50,
              child: Image.asset(
                'resources/Smartchat-1.png',
                fit: BoxFit.contain,
              )),
          IconButton(
              onPressed: () {
                Provider.of<ChatProvider>(context, listen: false)
                    .loadInitialMessage(context);
                Navigator.pop(context);
              },
              icon: SvgPicture.asset(
                'resources/icon_reload.svg',
                fit: BoxFit.cover,
                width: 23,
                height: 23,
                color: selectedColor == Colors.white
                    ? const Color(0xfffe64f13)
                    : Colors.white,
              ))
        ],
      ),
    );
  }

  // Hàm xây dựng ListTile với trạng thái màu từ Provider
  Widget _buildListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required int index,
  }) {
    final provider = Provider.of<DrawSelectedColorProvider>(context);
    bool isSelected = provider.selectedIndex == index;
    final selectedColor = Provider.of<Providercolor>(context).selectedColor;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isSelected
            ? const Color(0xFFED8113).withOpacity(0.2)
            : Colors.transparent,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: ListTile(
                contentPadding: EdgeInsets.zero, // Xóa padding mặc định
                visualDensity: VisualDensity.compact,
                minVerticalPadding: 0,
                horizontalTitleGap: 10, // Đặt về 0 và dùng padding của Text
                dense: true,
                leading: Icon(
                  icon,
                  color: isSelected
                      ? const Color(0xFFED3113)
                      : (selectedColor == Colors.white
                          ? Colors.black
                          : Colors.white),
                  size: 23,
                ),

                title: Text(title,
                    style: GoogleFonts.inter(
                      color: isSelected
                          ? const Color(0xFFED3113)
                          : (selectedColor == Colors.white
                              ? Colors.black
                              : Colors.white),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    )),
                onTap: () {
                  provider.setSelectedIndex(
                      index); // Cập nhật trạng thái trong Provider
                  onTap(); // Gọi hàm onTap gốc
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return ExpansionTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: GoogleFonts.inter(fontSize: 15, color: Colors.white),
      ),
      childrenPadding: const EdgeInsets.only(left: 20.0),
      iconColor: Colors.white,
      collapsedIconColor: Colors.grey,
      children: children,
    );
  }

// _buildUserAccount widget
  Widget _buildUserAccount() {
    final loginService = LoginService();
    final selectedColor = Provider.of<Providercolor>(context).selectedColor;
    return FutureBuilder<Map<String, String>?>(
      future:
          loginService.getAccountFullNameAndUsername(), // Fetch the user data
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const Text(
              "Không có dữ liệu người dùng"); // Xử lý khi không có dữ liệu
        }
        final data = snapshot.data!;
        final imageUrl = data['picture'] ?? '';
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child:
                  const CircularProgressIndicator(), // Show loading indicator
            ),
            title: GestureDetector(
              onTap: () {
                widget.onItemSelected(2);
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Loading...', // Placeholder text
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: selectedColor == Colors.white
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: selectedColor == Colors.white
                            ? Colors.black
                            : Colors.white,
                      ),
                    ],
                  ),
                  Text(
                    'Loading...', // Placeholder text
                    style: GoogleFonts.inter(
                        color: selectedColor == Colors.white
                            ? Colors.black
                            : Colors.white,
                        fontSize: 16,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          );
        }
        // Error state
        else if (snapshot.hasError) {
          return ListTile(
            leading: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                    color: Colors.grey.shade400, width: 1), // Viền trắng
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 23,
                foregroundImage: (imageUrl.isNotEmpty)
                    ? NetworkImage("${ApiConfig.baseUrlBasic}$imageUrl")
                    : const AssetImage('resources/Smartchat.png')
                        as ImageProvider,
              ),
            ),
            contentPadding: EdgeInsets.zero,
            title: GestureDetector(
              onTap: () {
                widget.onItemSelected(2);
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Error loading user info', // Display error message
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: selectedColor == Colors.white
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '',
                    style: GoogleFonts.inter(
                        color: selectedColor == Colors.white
                            ? Colors.black
                            : Colors.white,
                        fontSize: 16,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          );
        }
        // Data successfully fetched
        else if (snapshot.hasData && snapshot.data != null) {
          final userName = snapshot.data?['full_name'] ?? 'Không có tên';
          final email = snapshot.data?['email'] ?? 'Không có email';

          return ListTile(
            leading: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                    color: Colors.grey.shade400, width: 1), // Viền trắng
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 23,
                foregroundImage: (imageUrl.isNotEmpty)
                    ? NetworkImage("${ApiConfig.baseUrlBasic}$imageUrl")
                    : const AssetImage('resources/logoAI.png') as ImageProvider,
              ),
            ),
            contentPadding: EdgeInsets.zero,
            title: GestureDetector(
              onTap: () {
                widget.onItemSelected(2);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        userName,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: selectedColor == Colors.white
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: selectedColor == Colors.white
                            ? Colors.black
                            : Colors.white,
                      ),
                    ],
                  ),
                  Text(
                    email, // Display fetched email
                    style: GoogleFonts.inter(
                      color: selectedColor == Colors.white
                          ? Colors.black
                          : Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(); // Return an empty container if no data or error
      },
    );
  }
}

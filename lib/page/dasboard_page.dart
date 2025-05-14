import 'package:smart_chat/model/char/response_interaction_char.dart';
import 'package:smart_chat/model/char/response_interactionpie.dart';
import 'package:smart_chat/model/char/response_potential_customer.dart';
import 'package:smart_chat/model/char/response_potential_customerpie.dart';
import 'package:smart_chat/model/chatbot_info.dart';
import 'package:smart_chat/model/response_total_count.dart';
import 'package:smart_chat/model/response_total_interaction.dart';
import 'package:smart_chat/model/response_total_potential_customers.dart';
import 'package:smart_chat/model/response_total_question.dart';
import 'package:smart_chat/page/char_page/interaction_char_page.dart';
import 'package:smart_chat/page/char_page/interaction_pie_page.dart';
import 'package:smart_chat/page/char_page/potential_customer_char.dart';
import 'package:smart_chat/page/char_page/potential_customer_piechar.dart';
import 'package:smart_chat/provider/chatbotname_provider.dart';
import 'package:smart_chat/service/service_char/interaction_char.dart';
import 'package:smart_chat/service/service_char/interaction_pie_service.dart';
import 'package:smart_chat/service/service_char/piechar_potential_customer_service.dart';
import 'package:smart_chat/service/service_char/potential_customer_service.dart';
import 'package:smart_chat/service/total_count_service.dart';
import 'package:smart_chat/service/total_potential_customers_service.dart';
import 'package:smart_chat/service/total_question_service.dart';
import 'package:smart_chat/service/total_sessions_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:intl/date_symbol_data_local.dart'; // Thêm thư viện này nếu cần init locale

class DasboardPage extends StatefulWidget {
  const DasboardPage({
    super.key,
  });

  @override
  State<DasboardPage> createState() => _DasboardPageState();
}

class _DasboardPageState extends State<DasboardPage> {
  List<String> chatbotNames = [];
  String? selectedCustomer;
  String? selectedDate;
  int totalQuestions = 0; // Biến để hiển thị số lượng câu hỏi
  int totalInteraction = 0;
  int totalCount = 0;
  int totalPotentialCustomer = 0;
  // List<ResponseInteractionChar> interactionCharList = [];
  List<ResponseInteractionChar> chartData = [];
  List<ResponsePotentialCustomer> charDataPotential = [];
  List<ResponsePotentialCustomerpie> charDataPotentialPieChar = [];
  List<ResponseInteractionpie> charDataInteractionPieChar = [];

  @override
  void initState() {
    super.initState();
    _initializeCurrentMonthData();
  }

  String? startDate;
  String? endDate;

  Future<void> _selectMonth(BuildContext context) async {
    DateTime? pickedDate = await showMonthPicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      DateTime firstDay = DateTime(pickedDate.year, pickedDate.month, 1);
      DateTime lastDay = DateTime(pickedDate.year, pickedDate.month + 1, 0);

      setState(() {
        selectedDate = DateFormat('MM/yyyy').format(pickedDate);
        startDate =
            "${DateFormat('yyyy-MM-dd').format(firstDay)} 0:0:0"; // Định dạng chuẩn
        endDate =
            "${DateFormat('yyyy-MM-dd').format(lastDay)} 23:59:59"; // Định dạng chuẩn
      });

      // Gọi lại API với tháng mới
      _fetchDataTotal(""); // Hoặc truyền chatbotCode
    }
  }

  void _initializeCurrentMonthData() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1); // Ngày đầu tháng
    final lastDay = DateTime(now.year, now.month + 1, 0); // Ngày cuối tháng

    setState(() {
      selectedDate = DateFormat('MM/yyyy').format(now); // Hiển thị "04/2025"
      startDate =
          "${DateFormat('yyyy-MM-dd').format(firstDay)} 0:0:0"; // "2025-04-01 0:0:0"
      endDate =
          "${DateFormat('yyyy-MM-dd').format(lastDay)} 23:59:59"; // "2025-04-30 23:59:59"
    });

    // Gọi API ngay sau khi khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDataTotal(""); // Hoặc truyền chatbotCode nếu có
    });
  }

  Widget renderDateDropdown() {
    List<String> monthItems = List.generate(12, (index) {
      return (index + 1).toString().padLeft(2, '0');
    });

    return buildDropdowCalendar(
      items: monthItems,
      selectedItem: selectedDate,
      hint: "Chọn tháng",
      width: 180,
      onTap: () => _selectMonth(context),
      onChanged: (value) {
        cleanSelectedDate();
      },
    );
  }

  void cleanSelectedDate() {
    setState(() {
      selectedDate = ""; // Xoá tháng đã chọn
    });
    _fetchDataTotalWithoutDate(""); // Gọi API mà không truyền ngày tháng
  }

  Future<void> _fetchDataTotalWithoutDate(String? chatbotCode) async {
    try {
      final results = await Future.wait([
        fetchAllTotalQuestion(
                chatbotCode == "" ? null : chatbotCode, null, null)
            .catchError((e) => ResponseTotalQuestion()),
        fetchAllTotalInteraction(
                chatbotCode == "" ? null : chatbotCode, null, null)
            .catchError((e) => ResponseTotalInteraction()),
        fetchAllTotalCount(chatbotCode == "" ? null : chatbotCode, null, null)
            .catchError((e) => ResponseTotalCount()),
        fetchAllTotalPotentialCustomer(
                chatbotCode == "" ? null : chatbotCode, null, null)
            .catchError((e) => ResponseTotalPotentialCustomers()),
        fetchAllInteractionChar(chatbotCode, null, null)
            .catchError((e) => <ResponseInteractionChar>[]),
        fetchAllPotentialCustomerChar(chatbotCode, null, null)
            .catchError((e) => <ResponsePotentialCustomer>[]),
        fetchAllTotalPotentialCustomerPieChar(chatbotCode, null, null)
            .catchError((e) => <ResponsePotentialCustomerpie>[]),
        fetchAllInteractionpie(chatbotCode, null, null)
            .catchError((e) => <ResponseInteractionpie>[]),
      ]);

      // Gán kết quả
      ResponseTotalQuestion responseQuestion =
          results[0] as ResponseTotalQuestion;
      ResponseTotalInteraction responseInteraction =
          results[1] as ResponseTotalInteraction;
      ResponseTotalCount responseCount = results[2] as ResponseTotalCount;
      ResponseTotalPotentialCustomers responsePotentialCustomers =
          results[3] as ResponseTotalPotentialCustomers;

      List<ResponseInteractionChar> interactionCharData =
          results[4] as List<ResponseInteractionChar>;
      List<ResponsePotentialCustomer> potentialCharData =
          results[5] as List<ResponsePotentialCustomer>;
      List<ResponsePotentialCustomerpie> potentialPieData =
          results[6] as List<ResponsePotentialCustomerpie>;
      List<ResponseInteractionpie> interactionPieData =
          results[7] as List<ResponseInteractionpie>;

      // Cập nhật UI
      setState(() {
        totalQuestions = responseQuestion.totalQuestions ?? 0;
        totalInteraction = responseInteraction.totalInteraction ?? 0;
        totalCount = responseCount.totalChatbots ?? 0;
        totalPotentialCustomer =
            responsePotentialCustomers.totalPotentialCustomer ?? 0;

        chartData = interactionCharData;
        charDataPotential = potentialCharData;
        charDataPotentialPieChar = potentialPieData;
        charDataInteractionPieChar = interactionPieData;
      });
    } catch (e, stacktrace) {
      // Bạn có thể in lỗi ra log nếu muốn debug
      print('Error: $e');
    }
  }

  Future<void> _fetchDataTotal(String? chatbotCode) async {
    try {
      final results = await Future.wait([
        fetchAllTotalQuestion(
                chatbotCode == "" ? null : chatbotCode, startDate, endDate)
            .catchError((e) {
          return ResponseTotalQuestion();
        }),
        fetchAllTotalInteraction(
                chatbotCode == "" ? null : chatbotCode, startDate, endDate)
            .catchError((e) {
          return ResponseTotalInteraction();
        }),
        fetchAllTotalCount(
                chatbotCode == "" ? null : chatbotCode, startDate, endDate)
            .catchError((e) {
          return ResponseTotalCount();
        }),
        fetchAllTotalPotentialCustomer(
                chatbotCode == "" ? null : chatbotCode, startDate, endDate)
            .catchError((e) {
          return ResponseTotalPotentialCustomers();
        }),

        /// Gộp các hàm fetch dữ liệu của bạn vào đây
        fetchAllInteractionChar(chatbotCode, startDate, endDate)
            .catchError((e) {
          return <ResponseInteractionChar>[];
        }),
        fetchAllPotentialCustomerChar(chatbotCode, startDate, endDate)
            .catchError((e) {
          return <ResponsePotentialCustomer>[];
        }),
        fetchAllTotalPotentialCustomerPieChar(chatbotCode, startDate, endDate)
            .catchError((e) {
          return <ResponsePotentialCustomerpie>[];
        }),
        fetchAllInteractionpie(chatbotCode, startDate, endDate).catchError((e) {
          return <ResponseInteractionpie>[];
        }),
      ]);

      // Gán kết quả từ danh sách results
      ResponseTotalQuestion responseQuestion =
          results[0] as ResponseTotalQuestion;
      ResponseTotalInteraction responseInteraction =
          results[1] as ResponseTotalInteraction;
      ResponseTotalCount responseCount = results[2] as ResponseTotalCount;
      ResponseTotalPotentialCustomers responsePotentialCustomers =
          results[3] as ResponseTotalPotentialCustomers;

      List<ResponseInteractionChar> interactionCharData =
          results[4] as List<ResponseInteractionChar>;
      List<ResponsePotentialCustomer> potentialCharData =
          results[5] as List<ResponsePotentialCustomer>;
      List<ResponsePotentialCustomerpie> potentialPieData =
          results[6] as List<ResponsePotentialCustomerpie>;
      List<ResponseInteractionpie> interactionPieData =
          results[7] as List<ResponseInteractionpie>;

      // Cập nhật UI chỉ một lần
      setState(() {
        totalQuestions = responseQuestion.totalQuestions ?? 0;
        totalInteraction = responseInteraction.totalInteraction ?? 0;
        totalCount = responseCount.totalChatbots ?? 0;
        totalPotentialCustomer =
            responsePotentialCustomers.totalPotentialCustomer ?? 0;

        chartData = interactionCharData;
        charDataPotential = potentialCharData;
        charDataPotentialPieChar = potentialPieData;
        charDataInteractionPieChar = interactionPieData;
      });
    } catch (e, stacktrace) {}
  }

  Widget renderCustomerDropdown() {
    return Consumer<ChatbotnameProvider>(
      builder: (context, chatbotProvider, child) {
        List<ChatbotInfo> chatbotList = chatbotProvider.chatbotList;

        List<String> chatbotNames =
            chatbotList.map((chatbot) => chatbot.name).toList();
        List<String> dropdownItems = ['Chọn trợ lý', ...chatbotNames];

        return buildDropdown(
          items: dropdownItems.isNotEmpty ? dropdownItems : ["Loading..."],
          selectedItem: selectedCustomer,
          hint: "Chọn trợ lý",
          onTap: () {
            if (dropdownItems.isEmpty) return;
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return ListView.builder(
                  itemCount: dropdownItems.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(dropdownItems[index]),
                      onTap: () {
                        setState(() {
                          selectedCustomer = dropdownItems[index];

                          // Lấy thông tin chatbot đã chọn
                          ChatbotInfo? selectedChatbot = chatbotList.firstWhere(
                            (chatbot) => chatbot.name == selectedCustomer,
                            orElse: () => ChatbotInfo(
                                name: "",
                                code: "",
                                createdAt: "",
                                updatedAt: "",
                                userId: ""),
                          );

                          _fetchDataTotal(selectedChatbot.code);
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
            );
          },
          onChanged: (String? newValue) {},
        );
      },
    );
  }

  Widget buildDropdowCalendar({
    required List<String> items,
    required String? selectedItem,
    required String hint,
    required ValueChanged<String?> onChanged,
    required VoidCallback onTap,
    double width = 200,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 1, color: Colors.black38),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        width: width,
        height: 40,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                selectedItem == null || selectedItem.isEmpty
                    ? hint
                    : selectedItem,
                style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nếu đã chọn trợ lý thì hiển thị nút clear
                if (selectedItem != null &&
                    selectedItem.isNotEmpty &&
                    selectedItem != "Chọn trợ lý")
                  GestureDetector(
                    onTap: () {
                      onChanged(null); // gọi onChanged để clear selectedItem
                    },
                    child: const Icon(Icons.clear, size: 20),
                  ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 23,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDropdown({
    required List<String> items,
    required String? selectedItem,
    required String hint,
    required ValueChanged<String?> onChanged,
    required VoidCallback onTap, // Thêm hàm onTap
    double width = 200,
  }) {
    return GestureDetector(
      onTap: onTap, // Khi nhấn vào dropdown, sẽ gọi hàm này
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 1, color: Colors.black38),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        width: width,
        height: 40,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                selectedItem ?? hint,
                style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final styleText =
        GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500);
    final styleNumber =
        GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold);
    return SingleChildScrollView(
      child: LayoutBuilder(builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;

        // Lấy kích thước màn hình của thiết bị
        double screenWidth = MediaQuery.of(context).size.width;

        // Kiểm tra nếu màn hình có chiều rộng lớn hơn 600px (được coi là tablet)
        bool isTablet = screenWidth > 600;

        // Dựa vào kết quả, thiết lập chiều cao
        double? height =
            isTablet ? MediaQuery.of(context).size.width * 0.30 : null;
        double? heighttotal = isTablet
            ? MediaQuery.of(context).size.width * 0.20
            : MediaQuery.of(context).size.width * 0.16;
        return Container(
            width: maxWidth,
            padding: const EdgeInsets.all(6),
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: maxWidth * 0.47,
                        child: renderCustomerDropdown(),
                      ),
                      SizedBox(
                        width: maxWidth * 0.47,
                        child: renderDateDropdown(),
                      ),
                    ],
                  ),
                ),
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: maxWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              width: maxWidth * 0.47,
                              height: heighttotal,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  border:
                                      Border.all(width: 1, color: Colors.grey),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0x005c6566)
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                    )
                                  ]),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(
                                          width: 20,
                                          child:
                                              Icon(TablerIcons.clock_hour_4)),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Lượt tương tác',
                                          style: styleText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    totalInteraction != null
                                        ? '$totalInteraction'
                                        : '0',
                                    style: styleNumber,
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: maxWidth * 0.47,
                              height: heighttotal,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(width: 1, color: Colors.grey),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0x005c6566)
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                    )
                                  ]),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(
                                          width: 20,
                                          child: Icon(TablerIcons.user)),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Khách hàng tiềm năng',
                                          style: styleText,
                                        ),
                                      )
                                    ],
                                  ),
                                  Text(
                                    '$totalPotentialCustomer',
                                    style: styleNumber,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      SizedBox(
                        width: maxWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              width: maxWidth * 0.47,
                              height: heighttotal,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(width: 1, color: Colors.grey),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0x005c6566)
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                    )
                                  ]),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(
                                          width: 20,
                                          child:
                                              Icon(TablerIcons.message_circle)),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Tin nhắn',
                                          style: styleText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '$totalQuestions',
                                    style: styleNumber,
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: maxWidth * 0.47,
                              height: heighttotal,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(width: 1, color: Colors.grey),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0x005c6566)
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                    )
                                  ]),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(
                                          width: 20,
                                          child: Icon(Icons.support_outlined)),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Tổng số trợ lý',
                                          style: styleText,
                                        ),
                                      )
                                    ],
                                  ),
                                  Text(
                                    '$totalCount',
                                    style: styleNumber,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: maxWidth,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white,
                      border: Border.all(width: 1, color: Colors.grey)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: maxWidth,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          children: [
                            const Icon(
                              TablerIcons.chart_histogram,
                              size: 20,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              'Lượt tương tác',
                              style: styleText,
                            )
                          ],
                        ),
                      ),
                      const Divider(color: Colors.grey),
                      Container(
                        padding:
                            const EdgeInsets.only(right: 30, top: 8, left: 10),
                        width: double.infinity,
                        height: height,
                        child: chartData.isNotEmpty
                            ? InteractionCharPage(data: chartData)
                            : const Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: maxWidth,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white,
                      border: Border.all(width: 1, color: Colors.grey)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: maxWidth,
                        height: 36,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          children: [
                            const Icon(
                              TablerIcons.chart_histogram,
                              size: 20,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              'Khách hàng tiềm năng',
                              style: styleText,
                            )
                          ],
                        ),
                      ),
                      const Divider(color: Colors.grey),
                      Container(
                        padding:
                            const EdgeInsets.only(right: 30, top: 8, left: 10),
                        width: double.infinity,
                        height: height,
                        child: charDataPotential.isNotEmpty
                            ? PotentialCustomerChar(data: charDataPotential)
                            : const Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: maxWidth,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white,
                      border: Border.all(width: 1, color: Colors.grey)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: maxWidth,
                        height: 36,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 20,
                              child: Icon(
                                TablerIcons.chart_pie,
                                size: 20,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Text(
                                'Thống kê lượt tương tác theo kênh',
                                style: styleText,
                              ),
                            )
                          ],
                        ),
                      ),
                      const Divider(color: Colors.grey),
                      Container(
                        margin: const EdgeInsets.all(16),
                        width: double.infinity,
                        child: charDataInteractionPieChar.isNotEmpty
                            ? InteractionPiePage(
                                data: charDataInteractionPieChar)
                            : Center(
                                child: Container(
                                  width: 200, // Độ rộng hình tròn
                                  height: 300,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[300], // Màu tượng trưng
                                  ),
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(TablerIcons.database_off,
                                            size: 50, color: Colors.grey),
                                        SizedBox(height: 8),
                                        Text('Trống',
                                            style:
                                                TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: maxWidth,
                  height: 400,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white,
                      border: Border.all(width: 1, color: Colors.grey)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: maxWidth,
                        height: 36,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 20,
                              child: Icon(
                                TablerIcons.chart_pie,
                                size: 20,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Text(
                                'Thống kê số lượng khách hàng tiềm năng theo kênh',
                                style: styleText,
                              ),
                            )
                          ],
                        ),
                      ),
                      const Divider(color: Colors.grey),
                      Container(
                        margin: const EdgeInsets.all(16),
                        width: double.infinity,
                        child: charDataPotentialPieChar.isNotEmpty
                            ? PotentialCustomerPieChart(
                                data: charDataPotentialPieChar)
                            : Center(
                                child: Container(
                                  width: 200, // Độ rộng hình tròn
                                  height: 300,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[300], // Màu tượng trưng
                                  ),
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(TablerIcons.database_off,
                                            size: 50, color: Colors.grey),
                                        SizedBox(height: 8),
                                        Text('Trống',
                                            style:
                                                TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                )
              ],
            ));
      }),
    );
  }
}

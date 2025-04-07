import 'package:chatbotbnn/model/char/response_interaction_char.dart';
import 'package:chatbotbnn/model/char/response_interactionpie.dart';
import 'package:chatbotbnn/model/char/response_potential_customer.dart';
import 'package:chatbotbnn/model/char/response_potential_customerpie.dart';
import 'package:chatbotbnn/model/chatbot_info.dart';
import 'package:chatbotbnn/model/response_total_count.dart';
import 'package:chatbotbnn/model/response_total_interaction.dart';
import 'package:chatbotbnn/model/response_total_potential_customers.dart';
import 'package:chatbotbnn/model/response_total_question.dart';
import 'package:chatbotbnn/page/char_page/interaction_char_page.dart';
import 'package:chatbotbnn/page/char_page/interaction_pie_page.dart';
import 'package:chatbotbnn/page/char_page/potential_customer_char.dart';
import 'package:chatbotbnn/page/char_page/potential_customer_piechar.dart';
import 'package:chatbotbnn/provider/chatbotname_provider.dart';
import 'package:chatbotbnn/service/service_char/interaction_char.dart';
import 'package:chatbotbnn/service/service_char/interaction_pie_service.dart';
import 'package:chatbotbnn/service/service_char/piechar_potential_customer_service.dart';
import 'package:chatbotbnn/service/service_char/potential_customer_service.dart';
import 'package:chatbotbnn/service/total_count_service.dart';
import 'package:chatbotbnn/service/total_potential_customers_service.dart';
import 'package:chatbotbnn/service/total_question_service.dart';
import 'package:chatbotbnn/service/total_sessions_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
import 'package:tabler_icons/tabler_icons.dart';

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
  String? selectedChatbotName;
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
    _fetchDataTotal("");
  }

  String? startDate; // Biến lưu ngày đầu tháng: "YYYY-MM-DD 00:00:00"
  String? endDate; // Biến lưu ngày cuối tháng: "YYYY-MM-DD 23:59:59"

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
        startDate = DateFormat('yyyy-MM-dd').format(firstDay);
        endDate = DateFormat('yyyy-MM-dd').format(lastDay);
      });

      // Get the selected chatbot code if available
      String? chatbotCode = "";
      if (selectedCustomer != null && selectedCustomer != "Chọn trợ lý") {
        final chatbotProvider =
            Provider.of<ChatbotnameProvider>(context, listen: false);
        ChatbotInfo? selectedChatbot = chatbotProvider.chatbotList.firstWhere(
          (chatbot) => chatbot.name == selectedCustomer,
          orElse: () => ChatbotInfo(
              name: "", code: "", createdAt: "", updatedAt: "", userId: ""),
        );
        chatbotCode = selectedChatbot.code;
      }

      _fetchDataTotal(chatbotCode);
    }
  }

  Widget renderDateDropdown() {
    return buildDropdown(
      items: [],
      selectedItem: selectedDate,
      hint: "Chọn tháng",
      width: 180,
      onTap: () => _selectMonth(context),
      onChanged: (value) {
        _fetchDataTotal("");
      },
    );
  }

  Future<void> _fetchDataTotal(String? chatbotCode) async {
    try {
      final results = await Future.wait([
        fetchAllTotalQuestion(
                chatbotCode == "" ? null : chatbotCode, startDate, endDate)
            .catchError((e) {
          print("Error in fetchAllTotalQuestion: $e");
          return ResponseTotalQuestion();
        }),
        fetchAllTotalInteraction(
                chatbotCode == "" ? null : chatbotCode, startDate, endDate)
            .catchError((e) {
          print("Error in fetchAllTotalInteraction: $e");
          return ResponseTotalInteraction();
        }),
        fetchAllTotalCount(
                chatbotCode == "" ? null : chatbotCode, startDate, endDate)
            .catchError((e) {
          print("Error in fetchAllTotalCount: $e");
          return ResponseTotalCount();
        }),
        fetchAllTotalPotentialCustomer(
                chatbotCode == "" ? null : chatbotCode, startDate, endDate)
            .catchError((e) {
          print("Error in fetchAllTotalPotentialCustomer: $e");
          return ResponseTotalPotentialCustomers();
        }),

        /// Gộp các hàm fetch dữ liệu của bạn vào đây
        fetchAllInteractionChar(chatbotCode, startDate, endDate)
            .catchError((e) {
          print("Error in fetchAllInteractionChar: $e");
          return <ResponseInteractionChar>[];
        }),
        fetchAllPotentialCustomerChar(chatbotCode, startDate, endDate)
            .catchError((e) {
          print("Error in fetchAllPotentialCustomerChar: $e");
          return <ResponsePotentialCustomer>[];
        }),
        fetchAllTotalPotentialCustomerPieChar(chatbotCode, startDate, endDate)
            .catchError((e) {
          print("Error in fetchAllTotalPotentialCustomerPieChar: $e");
          return <ResponsePotentialCustomerpie>[];
        }),
        fetchAllInteractionpie(chatbotCode, startDate, endDate).catchError((e) {
          print("Error in fetchAllInteractionpie: $e");
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
    } catch (e, stacktrace) {
      print("❌ Error fetching data: $e");
      print("🛠 Stacktrace: $stacktrace");
    }
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              width: maxWidth * 0.47,
                              height: maxWidth * 0.16,
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
                              height: maxWidth * 0.16,
                              padding: EdgeInsets.symmetric(
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              width: maxWidth * 0.47,
                              height: maxWidth * 0.16,
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
                              height: maxWidth * 0.16,
                              padding: EdgeInsets.symmetric(
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
                                          'Trợ lý',
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
                      border: Border.all(width: 2, color: Colors.grey)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: maxWidth,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          children: [
                            Icon(
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
                        padding: const EdgeInsets.only(right: 30, top: 8),
                        width: double.infinity,
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
                      border: Border.all(width: 2, color: Colors.grey)),
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
                        padding: const EdgeInsets.only(right: 30, top: 8),
                        width: double.infinity,
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
                      border: Border.all(width: 2, color: Colors.grey)),
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
                                  child: Center(
                                    child: Text(
                                      "Không có dữ liệu",
                                      style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
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
                      border: Border.all(width: 2, color: Colors.grey)),
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
                                  child: Center(
                                    child: Text(
                                      "Không có dữ liệu",
                                      style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
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

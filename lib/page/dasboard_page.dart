import 'package:chatbotbnn/model/chatbot_info.dart';
import 'package:chatbotbnn/model/response_total_count.dart';
import 'package:chatbotbnn/model/response_total_interaction.dart';
import 'package:chatbotbnn/model/response_total_question.dart';
import 'package:chatbotbnn/provider/chatbotname_provider.dart';
import 'package:chatbotbnn/service/total_count_service.dart';
import 'package:chatbotbnn/service/total_question_service.dart';
import 'package:chatbotbnn/service/total_sessions_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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

  Future<void> _fetchDataTotal(String? chatbotCode) async {
    try {
      // Gọi cả hai API song song để giảm thời gian chờ
      final results = await Future.wait([
        fetchAllTotalQuestion(
          chatbotCode == "" ? null : chatbotCode,
          null, // Hoặc thay bằng startDate nếu có
          null, // Hoặc thay bằng endDate nếu có
        ),
        fetchAllTotalInteraction(
          chatbotCode == "" ? null : chatbotCode,
          null, // Hoặc thay bằng startDate nếu có
          null, // Hoặc thay bằng endDate nếu có
        ),
        fetchAllTotalCount(
          chatbotCode == "" ? null : chatbotCode,
          null, // Hoặc thay bằng startDate nếu có
          null, // Hoặc thay bằng endDate nếu có
        ),
      ]);

      // Lấy kết quả từ danh sách results
      ResponseTotalQuestion responseQuestion =
          results[0] as ResponseTotalQuestion;
      ResponseTotalInteraction responseInteraction =
          results[1] as ResponseTotalInteraction;
      ResponseTotalCount responseCount = results[2] as ResponseTotalCount;
      // Cập nhật UI chỉ một lần
      setState(() {
        totalQuestions = responseQuestion.totalQuestions ?? 0;
        totalInteraction = responseInteraction.totalInteraction ?? 0;
        totalCount = responseCount.totalChatbots ?? 0;
      });

      print("Total Questions: $totalQuestions");
      print("Total Interactions: $totalInteraction");
      print("Total Count: $totalCount");
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
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

  Widget renderDateDropdown() {
    return buildDropdown(
      items: [],
      selectedItem: selectedDate,
      hint: "Chọn ngày",
      width: 180,
      onTap: () => _selectDate(context),
      onChanged: (value) {}, // Không cần sử dụng vì onTap đã xử lý chọn ngày
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
                style: GoogleFonts.robotoCondensed(
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
        GoogleFonts.robotoCondensed(fontSize: 14, fontWeight: FontWeight.w400);
    final styleNumber =
        GoogleFonts.robotoCondensed(fontSize: 18, fontWeight: FontWeight.bold);
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
                        width: maxWidth * 0.45,
                        child: renderCustomerDropdown(),
                      ),
                      SizedBox(
                        width: maxWidth * 0.45,
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
                              width: maxWidth * 0.46,
                              height: 64,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color(0xfff9f0ff),
                                  border:
                                      Border.all(width: 2, color: Colors.grey),
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
                                      const Icon(Icons.link),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        'Lượt tương tác',
                                        style: styleText,
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
                              width: maxWidth * 0.46,
                              height: 64,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(width: 2, color: Colors.grey),
                                  color:
                                      const Color.fromARGB(255, 253, 253, 218),
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
                                      const Icon(Icons.account_box_outlined),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        'Khách hàng tiềm năng',
                                        style: styleText,
                                      )
                                    ],
                                  ),
                                  Text(
                                    '0',
                                    style: styleNumber,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: maxWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: maxWidth * 0.46,
                              height: 64,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(width: 2, color: Colors.grey),
                                  color: const Color(0xffF6FFED),
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
                                      const Icon(Icons.message_outlined),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        'Tin nhắn',
                                        style: styleText,
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
                              width: maxWidth * 0.46,
                              height: 64,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(width: 2, color: Colors.grey),
                                  color: const Color(0xffFFEEED),
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
                                      const Icon(Icons.support_outlined),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        'Trợ lý',
                                        style: styleText,
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
                  height: 300,
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
                              Icons.view_column_outlined,
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
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: maxWidth,
                  height: 300,
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
                              Icons.view_column_outlined,
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
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: maxWidth,
                  height: 300,
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
                              Icons.view_column_outlined,
                              size: 20,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              'Thống kê lượt tương tác theo kênh',
                              style: styleText,
                            )
                          ],
                        ),
                      ),
                      const Divider(color: Colors.grey),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: maxWidth,
                  height: 300,
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
                              Icons.view_column_outlined,
                              size: 20,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              'Thống kê số lượng khách hàng tiềm năng theo kênh',
                              style: styleText,
                            )
                          ],
                        ),
                      ),
                      const Divider(color: Colors.grey),
                    ],
                  ),
                )
              ],
            ));
      }),
    );
  }
}

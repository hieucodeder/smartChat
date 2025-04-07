import 'package:chatbotbnn/model/reponse_potential_customer.dart';
import 'package:chatbotbnn/provider/provider_color.dart';
import 'package:chatbotbnn/service/app_config.dart';
import 'package:chatbotbnn/service/potential_customer_sevice.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PotentialCustomers extends StatefulWidget {
  const PotentialCustomers({super.key});

  @override
  State<PotentialCustomers> createState() => _PotentialCustomersState();
}

class _PotentialCustomersState extends State<PotentialCustomers> {
  final TextEditingController _searchController = TextEditingController();

  List<DataPotentialCustomer> customers = [];
  bool isLoading = false;
  List<String> dynamicColumns =
      []; // Lưu danh sách các cột động từ slot_details
  String? searchContent;
  String? slotsStatus;
  String? currentPage = "1";
  String? pageSize = "10";
  final List<int> itemsPerPageOptions = [10, 20, 50, 100];
  bool hasMoreData = true;
  bool isImageUrl(String url) {
    if (url.isEmpty) {
      debugPrint('⚠️ URL rỗng - không phải ảnh');
      return false;
    }

    final lowerUrl = url.toLowerCase().trim();
    debugPrint('\n🔍 Kiểm tra URL: "$lowerUrl"');

    // Kiểm tra các dấu hiệu của URL ảnh
    final isHttp =
        lowerUrl.startsWith('http://') || lowerUrl.startsWith('https://');
    final hasImageExtension =
        RegExp(r'\.(jpg|jpeg|png|gif|webp|bmp)(\?.*)?$').hasMatch(lowerUrl);
    final containsImagePath =
        RegExp(r'(image|img|picture|pic|photo)').hasMatch(lowerUrl);

    debugPrint('🔎 Kết quả kiểm tra:');
    debugPrint('- Là URL: $isHttp');
    debugPrint('- Có đuôi ảnh: $hasImageExtension');
    debugPrint('- Chứa đường dẫn ảnh: $containsImagePath');

    final result = isHttp && (hasImageExtension || containsImagePath);
    debugPrint('🎯 Kết luận: ${result ? "✅ Là ảnh" : "❌ Không phải ảnh"}');

    return result;
  }

  String? selectedItem;
  final List<String> items = [
    'Tất cả trạng thái',
    'pending',
    'completed',
    'unreachable'
  ];

  @override
  void initState() {
    super.initState();
    fetchCustomers(searchContent, slotsStatus, currentPage, pageSize);
  }

  Future<Map<String, String?>> getChatbotInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('chatbot_name'),
      'picture': prefs.getString('chatbot_picture'),
    };
  }

  Future<void> fetchCustomers(String? selectedValue, String? searchValue,
      String? pageIndex, String? pageSize1) async {
    setState(() {
      isLoading = true;
      slotsStatus = selectedValue; // Cập nhật giá trị đã chọn vào slotsStatus
      searchContent = searchValue;
      currentPage = pageIndex;
      pageSize = pageSize1;
    });

    List<DataPotentialCustomer> data = await fetchAllPotentialCustomer(
        context, searchContent, slotsStatus, currentPage, pageSize);

    Set<String> columnsSet = {};
    for (var customer in data) {
      columnsSet.addAll(customer.slotDetails.keys);
    }

    setState(() {
      customers = data;
      dynamicColumns = columnsSet.toList();
      isLoading = false;
    });
  }

  Widget buildDropdown({
    required List<String> items,
    required String? selectedItem,
    required String hint,
    required ValueChanged<String?> onChanged, // Chỉ sử dụng onChanged
    double width = 200,
  }) {
    return GestureDetector(
      onTap: () =>
          onChanged(null), // Khi nhấn vào dropdown, gọi onChanged(null)
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
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedItem,
            hint: Text(
              hint,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            isExpanded: true,
            onChanged: onChanged, // Gọi khi chọn giá trị mới
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
                ),
              );
            }).toList(),
            icon: const Icon(Icons.arrow_drop_down),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = Provider.of<Providercolor>(context).selectedColor;
    return Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(8),
        color: Colors.white,
        child: Column(
          children: [
            Row(
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
                                AssetImage('resources/logo_smart.png'),
                            radius: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'No Name',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      );
                    }

                    final chatbotName = snapshot.data?['name'] ?? 'No Name';
                    final chatbotPicture = snapshot.data?['picture'];

                    return Row(
                      children: [
                        Container(
                          height: 30,
                          width: 30,
                          padding: const EdgeInsets.only(
                            left: 0,
                            right: 0,
                            top: 0,
                            bottom: 0,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.white),
                            borderRadius: BorderRadius.circular(
                                25), // Adding rounded corners here
                          ),
                          child: CircleAvatar(
                            backgroundImage: chatbotPicture != null &&
                                    chatbotPicture.isNotEmpty
                                ? NetworkImage(
                                    "${ApiConfig.baseUrlBasic}$chatbotPicture")
                                : const AssetImage('resources/Smartchat.png')
                                    as ImageProvider,
                            radius: 20,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          chatbotName,
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildDropdown(
                  items: items,
                  selectedItem: selectedItem,
                  hint: 'Tất cả trạng thái',
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedItem = newValue;
                    });

                    // Nếu chọn "Tất cả trạng thái", truyền null hoặc chuỗi rỗng
                    fetchCustomers(
                        newValue == 'Tất cả trạng thái' ? null : newValue,
                        searchContent,
                        currentPage,
                        pageSize);
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(width: 1.2, color: Colors.black26),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style:
                          GoogleFonts.inter(fontSize: 14, color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm tại đây...',
                        hintStyle: GoogleFonts.inter(
                            fontSize: 14, color: Colors.black45),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            fetchCustomers(slotsStatus, currentPage, pageSize,
                                _searchController.text);
                          },
                          child: Container(
                            width: 10,
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: selectedColor == Colors.white
                                  ? const Color(0xfffed5113)
                                  : selectedColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      onSubmitted: (value) {
                        fetchCustomers(
                            slotsStatus, currentPage, pageSize, value);
                      },
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  border: Border.all(width: 2, color: Colors.grey),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (dynamicColumns.isNotEmpty && customers.isNotEmpty)
                        ? SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: [
                                  DataColumn(
                                    label: Text(
                                      "STT",
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  ...dynamicColumns.map(
                                    (col) => DataColumn(
                                      label: Text(
                                        col,
                                        style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Trạng thái",
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                                rows: customers
                                    .asMap()
                                    .entries
                                    .map<DataRow>((entry) {
                                  int index = entry.key + 1;
                                  DataPotentialCustomer customer = entry.value;

                                  return DataRow(
                                    cells: [
                                      DataCell(Center(
                                          child: Text(index.toString()))),
                                      ...dynamicColumns.map((col) {
                                        final value = customer.slotDetails[col]
                                                ?.toString()
                                                .trim() ??
                                            "";
                                        debugPrint('\n📋 Kiểm tra cột: "$col"');
                                        debugPrint('📌 Giá trị: "$value"');

                                        if (isImageUrl(value)) {
                                          return DataCell(
                                            Center(
                                              child: Container(
                                                width: 60,
                                                height: 60,
                                                padding:
                                                    const EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                          Colors.grey.shade300),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  child: Image.network(
                                                    value,
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (context,
                                                        child, progress) {
                                                      if (progress == null)
                                                        return child;
                                                      return Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          value: progress
                                                                      .expectedTotalBytes !=
                                                                  null
                                                              ? progress
                                                                      .cumulativeBytesLoaded /
                                                                  progress
                                                                      .expectedTotalBytes!
                                                              : null,
                                                        ),
                                                      );
                                                    },
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      debugPrint(
                                                          '❗ Lỗi tải ảnh: $error');
                                                      return const Icon(
                                                          Icons
                                                              .image_not_supported,
                                                          size: 30);
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          return DataCell(
                                            Center(
                                                child: Text(value.isEmpty
                                                    ? "-"
                                                    : value)),
                                          );
                                        }
                                      }),
                                      DataCell(
                                        Center(
                                            child: Text(
                                                customer.slotStatus ?? "")),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          )
                        : const Center(
                            child: Text("Không có dữ liệu để hiển thị")),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed:
                        (currentPage != null && int.parse(currentPage!) > 1)
                            ? () {
                                setState(() {
                                  currentPage = (int.parse(currentPage!) - 1)
                                      .toString(); // Giảm trang
                                });
                                fetchCustomers(
                                  searchContent,
                                  slotsStatus,
                                  currentPage,
                                  pageSize,
                                );
                              }
                            : null,
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 2.0, horizontal: 10.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: selectedColor == Colors.white
                              ? const Color(0xfffed5113)
                              : selectedColor),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      currentPage ?? "1",
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          color: selectedColor == Colors.white
                              ? const Color(0xfffed51123)
                              : selectedColor),
                    ), // Hiển thị trang hiện tại, mặc định "1"
                  ),
                  IconButton(
                    onPressed: hasMoreData
                        ? () {
                            setState(() {
                              currentPage = (int.parse(currentPage ?? "1") + 1)
                                  .toString(); // Tăng trang
                            });
                            fetchCustomers(
                              searchContent,
                              slotsStatus,
                              currentPage,
                              pageSize,
                            );
                          }
                        : null,
                    icon: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 1, color: Colors.black12),
                    ),
                    child: DropdownButton<String>(
                      value: pageSize,
                      items: itemsPerPageOptions.map((int value) {
                        return DropdownMenuItem<String>(
                          value: value.toString(),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Text('$value/${'trang'}',
                                style: GoogleFonts.inter(fontSize: 14)),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            pageSize = newValue;
                            currentPage = "1"; // Đặt lại về trang 1
                          });
                          fetchCustomers(
                            searchContent,
                            slotsStatus,
                            currentPage,
                            pageSize,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}

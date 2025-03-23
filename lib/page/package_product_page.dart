import 'dart:ui';

import 'package:chatbotbnn/provider/provider_color.dart';
import 'package:flutter/material.dart';
import 'package:chatbotbnn/model/package_product_response.dart';
import 'package:chatbotbnn/service/package_product_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PackageProductPage extends StatefulWidget {
  const PackageProductPage({super.key});

  @override
  State<PackageProductPage> createState() => _PackageProductPageState();
}

class _PackageProductPageState extends State<PackageProductPage> {
  int selectedDuration = 2;
  List<Map<String, dynamic>> plans = [];
  bool isLoading = true;
  String? searchContent;
  String? package_product_name;
  int _selectedValue = 1; // Giá trị mặc định là "1 tháng"
  int? selectedMonths;
  int? selectedPrice;
  Map<String, int?> selectedMonthsMap = {};
  Map<String, dynamic> selectedPriceMap = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);

    try {
      PackageProductResponse? response =
          await fetchAllPackageProduct(searchContent, package_product_name);

      setState(() {
        if (response != null && response.data != null) {
          plans = response.data!.map((item) {
            String features =
                (item.listFunctions != null && item.listFunctions!.isNotEmpty)
                    ? item.listFunctions!
                        .map((func) =>
                            func.packageFunctionName ?? "Không có chức năng")
                        .join(", ")
                    : "Không có chức năng";

            String queriesPerMonth =
                (item.listFunctions != null && item.listFunctions!.isNotEmpty)
                    ? item.listFunctions!
                        .where((func) => func.queriesPerMonth != null)
                        .map((func) => func.queriesPerMonth.toString())
                        .join(", ")
                    : "Không có";

            String numbersOfBot =
                (item.listFunctions != null && item.listFunctions!.isNotEmpty)
                    ? item.listFunctions!
                        .where((func) => func.numbersOfBot != null)
                        .map((func) => func.numbersOfBot.toString())
                        .join(", ")
                    : "Không có";

            String numbersOfUsers =
                (item.listFunctions != null && item.listFunctions!.isNotEmpty)
                    ? item.listFunctions!
                        .where((func) => func.numbersOfUsers != null)
                        .map((func) => func.numbersOfUsers.toString())
                        .join(", ")
                    : "Không có";

            List<Map<String, dynamic>> listMonths = (item.listMonths != null)
                ? item.listMonths!.map((month) {
                    return {
                      "unit_price": month.unitPrice,
                      "count_month": month.countMonth,
                      "package_month_id": month.packageMonthId,
                      "package_product_id": month.packageProductId,
                    };
                  }).toList()
                : [];

            String price = (selectedPrice != null)
                ? "$selectedPrice VND / Tháng"
                : "Miễn phí";

            return {
              "title": item.packageProductName ?? "Không có tên",
              "price": price,
              "features": features,
              "queries_per_month": queriesPerMonth,
              "numbers_of_bot": numbersOfBot,
              "numbers_of_users": numbersOfUsers,
              "isActive": item.packageKey == "free" ? "true" : "false",
              "list_months": listMonths,
            };
          }).toList();
        } else {
          plans = [];
        }

        isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi tải dữ liệu: $e");
      setState(() {
        isLoading = false;
        plans = [];
      });
    }
  }

  String getIconForPlan(String title) {
    switch (title.toLowerCase()) {
      // Chuyển về chữ thường để tránh lỗi
      case "trải nghiệm":
        return 'resources/iconfree.png';
      case "cơ bản":
        return 'resources/iconbasic.png';
      case "nâng cao":
        return 'resources/diamond.png';
      case "tùy biến":
        return 'resources/package.png';
      default:
        return 'resources/iconfree.png'; // Icon mặc định nếu không khớp
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = Provider.of<Providercolor>(context).selectedColor;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : plans.isEmpty
              ? const Center(
                  child: Text(
                    "Không có gói sản phẩm nào",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    final isActive = plan["isActive"] == "true";
                    List<String> queries = plan["queries_per_month"]!
                        .split(", "); // Tách thành danh sách

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 2, color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Tiêu đề gói
                            ListTile(
                              leading: Image.asset(
                                getIconForPlan(plan["title"] ??
                                    ""), // Gọi hàm để lấy icon tương ứng
                                fit: BoxFit.contain,
                                width: 30,
                                height: 30,
                              ),
                              title: Text(
                                plan["title"] ?? "",
                                style: GoogleFonts.robotoCondensed(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: selectedColor == Colors.white
                                      ? Colors.orange
                                      : selectedColor,
                                ),
                              ),
                            ),

                            /// Giá gói
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      plan["title"] == "Tùy biến"
                                          ? "Liên hệ"
                                          : (plan["title"] == "Trải nghiệm"
                                              ? (plan["price"] ??
                                                  "Miễn phí") // Nếu là "Free", giữ nguyên giá hoặc "Miễn phí"
                                              : (selectedPriceMap[
                                                          plan["title"]] !=
                                                      null
                                                  ? "${selectedPriceMap[plan["title"]]} VND / Tháng"
                                                  : "Miễn phí")), // Nếu không phải "Free", hiển thị giá hoặc "Miễn phí"
                                      style: GoogleFonts.robotoCondensed(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isActive
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (plan["title"] != "Trải nghiệm" &&
                                plan["title"] != "Tùy biến")
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildRadioButton(
                                          plan["title"],
                                          12,
                                          "12 tháng",
                                          plan["list_months"] ?? []),
                                      _buildRadioButton(plan["title"], 6,
                                          "6 tháng", plan["list_months"] ?? []),
                                      _buildRadioButton(plan["title"], 3,
                                          "3 tháng", plan["list_months"] ?? []),
                                    ],
                                  ),
                                ],
                              ),
                            const Divider(
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 10),

                            /// Hiển thị thông tin chi tiết
                            _buildInfoRow(
                              Icons.check_circle_outline,
                              plan["numbers_of_bot"]!,
                              "Số lượng BOT",
                            ),

                            _buildInfoRow(
                              Icons.check_circle_outline, queries[0],
                              "Số lượng ký tự/bot",
                              // Lấy giá trị đầu tiên
                            ),
                            _buildInfoRow(
                              Icons.check_circle_outline, queries[1],
                              "Số lượng hỏi thông điệp/tháng",

                              // Lấy giá trị thứ hai
                            ),

                            ListTile(
                              leading: const Icon(Icons.check_circle_outline,
                                  color: Colors.black),
                              title: Text(
                                "${plan["title"] == "Cơ bản" ? 32 : plan["title"] == "Nâng cao" ? 40 : plan["title"] == "Tùy biến" ? 41 : 24} Tính năng thêm",
                                style: GoogleFonts.robotoCondensed(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              trailing: GestureDetector(
                                onTap: () {
                                  _showFeatureDialog(
                                      context, plan["features"]!.split(", "));
                                },
                                child: const Icon(Icons.info_outline,
                                    color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, dynamic value, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.black), // Icon màu xanh
        SizedBox(width: 8), // Khoảng cách giữa icon và text
        Text(
          "$value",
          style: GoogleFonts.robotoCondensed(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(width: 8), // Khoảng cách giữa icon và text

        Text(
          "$label",
          style: GoogleFonts.robotoCondensed(
            fontWeight: FontWeight.bold, // Chữ đậm
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  /// Hiển thị danh sách tính năng
  void _showFeatureDialog(BuildContext context, List<String> features) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Danh sách tính năng"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: features
                  .map((feature) => ListTile(
                        leading: const Icon(Icons.check),
                        title: Text(feature),
                      ))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Đóng"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRadioButton(
      String planTitle, int months, String label, List<dynamic> listMonths) {
    final selectedColor = Provider.of<Providercolor>(context).selectedColor;
    return Row(
      children: [
        Radio<int>(
          value: months,
          groupValue: selectedMonthsMap[planTitle],
          onChanged: (int? value) {
            setState(() {
              selectedMonthsMap[planTitle] = value;
              selectedPriceMap[planTitle] = listMonths.firstWhere(
                (item) => item["count_month"] == value,
                orElse: () => {"unit_price": null},
              )["unit_price"];
            });
          },
          fillColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return selectedColor == Colors.white
                    ? Colors.orange
                    : selectedColor; // Màu khi được chọn
              }
              return Colors.grey; // Màu mặc định
            },
          ),
        ),
        Text(
          label,
          style: GoogleFonts.robotoCondensed(
              fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

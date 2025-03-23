import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:chatbotbnn/model/package_product_response.dart';
import 'package:chatbotbnn/service/package_product_service.dart';
import 'package:google_fonts/google_fonts.dart';

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

  @override
  Widget build(BuildContext context) {
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
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Tiêu đề gói
                            ListTile(
                              leading: Image.asset(
                                'resources/iconfree.png',
                              ),
                              title: Text(
                                plan["title"] ?? "",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isActive ? Colors.green : Colors.black,
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
                                      plan["title"] == "Doanh nghiệp"
                                          ? "Liên hệ"
                                          : (plan["title"] == "Free"
                                              ? (plan["price"] ??
                                                  "Miễn phí") // Nếu là "Free", giữ nguyên giá hoặc "Miễn phí"
                                              : (selectedPriceMap[
                                                          plan["title"]] !=
                                                      null
                                                  ? "${selectedPriceMap[plan["title"]]} VND / Tháng"
                                                  : "Miễn phí")), // Nếu không phải "Free", hiển thị giá hoặc "Miễn phí"
                                      style: TextStyle(
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
                            if (plan["title"] != "Free" &&
                                plan["title"] != "Doanh nghiệp")
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
                                      _buildRadioButton(plan["title"], 1,
                                          "1 tháng", plan["list_months"] ?? []),
                                    ],
                                  ),
                                ],
                              ),

                            const SizedBox(height: 15),

                            /// Hiển thị thông tin chi tiết
                            _buildInfoRow(
                              Icons.check,
                              plan["numbers_of_bot"]!,
                              "Số lượng bot",
                            ),

                            _buildInfoRow(
                              Icons.check, queries[0], "Số lượng ký tự/bot",
                              // Lấy giá trị đầu tiên
                            ),
                            _buildInfoRow(
                              Icons.check, queries[1],
                              "Số lượng hỏi thông điệp/tháng",

                              // Lấy giá trị thứ hai
                            ),

                            ListTile(
                              leading:
                                  const Icon(Icons.check, color: Colors.blue),
                              title: Text(
                                "${plan["title"] == "Cơ bản" ? 32 : plan["title"] == "Nâng cao" ? 40 : plan["title"] == "Doanh nghiệp" ? 41 : 24} Tính năng thêm",
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

  /// Widget tạo dòng thông tin
  Widget _buildInfoRow(
    IconData icon,
    String title,
    String? value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.robotoCondensed(
                fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 5),
          Text(
            value ?? "Không có",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
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
    return Row(
      children: [
        Radio<int>(
          value: months,
          groupValue:
              selectedMonthsMap[planTitle], // Trạng thái riêng theo plan
          onChanged: (int? value) {
            setState(() {
              selectedMonthsMap[planTitle] = value;
              // Lấy giá tương ứng với số tháng đã chọn
              selectedPriceMap[planTitle] = listMonths.firstWhere(
                (item) => item["count_month"] == value,
                orElse: () => {"unit_price": null},
              )["unit_price"];
            });
          },
        ),
        Text(label),
      ],
    );
  }
}

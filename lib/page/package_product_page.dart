import 'dart:ui';

import 'package:smart_chat/provider/provider_color.dart';
import 'package:flutter/material.dart';
import 'package:smart_chat/model/package_product_response.dart';
import 'package:smart_chat/service/package_product_service.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Widget getIconForPlan(String? title) {
    final selectedColor = Provider.of<Providercolor>(context).selectedColor;
    if (title == null || title.isEmpty) {
      return const Icon(Icons.help_outline, size: 23, color: Colors.grey);
    }

    String assetPath;

    switch (title.toLowerCase()) {
      case "trải nghiệm":
        assetPath = 'resources/iconfree.svg';
        break;
      case "cơ bản":
        assetPath = 'resources/iconbasic.svg';
        break;
      case "nâng cao":
        assetPath = 'resources/diamond.svg';
        break;
      case "tùy biến":
        assetPath = 'resources/package.svg';
        break;
      default:
        assetPath = 'resources/iconfree.svg';
    }

    // Determine if the asset is SVG
    bool isSvg = assetPath.endsWith('.svg');

    return isSvg
        ? SvgPicture.asset(assetPath,
            width: 23,
            height: 23,
            colorFilter: ColorFilter.mode(
                selectedColor == Colors.white
                    ? const Color(0xFFED5113)
                    : selectedColor,
                BlendMode.srcIn))
        : Image.asset(assetPath, width: 30, height: 30, fit: BoxFit.contain);
  }

  String formatNumber(dynamic value, {bool first = false}) {
    if (value is List && value.isNotEmpty) {
      value = first ? value.first : value[1];
    }

    // Chuyển đổi value thành số nguyên (int) nếu là chuỗi
    int? number = int.tryParse(value.toString());

    if (number == null) {
      return value.toString(); // Trả về nguyên bản nếu không thể chuyển đổi
    }

    return NumberFormat("#,###", "en_US").format(number);
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = Provider.of<Providercolor>(context).selectedColor;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : plans.isEmpty
              ? Center(
                  child: Text(
                    "Không có gói sản phẩm nào",
                    style: GoogleFonts.inter(fontSize: 15),
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
                      color: Colors.white,
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 2, color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            /// Tiêu đề gói
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                getIconForPlan(plan["title"] ?? ""),
                                const SizedBox(
                                    width: 8), // khoảng cách giữa icon và text
                                Text(
                                  plan["title"] ?? "",
                                  style: GoogleFonts.inter(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: selectedColor == Colors.white
                                        ? const Color(0xFFED5113)
                                        : selectedColor,
                                  ),
                                ),
                              ],
                            ),
                            // Các p

                            /// Giá gói
                            // Center(
                            //   child: Container(
                            //     padding: const EdgeInsets.symmetric(
                            //         horizontal: 15, vertical: 8),
                            //     decoration: BoxDecoration(
                            //       color: Colors.orange.withOpacity(0.1),
                            //       borderRadius: BorderRadius.circular(10),
                            //     ),
                            //     child: Column(
                            //       children: [
                            //         Text(
                            //           plan["title"] == "Tùy biến"
                            //               ? "Liên hệ"
                            //               : (plan["title"] == "Trải nghiệm"
                            //                   ? (plan["price"] ??
                            //                       "Miễn phí") // Nếu là "Trải nghiệm", giữ nguyên giá hoặc "Miễn phí"
                            //                   : (selectedPriceMap[
                            //                               plan["title"]] !=
                            //                           null
                            //                       ? "${formatNumber(selectedPriceMap[plan["title"]])} VND / Tháng"
                            //                       : "Miễn phí")), // Nếu không phải "Trải nghiệm", hiển thị giá hoặc "Miễn phí"
                            //           style: GoogleFonts.inter(
                            //             fontSize: 20,
                            //             fontWeight: FontWeight.bold,
                            //             color: isActive
                            //                 ? Colors.black
                            //                 : Colors.black,
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            // if (plan["title"] != "Trải nghiệm" &&
                            //     plan["title"] != "Tùy biến")
                            //   Column(
                            //     children: [
                            //       Row(
                            //         mainAxisAlignment: MainAxisAlignment.center,
                            //         children: [
                            //           _buildRadioButton(
                            //               plan["title"],
                            //               12,
                            //               "12 tháng",
                            //               plan["list_months"] ?? []),
                            //           _buildRadioButton(plan["title"], 6,
                            //               "6 tháng", plan["list_months"] ?? []),
                            //           _buildRadioButton(plan["title"], 3,
                            //               "3 tháng", plan["list_months"] ?? []),
                            //         ],
                            //       ),
                            //     ],
                            //   ),
                            const Divider(
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 10),

                            /// Hiển thị thông tin chi tiết
                            _buildInfoRow(
                              Icons.check_circle_outline,
                              formatNumber(plan["numbers_of_bot"]!),
                              "Trợ lý AI",
                            ),

                            _buildInfoRow(
                              Icons.check_circle_outline,
                              formatNumber(queries[0]),
                              "thông điệp hỏi/tháng",
                              // Lấy giá trị thứ hai
                            ),
                            _buildInfoRow(
                              Icons.check_circle_outline,
                              formatNumber(queries[1]),
                              "tệp tối đa (tối đa 10MB/tệp)",
                              // Lấy giá trị thứ hai
                            ),
                            _buildInfoRow(
                              Icons.check_circle_outline,
                              formatNumber(queries[2]),
                              "liên kết (URLs) tối đa",
                              // Lấy giá trị thứ hai
                            ),
                            _buildInfoRow(
                              Icons.check_circle_outline,
                              formatNumber(queries[3]),
                              "câu hỏi mẫu tối đa",
                              // Lấy giá trị đầu tiên
                            ),
                            _buildInfoRow(
                              Icons.check_circle_outline,
                              queries.length > 4
                                  ? formatNumber(queries[4])
                                  : "0", // or some default value
                              "khách hàng tiềm năng tối đa",
                            ),

                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: ListTile(
                                leading: Icon(
                                  Icons.check_circle_outline,
                                  color: selectedColor == Colors.white
                                      ? const Color(0xffff5814a)
                                      : selectedColor,
                                  size: 20,
                                ),
                                title: Text(
                                  plan["title"] == "Tùy biến"
                                      ? "Tính năng theo yêu cầu"
                                      : "${plan["title"] == "Cơ bản" ? 20 : plan["title"] == "Nâng cao" ? 25 : 13} Tính năng thêm",
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),

                                // trailing: GestureDetector(
                                //   onTap: () async {
                                //     const youtubeUrl =
                                //         'https://smartchat.com.vn/vi/pricing'; // Thay link tại đây
                                //     if (await canLaunchUrl(
                                //         Uri.parse(youtubeUrl))) {
                                //       await launchUrl(Uri.parse(youtubeUrl));
                                //     } else {
                                //       ScaffoldMessenger.of(context)
                                //           .showSnackBar(
                                //         const SnackBar(
                                //             content:
                                //                 Text('Không thể mở YouTube')),
                                //       );
                                //     }
                                //     // _showFeatureDialog(
                                //     //     context, plan["features"]!.split(", "));
                                //   },
                                //   child: const Icon(
                                //     Icons.info_outline,
                                //     color: Colors.black,
                                //     size: 20,
                                //   ),
                                // ),
                                horizontalTitleGap:
                                    8, // Giảm khoảng cách ngang giữa icon và text

                                contentPadding: EdgeInsets.zero,
                                // Loại bỏ padding hoàn toàn
                                visualDensity: VisualDensity
                                    .compact, // Giảm mật độ hiển thị
                                minVerticalPadding:
                                    0, // Giảm padding dọc tối thiểu
                                dense: true, // Kích hoạt chế độ compact
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

  Widget _buildInfoRow(IconData icon, String value, String label) {
    final selectedcolor = Provider.of<Providercolor>(context)
        .selectedColor; // Kiểm tra nếu value là "99,999,999" thì thay bằng "Không giới hạn"
    String displayValue =
        (value == formatNumber(99999999)) ? "Không giới hạn" : value;
    if (value == "0" || value.isEmpty) {
      return const SizedBox.shrink(); // Hoặc return Container() nếu muốn
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ListTile(
        leading: Icon(icon,
            color: selectedcolor == Colors.white
                ? const Color(0xffff5814a)
                : selectedcolor,
            size: 20),
        title: Text(
          "$displayValue $label",
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        horizontalTitleGap: 8, // Giảm khoảng cách ngang giữa icon và text

        contentPadding: EdgeInsets.zero, // Loại bỏ padding hoàn toàn
        visualDensity: VisualDensity.compact, // Giảm mật độ hiển thị
        minVerticalPadding: 0, // Giảm padding dọc tối thiểu
        dense: true, // Kích hoạt chế độ compact
      ),
    );
  }

  /// Hiển thị danh sách tính năng
  void _showFeatureDialog(BuildContext context, List<String> features) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Danh sách tính năng",
            style: GoogleFonts.inter(
                fontSize: 18, color: Colors.black, fontWeight: FontWeight.w500),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: features
                  .map((feature) => ListTile(
                        leading: const Icon(
                          Icons.check,
                          size: 23,
                        ),
                        title: Text(
                          feature,
                          style: GoogleFonts.inter(
                              fontSize: 14, color: Colors.black),
                        ),
                      ))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Đóng",
                style: GoogleFonts.inter(fontSize: 16, color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRadioButton(
      String planTitle, int months, String label, List<dynamic> listMonths) {
    final selectedColor = Provider.of<Providercolor>(context).selectedColor;

    // Đặt giá trị mặc định là 12 nếu selectedMonthsMap[planTitle] chưa được khởi tạo
    if (selectedMonthsMap[planTitle] == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          selectedMonthsMap[planTitle] = 12; // Mặc định chọn 12 tháng
          selectedPriceMap[planTitle] = listMonths.firstWhere(
            (item) => item["count_month"] == 12,
            orElse: () => {"unit_price": null},
          )["unit_price"];
        });
      });
    }

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
                    ? const Color(0xFFED5113)
                    : selectedColor; // Màu khi được chọn
              }
              return Colors.grey; // Màu mặc định
            },
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

import 'package:chatbotbnn/model/char/response_potential_customerpie.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PotentialCustomerPieChart extends StatefulWidget {
  final List<ResponsePotentialCustomerpie> data;

  const PotentialCustomerPieChart({super.key, required this.data});

  @override
  _PotentialCustomerPieChartState createState() =>
      _PotentialCustomerPieChartState();
}

class _PotentialCustomerPieChartState extends State<PotentialCustomerPieChart> {
  int? touchedIndex;

  // Map ánh xạ platform với màu cố định
  static const Map<String, Color> platformColors = {
    'playground': Color(0xFFee5b24),
    'zalo': Color(0xFF58daa3),
    'website': Color(0xFFf5c12b),
    'facebook': Color(0xFF5e9af7),
    // Thêm các platform khác nếu cần
  };

  // Hàm lấy màu theo platform, mặc định màu xám nếu không tìm thấy
  Color getColorForPlatform(String? platform) {
    return platformColors[platform] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Biểu đồ tròn
        SizedBox(
          height: 250,
          width: double.infinity,
          child: PieChart(
            PieChartData(
              sections: widget.data.map((item) {
                return PieChartSectionData(
                  value: (item.totalSlot ?? 0).toDouble(),
                  title: touchedIndex == widget.data.indexOf(item)
                      ? '${item.totalSlot}'
                      : '',
                  color: getColorForPlatform(item.platform),
                  radius: touchedIndex == widget.data.indexOf(item) ? 110 : 100,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              sectionsSpace: 0,
              centerSpaceRadius: 0,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse?.touchedSection == null) {
                      touchedIndex = null;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse!.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Chú thích (Legend)
        Wrap(
          spacing: 10,
          runSpacing: 6,
          children: widget.data.map((item) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: getColorForPlatform(item.platform),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  item.platform ?? '',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

import 'package:smart_chat/model/char/response_interactionpie.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class InteractionPiePage extends StatefulWidget {
  final List<ResponseInteractionpie> data;

  const InteractionPiePage({super.key, required this.data});

  @override
  _InteractionPiePageState createState() => _InteractionPiePageState();
}

class _InteractionPiePageState extends State<InteractionPiePage> {
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
              sections: widget.data.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                return PieChartSectionData(
                  value: (item.totalMessages ?? 0).toDouble(),
                  title: touchedIndex == index ? '${item.totalMessages}' : '',
                  color: getColorForPlatform(item.platform),
                  radius: touchedIndex == index
                      ? 110
                      : 100, // Làm nổi bật phần được chọn
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

        const SizedBox(height: 16), // Khoảng cách giữa biểu đồ và chú thích

        // Chú thích (Legend)
        Wrap(
          spacing: 10,
          runSpacing: 6,
          children: widget.data.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
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

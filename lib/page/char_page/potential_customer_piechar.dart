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
                  value: (item.totalSlot ?? 0).toDouble(),
                  title: touchedIndex == index ? '${item.totalSlot}' : '',
                  color: Colors.primaries[index % Colors.primaries.length],
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
                    color: Colors.primaries[index % Colors.primaries.length],
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

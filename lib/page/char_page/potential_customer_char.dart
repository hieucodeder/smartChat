import 'package:smart_chat/model/char/response_potential_customer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PotentialCustomerChar extends StatelessWidget {
  final List<ResponsePotentialCustomer> data;
  final List<Color> barColors = [
    const Color(0xFFFFCEBBC),
    const Color(0xFF7566FB),
    const Color(0xFF65DAAB),
    const Color(0xFFFD0F4E6),
    const Color(0xFF657798),
    const Color(0xFF76CBED),
  ];

  PotentialCustomerChar({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: AspectRatio(
        aspectRatio: 1.5,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: data.isNotEmpty
                ? (data
                            .map((e) => e.totalSlot ?? 0)
                            .reduce((a, b) => a > b ? a : b) +
                        1)
                    .toDouble()
                : 10,
            // Thêm viền cho biểu đồ
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: Colors.grey, // Màu viền
                width: 1, // Độ dày viền
              ),
            ),
            barGroups: data.asMap().entries.map(
              (entry) {
                final colorIndex = entry.key % barColors.length;
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: (entry.value.totalSlot ?? 0).toDouble(),
                      color: barColors[colorIndex],
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: [
                          barColors[colorIndex],
                          barColors[colorIndex],
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ],
                );
              },
            ).toList(),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= 0 && index < data.length) {
                      String date = data[index].interactionDate ?? '';
                      String day = date.split('-').last;
                      if (day.isNotEmpty && int.tryParse(day) != null) {
                        int dayNumber = int.parse(day);
                        if (dayNumber % 2 == 1) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              day.padLeft(2, '0'),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }
                      }
                    }
                    return const Text('');
                  },
                  interval: 1,
                  reservedSize: 20,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.black,
                      ),
                    );
                  },
                  reservedSize: 25,
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.3),
                  strokeWidth: 1,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

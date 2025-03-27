import 'package:chatbotbnn/model/char/response_interaction_char.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class InteractionCharPage extends StatelessWidget {
  final List<ResponseInteractionChar> data;

  const InteractionCharPage({super.key, required this.data});

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
                            .map((e) => e.totalSessions ?? 0)
                            .reduce((a, b) => a > b ? a : b) +
                        1)
                    .toDouble()
                : 10,
            barGroups: data
                .asMap()
                .entries
                .map(
                  (entry) => BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: (entry.value.totalSessions ?? 0).toDouble(),
                        color: Colors.blue,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                )
                .toList(),
            titlesData: FlTitlesData(
              topTitles: AxisTitles(
                sideTitles:
                    SideTitles(showTitles: false), // Ẩn giá trị phía trên
              ),
              rightTitles: AxisTitles(
                sideTitles:
                    SideTitles(showTitles: false), // Ẩn giá trị bên phải
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index % 4 == 1 && index >= 0 && index < data.length) {
                      String date = data[index].interactionDate ?? '';
                      return Text(
                        date.length >= 5 ? date.substring(5) : date,
                        style: const TextStyle(fontSize: 10),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

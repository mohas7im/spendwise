import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SpendingTrendsChart extends StatelessWidget {
  final List<double> weeklyData; // 7 days of data
  
  const SpendingTrendsChart({super.key, required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    if (weeklyData.isEmpty) return const SizedBox.shrink();

    double maxY = weeklyData.reduce((curr, next) => curr > next ? curr : next);
    if (maxY == 0) maxY = 100; // default scale

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (weeklyData.length - 1).toDouble(),
          minY: 0,
          maxY: maxY * 1.2,
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(weeklyData.length, (index) => FlSpot(index.toDouble(), weeklyData[index])),
              isCurved: true,
              color: Theme.of(context).primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> categoryData;

  const CategoryPieChart({super.key, required this.categoryData});

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.blue,
      Colors.redAccent,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    if (categoryData.isEmpty) {
      return const Center(child: Text('No spending data', style: TextStyle(color: Colors.grey)));
    }

    int i = 0;
    List<PieChartSectionData> sections = categoryData.entries.map((entry) {
      final color = colors[i % colors.length];
      i++;
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${entry.key}\n₹${entry.value.toStringAsFixed(0)}',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: sections,
        ),
      ),
    );
  }
}

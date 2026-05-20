import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

enum ChartType { pie, bar, line, radar }

class ChartDataPoint {
  final String label;
  final double value;
  final Color? color;

  ChartDataPoint({required this.label, required this.value, this.color});
}

class FinancialChart extends StatelessWidget {
  final ChartType type;
  final List<ChartDataPoint> data;
  final double? height;
  final bool showLegend;
  final bool animated;

  const FinancialChart({
    super.key,
    required this.type,
    required this.data,
    this.height = 200,
    this.showLegend = true,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: type == ChartType.pie ? _buildPieChart() : _buildBarChart(),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: data.asMap().entries.map((e) => PieChartSectionData(
          value: e.value.value,
          title: e.value.label,
          color: e.value.color ?? Colors.primaries[e.key % Colors.primaries.length],
          radius: 40,
        )).toList(),
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        barGroups: data.asMap().entries.map((e) => BarChartGroupData(
          x: e.key,
          barRods: [BarChartRodData(toY: e.value.value, color: e.value.color ?? Colors.blue)],
        )).toList(),
      ),
    );
  }
}

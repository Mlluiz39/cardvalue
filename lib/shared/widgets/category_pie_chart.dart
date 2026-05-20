import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CategorySpending {
  final String name;
  final double amount;
  final Color color;
  final double percentage;

  CategorySpending({required this.name, required this.amount, required this.color, required this.percentage});
}

class CategoryPieChart extends StatelessWidget {
  final List<CategorySpending> categories;
  final double? height;
  final bool showLabels;

  const CategoryPieChart({super.key, required this.categories, this.height, this.showLabels = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 200,
      child: PieChart(
        PieChartData(
          sections: categories.map((c) => PieChartSectionData(
            value: c.amount,
            title: showLabels ? '${c.percentage.toStringAsFixed(0)}%' : '',
            color: c.color,
            radius: 50,
          )).toList(),
        ),
      ),
    );
  }
}

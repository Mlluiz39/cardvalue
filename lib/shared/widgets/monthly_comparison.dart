import 'package:flutter/material.dart';

class MonthData {
  final String label;
  final double value;

  MonthData({required this.label, required this.value});
}

class MonthlyComparison extends StatelessWidget {
  final List<MonthData> currentYear;
  final List<MonthData>? previousYear;
  final String currentLabel;
  final String? previousLabel;

  const MonthlyComparison({
    super.key,
    required this.currentYear,
    this.previousYear,
    required this.currentLabel,
    this.previousLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Comparativo Mensal', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('$currentLabel: ${currentYear.length} meses', style: Theme.of(context).textTheme.bodySmall),
            if (previousYear != null)
              Text('${previousLabel ?? "Anterior"}: ${previousYear!.length} meses'),
          ],
        ),
      ),
    );
  }
}

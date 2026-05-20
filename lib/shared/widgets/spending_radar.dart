import 'package:flutter/material.dart';

class RadarCategory {
  final String name;
  final double amount;
  final Color color;
  final double maxAmount;

  RadarCategory({required this.name, required this.amount, required this.color, this.maxAmount = 1000});
}

class SpendingRadar extends StatelessWidget {
  final List<RadarCategory> categories;
  final double? size;

  const SpendingRadar({super.key, required this.categories, this.size = 250});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      child: Center(
        child: Text('SpendingRadar (${categories.length} categories)', style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class InvoiceMonth {
  final int month;
  final int year;
  final double total;
  final bool isPaid;
  final bool isCurrent;

  InvoiceMonth({
    required this.month,
    required this.year,
    required this.total,
    this.isPaid = false,
    this.isCurrent = false,
  });
}

class InvoiceTimeline extends StatelessWidget {
  final List<InvoiceMonth> months;
  final int selectedIndex;
  final ValueChanged<int> onMonthSelected;

  const InvoiceTimeline({
    super.key,
    required this.months,
    required this.selectedIndex,
    required this.onMonthSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: months.length,
        itemBuilder: (context, index) {
          final month = months[index];
          final isSelected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text('${month.month}/${month.year}'),
              selected: isSelected,
              onSelected: (_) => onMonthSelected(index),
            ),
          );
        },
      ),
    );
  }
}

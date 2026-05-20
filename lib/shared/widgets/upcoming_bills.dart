import 'package:flutter/material.dart';

class UpcomingBill {
  final String description;
  final double amount;
  final DateTime dueDate;
  final String category;

  UpcomingBill({required this.description, required this.amount, required this.dueDate, required this.category});
}

class UpcomingBills extends StatelessWidget {
  final List<UpcomingBill> bills;
  final int maxItems;
  final VoidCallback? onViewAll;

  const UpcomingBills({super.key, required this.bills, this.maxItems = 5, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final display = bills.take(maxItems).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Próximas Faturas', style: Theme.of(context).textTheme.titleMedium),
                if (onViewAll != null)
                  TextButton(onPressed: onViewAll, child: const Text('Ver todas')),
              ],
            ),
            ...display.map((b) => ListTile(
              title: Text(b.description),
              subtitle: Text(b.category),
              trailing: Text('R\$ ${b.amount.toStringAsFixed(2)}'),
            )),
          ],
        ),
      ),
    );
  }
}

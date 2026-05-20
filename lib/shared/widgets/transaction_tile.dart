import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  final String description;
  final String formattedAmount;
  final String category;
  final IconData categoryIcon;
  final Color categoryColor;
  final DateTime date;
  final String? paymentMethod;
  final bool isIncome;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.description,
    required this.formattedAmount,
    required this.category,
    required this.categoryIcon,
    required this.categoryColor,
    required this.date,
    this.paymentMethod,
    this.isIncome = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: categoryColor.withValues(alpha: 0.2), child: Icon(categoryIcon, color: categoryColor, size: 20)),
      title: Text(description),
      subtitle: Text('$category • ${paymentMethod ?? ""}'),
      trailing: Text(
        formattedAmount,
        style: TextStyle(color: isIncome ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
      ),
      onTap: onTap,
    );
  }
}

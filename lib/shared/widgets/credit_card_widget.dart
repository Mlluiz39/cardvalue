import 'package:flutter/material.dart';

class CreditCardWidget extends StatelessWidget {
  final String bankName;
  final String cardName;
  final String lastDigits;
  final double usedAmount;
  final double totalLimit;
  final String closingDayText;
  final String dueDayText;
  final Color color;
  final bool isFlipped;
  final VoidCallback? onTap;

  const CreditCardWidget({
    super.key,
    required this.bankName,
    required this.cardName,
    required this.lastDigits,
    required this.usedAmount,
    required this.totalLimit,
    required this.closingDayText,
    required this.dueDayText,
    required this.color,
    this.isFlipped = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final usage = totalLimit > 0 ? usedAmount / totalLimit : 0.0;
    return Card(
      color: color.withValues(alpha: 0.9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(bankName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  Text('•••• $lastDigits', style: const TextStyle(color: Colors.white70)),
                ],
              ),
              const Spacer(),
              Text(cardName, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: usage,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation(usage > 0.8 ? Colors.red : Colors.white),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(closingDayText, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(dueDayText, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

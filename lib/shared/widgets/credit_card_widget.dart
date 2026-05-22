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
    final isHighUsage = usage >= 0.8;

    return Semantics(
      label: 'Cartão $bankName $cardName, final $lastDigits. '
          'Limite usado: ${(usage * 100).toStringAsFixed(0)}%. '
          '$closingDayText, $dueDayText',
      button: onTap != null,
      child: Card(
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
                    Text('•••• $lastDigits', style: TextStyle(color: Colors.white.withValues(alpha: 0.8))),
                  ],
                ),
                const Spacer(),
                Text(cardName, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: usage.clamp(0.0, 1.0),
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation(isHighUsage ? Colors.red.shade300 : Colors.white),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'R\$ ${usedAmount.toStringAsFixed(2)} / R\$ ${totalLimit.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                    ),
                    if (isHighUsage)
                      Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.red.shade300, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${(usage * 100).toStringAsFixed(0)}%',
                            style: TextStyle(color: Colors.red.shade300, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      )
                    else
                      Text(
                        '${(usage * 100).toStringAsFixed(0)}%',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(closingDayText, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
                    Text(dueDayText, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

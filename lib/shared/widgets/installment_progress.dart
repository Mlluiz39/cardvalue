import 'package:flutter/material.dart';

class InstallmentProgress extends StatelessWidget {
  final int paidCount;
  final int totalCount;
  final double paidAmount;
  final double totalAmount;
  final double size;

  const InstallmentProgress({
    super.key,
    required this.paidCount,
    required this.totalCount,
    required this.paidAmount,
    required this.totalAmount,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalCount > 0 ? paidCount / totalCount : 0.0;
    return Semantics(
      label: 'Progresso de parcelas: $paidCount de $totalCount pagas. '
          'Valor pago: R\$ ${paidAmount.toStringAsFixed(2)} de R\$ ${totalAmount.toStringAsFixed(2)}',
      child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 6,
                backgroundColor: Colors.grey.shade200,
              ),
              Center(
                child: Text(
                  '$paidCount/$totalCount',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text('R\$ ${paidAmount.toStringAsFixed(2)} / R\$ ${totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    ),
    );
  }
}

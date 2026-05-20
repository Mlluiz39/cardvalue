import 'package:flutter/material.dart';

class DebtDetailScreen extends StatelessWidget {
  final String debtId;

  const DebtDetailScreen({super.key, required this.debtId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da Dívida')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: $debtId', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            const Text('Detalhes completos serão exibidos aqui.'),
          ],
        ),
      ),
    );
  }
}

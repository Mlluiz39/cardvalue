import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InvoiceListScreen extends StatelessWidget {
  final String cardId;

  const InvoiceListScreen({super.key, required this.cardId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Faturas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Cartão: $cardId', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          const Text('Faturas disponíveis aparecerão aqui.'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.push('/invoices/$cardId/reconciliation'),
            child: const Text('Conciliar Fatura'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ReconciliationScreen extends StatelessWidget {
  final String invoiceId;

  const ReconciliationScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conciliação')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Fatura: $invoiceId', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          const Text('Itens da Fatura:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Card(
            child: ExpansionTile(
              title: Text('Item #1'),
              subtitle: Text('R\$ 0,00'),
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Detalhes do item serão exibidos aqui.'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          ListTile(
            title: const Text('Total'),
            trailing: Text('R\$ 0,00', style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {},
            child: const Text('Finalizar Conciliação'),
          ),
        ],
      ),
    );
  }
}

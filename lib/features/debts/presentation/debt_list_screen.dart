import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'debt_providers.dart';

class DebtListScreen extends ConsumerWidget {
  const DebtListScreen({super.key});

  String _priorityLabel(String priority) {
    switch (priority) {
      case 'low': return 'Baixa';
      case 'high': return 'Alta';
      default: return 'Média';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(debtListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Dívidas')),
      body: debtsAsync.when(
        data: (debts) => debts.isEmpty
            ? const Center(child: Text('Nenhuma dívida registrada'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: debts.length,
                itemBuilder: (_, i) {
                  final debt = debts[i];
                  return Card(
                    child: ListTile(
                      title: Text(debt.title),
                      subtitle: Text('R\$ ${debt.remainingAmount.toStringAsFixed(2)} restantes'),
                      trailing: Chip(label: Text(_priorityLabel(debt.priority))),
                      onTap: () => context.push('/debts/${debt.id}'),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/debts/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

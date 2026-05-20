import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/transaction_tile.dart';
import 'transaction_providers.dart';

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Transações')),
      body: transactionsAsync.when(
        data: (transactions) => transactions.isEmpty
            ? const Center(child: Text('Nenhuma transação'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: transactions.length,
                itemBuilder: (_, i) {
                  final t = transactions[i];
                  final isIncome = t.type == 'income';
                  return Dismissible(
                    key: Key(t.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Excluir Transação'),
                          content: const Text('Tem certeza que deseja excluir?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text('Excluir'),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) {
                      ref.read(transactionRepositoryProvider).delete(t.id);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transação excluída')));
                    },
                    child: TransactionTile(
                      description: t.description,
                      formattedAmount: '${isIncome ? '+' : '-'}R\$ ${t.amount.toStringAsFixed(2)}',
                      category: t.categoryId,
                      categoryIcon: isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                      categoryColor: isIncome ? Colors.green : Colors.red,
                      date: t.transactionDate,
                      isIncome: isIncome,
                      onTap: () => context.push('/transactions/${t.id}'),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/transactions/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

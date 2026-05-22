import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/utils/currency_formatter.dart';
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
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Nenhuma transação', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600)),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Adicione sua primeira transação', style: TextStyle(color: Colors.grey.shade500)),
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton.icon(
                      onPressed: () => context.push('/transactions/new'),
                      icon: const Icon(Icons.add),
                      label: const Text('Nova Transação'),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(transactionListProvider),
                child: ListView.builder(
                  padding: AppSpacing.screenPadding,
                  itemCount: transactions.length,
                  itemBuilder: (_, i) {
                    final t = transactions[i];
                    final isIncome = t.type == 'income';
                    return Dismissible(
                      key: Key(t.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: AppColors.expense,
                          borderRadius: AppRadius.borderRadiusMd,
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Excluir Transação'),
                            content: const Text('Tem certeza que deseja excluir?'),
                            actions: [
                              TextButton(onPressed: () => context.pop(false), child: const Text('Cancelar')),
                              TextButton(
                                onPressed: () => context.pop(true),
                                style: TextButton.styleFrom(foregroundColor: AppColors.expense),
                                child: const Text('Excluir'),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) {
                        ref.read(transactionRepositoryProvider).delete(t.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Transação excluída'),
                            action: SnackBarAction(label: 'Desfazer', onPressed: () {}),
                          ),
                        );
                      },
                      child: TransactionTile(
                        description: t.description,
                        formattedAmount: '${isIncome ? '+' : '-'}${CurrencyFormatter.format(t.amount)}',
                        category: t.categoryId,
                        categoryIcon: isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                        categoryColor: isIncome ? AppColors.income : AppColors.expense,
                        date: t.transactionDate,
                        isIncome: isIncome,
                        onTap: () => context.push('/transactions/${t.id}'),
                      ),
                    );
                  },
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.expense),
              const SizedBox(height: AppSpacing.md),
              const Text('Erro ao carregar transações'),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(transactionListProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/transactions/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

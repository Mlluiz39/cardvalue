import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/utils/currency_formatter.dart';
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

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'low': return AppColors.info;
      case 'high': return AppColors.expense;
      default: return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(debtListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Dívidas')),
      body: debtsAsync.when(
        data: (debts) => debts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_balance_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Nenhuma dívida registrada', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600)),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Registre suas dívidas para acompanhar', style: TextStyle(color: Colors.grey.shade500)),
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton.icon(
                      onPressed: () => context.push('/debts/new'),
                      icon: const Icon(Icons.add),
                      label: const Text('Nova Dívida'),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(debtListProvider),
                child: ListView.builder(
                  padding: AppSpacing.screenPadding,
                  itemCount: debts.length,
                  itemBuilder: (_, i) {
                    final debt = debts[i];
                    return Card(
                      child: ListTile(
                        title: Text(debt.title),
                        subtitle: Text('${CurrencyFormatter.format(debt.remainingAmount)} restantes'),
                        trailing: Chip(
                          label: Text(_priorityLabel(debt.priority), style: const TextStyle(fontSize: 12)),
                          backgroundColor: _priorityColor(debt.priority).withValues(alpha: 0.1),
                          side: BorderSide(color: _priorityColor(debt.priority).withValues(alpha: 0.3)),
                        ),
                        onTap: () => context.push('/debts/${debt.id}'),
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
              const Text('Erro ao carregar dívidas'),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(debtListProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/debts/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

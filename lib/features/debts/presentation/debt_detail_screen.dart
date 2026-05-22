import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../shared/utils/currency_formatter.dart';
import 'debt_providers.dart';

class DebtDetailScreen extends ConsumerWidget {
  final String debtId;

  const DebtDetailScreen({super.key, required this.debtId});

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
    final debtAsync = ref.watch(debtDetailProvider(debtId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Dívida'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.expense),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: debtAsync.when(
        data: (debt) {
          if (debt == null) return const Center(child: Text('Dívida não encontrada'));

          final progress = debt.totalAmount > 0 ? (debt.totalAmount - debt.remainingAmount) / debt.totalAmount : 0.0;
          final paidAmount = debt.totalAmount - debt.remainingAmount;

          return ListView(
            padding: AppSpacing.screenPadding,
            children: [
              Card(
                child: Padding(
                  padding: AppSpacing.cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.account_balance, color: _priorityColor(debt.priority)),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(debt.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          ),
                          Chip(
                            label: Text(_priorityLabel(debt.priority), style: const TextStyle(fontSize: 12)),
                            backgroundColor: _priorityColor(debt.priority).withValues(alpha: 0.1),
                            side: BorderSide(color: _priorityColor(debt.priority).withValues(alpha: 0.3)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Card(
                child: Padding(
                  padding: AppSpacing.cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Progresso de Pagamento', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppSpacing.md),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          minHeight: 12,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(progress >= 1.0 ? AppColors.success : AppColors.info),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${(progress * 100).toStringAsFixed(0)}% pago', style: TextStyle(color: Colors.grey.shade600)),
                          Text('${CurrencyFormatter.format(paidAmount)} / ${CurrencyFormatter.format(debt.totalAmount)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Card(
                child: Padding(
                  padding: AppSpacing.cardPadding,
                  child: Column(
                    children: [
                      _detailRow('Valor Total', CurrencyFormatter.format(debt.totalAmount)),
                      const Divider(),
                      _detailRow('Valor Restante', CurrencyFormatter.format(debt.remainingAmount)),
                      const Divider(),
                      _detailRow('Taxa de Juros', '${debt.interestRate.toStringAsFixed(1)}%'),
                      const Divider(),
                      _detailRow('Parcelas', '${debt.remainingInstallments} de ${debt.totalInstallments}'),
                      const Divider(),
                      _detailRow('Vencimento', debt.dueDate.format()),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.expense),
              const SizedBox(height: AppSpacing.md),
              const Text('Erro ao carregar dívida'),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(debtDetailProvider(debtId)),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Dívida'),
        content: const Text('Tem certeza que deseja excluir esta dívida?'),
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

    if (confirm == true) {
      try {
        await ref.read(debtRepositoryProvider).delete(debtId);
        if (context.mounted) context.pop();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Erro ao excluir dívida'), backgroundColor: AppColors.expense),
          );
        }
      }
    }
  }
}

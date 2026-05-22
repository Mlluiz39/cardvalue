import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../shared/utils/currency_formatter.dart';
import 'goal_providers.dart';

class GoalDetailScreen extends ConsumerWidget {
  final String goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(goalDetailProvider(goalId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Meta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.expense),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: goalAsync.when(
        data: (goal) {
          if (goal == null) return const Center(child: Text('Meta não encontrada'));

          final progress = goal.targetAmount > 0 ? goal.currentAmount / goal.targetAmount : 0.0;
          final remaining = goal.targetAmount - goal.currentAmount;
          final monthsToGoal = goal.monthlyContribution != null && goal.monthlyContribution! > 0
              ? (remaining / goal.monthlyContribution!).ceil()
              : null;

          return ListView(
            padding: AppSpacing.screenPadding,
            children: [
              Card(
                child: Padding(
                  padding: AppSpacing.cardPadding,
                  child: Column(
                    children: [
                      Icon(Icons.flag, size: 48, color: progress >= 1.0 ? AppColors.success : AppColors.info),
                      const SizedBox(height: AppSpacing.md),
                      Text(goal.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      const SizedBox(height: AppSpacing.sm),
                      if (progress >= 1.0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(20)),
                          child: Text('Meta Alcançada!', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
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
                      Text('Progresso', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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
                          Text('${(progress * 100).toStringAsFixed(0)}% concluído', style: TextStyle(color: Colors.grey.shade600)),
                          Text('${CurrencyFormatter.format(goal.currentAmount)} / ${CurrencyFormatter.format(goal.targetAmount)}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                      _detailRow('Valor Alvo', CurrencyFormatter.format(goal.targetAmount)),
                      const Divider(),
                      _detailRow('Valor Atual', CurrencyFormatter.format(goal.currentAmount)),
                      const Divider(),
                      _detailRow('Faltam', CurrencyFormatter.format(remaining > 0 ? remaining : 0)),
                      if (goal.monthlyContribution != null && goal.monthlyContribution! > 0) ...[
                        const Divider(),
                        _detailRow('Contribuição Mensal', CurrencyFormatter.format(goal.monthlyContribution!)),
                        if (monthsToGoal != null && monthsToGoal > 0) ...[
                          const Divider(),
                          _detailRow('Previsão', '$monthsToGoal meses'),
                        ],
                      ],
                      if (goal.deadline != null) ...[
                        const Divider(),
                        _detailRow('Prazo', goal.deadline!.format()),
                      ],
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
              const Text('Erro ao carregar meta'),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(goalDetailProvider(goalId)),
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
        title: const Text('Excluir Meta'),
        content: const Text('Tem certeza que deseja excluir esta meta?'),
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
        await ref.read(goalRepositoryProvider).delete(goalId);
        if (context.mounted) context.pop();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Erro ao excluir meta'), backgroundColor: AppColors.expense),
          );
        }
      }
    }
  }
}

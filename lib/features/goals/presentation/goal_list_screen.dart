import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/utils/currency_formatter.dart';
import 'goal_providers.dart';

class GoalListScreen extends ConsumerWidget {
  const GoalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Metas')),
      body: goalsAsync.when(
        data: (goals) => goals.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.flag_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Nenhuma meta criada', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600)),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Defina metas para suas economias', style: TextStyle(color: Colors.grey.shade500)),
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton.icon(
                      onPressed: () => context.push('/goals/new'),
                      icon: const Icon(Icons.add),
                      label: const Text('Nova Meta'),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(goalListProvider),
                child: ListView.builder(
                  padding: AppSpacing.screenPadding,
                  itemCount: goals.length,
                  itemBuilder: (_, i) {
                    final goal = goals[i];
                    final progress = goal.targetAmount > 0 ? goal.currentAmount / goal.targetAmount : 0.0;
                    return Card(
                      child: InkWell(
                        onTap: () => context.push('/goals/${goal.id}'),
                        borderRadius: AppRadius.borderRadiusMd,
                        child: Padding(
                          padding: AppSpacing.cardPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.flag, color: AppColors.info, size: 20),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(child: Text(goal.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress.clamp(0.0, 1.0),
                                  minHeight: 8,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation(progress >= 1.0 ? AppColors.success : AppColors.info),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${CurrencyFormatter.format(goal.currentAmount)} / ${CurrencyFormatter.format(goal.targetAmount)}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                                  Text('${(progress * 100).toStringAsFixed(0)}%', style: TextStyle(fontWeight: FontWeight.bold, color: progress >= 1.0 ? AppColors.success : AppColors.info)),
                                ],
                              ),
                            ],
                          ),
                        ),
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
              const Text('Erro ao carregar metas'),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(goalListProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/goals/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

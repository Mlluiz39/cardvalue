import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import '../../cards/presentation/card_providers.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(categoryBreakdownProvider);
    final monthlySpendingAsync = ref.watch(monthlySpendingProvider);
    final monthlyIncomeAsync = ref.watch(monthlyIncomeProvider);
    final cardsAsync = ref.watch(cardListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          Card(
            color: AppColors.infoLight,
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: AppColors.info),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Análise inteligente dos seus dados financeiros',
                      style: TextStyle(color: AppColors.info),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Categorias com Maior Gasto', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          categoryAsync.when(
            data: (categories) {
              if (categories.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: AppSpacing.md),
                        Text('Nenhum dado disponível', style: TextStyle(color: Colors.grey.shade600)),
                        const SizedBox(height: AppSpacing.sm),
                        Text('Registre transações para ver análises', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              }

              final topCategories = categories.take(5).toList();
              return Column(
                children: topCategories.map((cat) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.getCategoryColor(cat.categoryId).withValues(alpha: 0.2),
                      child: Icon(Icons.category, color: AppColors.getCategoryColor(cat.categoryId)),
                    ),
                    title: Text(cat.label),
                    subtitle: Text('${cat.percentage.toStringAsFixed(1)}% do total'),
                    trailing: Text(CurrencyFormatter.format(cat.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('Erro ao carregar categorias', style: TextStyle(color: AppColors.expense)))),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Alertas', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          cardsAsync.when(
            data: (cards) {
              final alerts = <_InsightAlert>[];

              for (final card in cards) {
                final usage = card.limitAmount > 0 ? card.usedAmount / card.limitAmount : 0.0;
                if (usage >= 0.8) {
                  alerts.add(_InsightAlert(
                    title: 'Limite próximo do máximo',
                    message: '${card.bankName} - ${card.cardName} está em ${(usage * 100).toStringAsFixed(0)}%',
                    icon: Icons.warning_amber,
                    color: AppColors.warning,
                  ));
                }
              }

              monthlySpendingAsync.whenData((spending) {
                monthlyIncomeAsync.whenData((income) {
                  if (income > 0 && spending > income) {
                    alerts.add(_InsightAlert(
                      title: 'Gastos acima da receita',
                      message: 'Seus gastos (${CurrencyFormatter.format(spending)}) superam sua receita (${CurrencyFormatter.format(income)})',
                      icon: Icons.trending_down,
                      color: AppColors.expense,
                    ));
                  }
                });
              });

              if (alerts.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_outline, size: 48, color: AppColors.success),
                        const SizedBox(height: AppSpacing.md),
                        Text('Tudo certo!', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppSpacing.sm),
                        Text('Nenhum alerta no momento', style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: alerts.map((alert) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: alert.color.withValues(alpha: 0.2),
                      child: Icon(alert.icon, color: alert.color),
                    ),
                    title: Text(alert.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(alert.message),
                  ),
                )).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('Erro ao carregar alertas', style: TextStyle(color: AppColors.expense)))),
          ),
        ],
      ),
    );
  }
}

class _InsightAlert {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  _InsightAlert({required this.title, required this.message, required this.icon, required this.color});
}

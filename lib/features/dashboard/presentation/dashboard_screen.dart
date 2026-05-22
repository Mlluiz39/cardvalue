import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../shared/widgets/expense_card.dart';
import '../../../shared/widgets/category_pie_chart.dart';
import '../../../shared/widgets/upcoming_bills.dart';
import 'dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyExpenseAsync = ref.watch(monthlySpendingProvider);
    final monthlyIncomeAsync = ref.watch(monthlyIncomeProvider);
    final categoryBreakdownAsync = ref.watch(categoryBreakdownProvider);
    final upcomingBillsAsync = ref.watch(upcomingBillsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          Row(
            children: [
              Expanded(
                child: monthlyIncomeAsync.when(
                  data: (total) => ExpenseCard(
                    title: 'Receitas do Mês',
                    amount: total,
                    formattedAmount: CurrencyFormatter.format(total),
                    icon: Icons.trending_up,
                    color: AppColors.income,
                  ),
                  loading: () => const ExpenseCard(
                    title: 'Receitas do Mês',
                    amount: 0,
                    formattedAmount: 'Carregando...',
                    icon: Icons.trending_up,
                    color: AppColors.income,
                  ),
                  error: (_, _) => const ExpenseCard(
                    title: 'Receitas do Mês',
                    amount: 0,
                    formattedAmount: 'Erro',
                    icon: Icons.trending_up,
                    color: AppColors.income,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: monthlyExpenseAsync.when(
                  data: (total) => ExpenseCard(
                    title: 'Gastos do Mês',
                    amount: total,
                    formattedAmount: CurrencyFormatter.format(total),
                    icon: Icons.trending_down,
                    color: AppColors.expense,
                  ),
                  loading: () => const ExpenseCard(
                    title: 'Gastos do Mês',
                    amount: 0,
                    formattedAmount: 'Carregando...',
                    icon: Icons.trending_down,
                    color: AppColors.expense,
                  ),
                  error: (_, _) => const ExpenseCard(
                    title: 'Gastos do Mês',
                    amount: 0,
                    formattedAmount: 'Erro',
                    icon: Icons.trending_down,
                    color: AppColors.expense,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Gastos por Categoria', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          categoryBreakdownAsync.when(
            data: (categories) {
              if (categories.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: AppSpacing.sm),
                        Text('Nenhum gasto este mês', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                );
              }

              final pieData = categories.map((c) => CategorySpending(
                name: c.label,
                amount: c.amount,
                percentage: c.percentage,
                color: AppColors.getCategoryColor(c.categoryId),
              )).toList();

              return CategoryPieChart(categories: pieData);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro ao carregar categorias', style: TextStyle(color: AppColors.expense))),
          ),
          const SizedBox(height: AppSpacing.lg),
          upcomingBillsAsync.when(
            data: (bills) => UpcomingBills(bills: bills),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro ao carregar contas', style: TextStyle(color: AppColors.expense))),
          ),
        ],
      ),
    );
  }
}

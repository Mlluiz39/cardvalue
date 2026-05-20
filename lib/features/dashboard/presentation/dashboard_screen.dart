import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: monthlyIncomeAsync.when(
                  data: (total) => ExpenseCard(
                    title: 'Receitas do Mês',
                    amount: total,
                    formattedAmount: 'R\$ ${total.toStringAsFixed(2)}',
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                  loading: () => const ExpenseCard(
                    title: 'Receitas do Mês',
                    amount: 0,
                    formattedAmount: 'Carregando...',
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                  error: (_, _) => const ExpenseCard(
                    title: 'Receitas do Mês',
                    amount: 0,
                    formattedAmount: 'Erro',
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: monthlyExpenseAsync.when(
                  data: (total) => ExpenseCard(
                    title: 'Gastos do Mês',
                    amount: total,
                    formattedAmount: 'R\$ ${total.toStringAsFixed(2)}',
                    icon: Icons.trending_down,
                    color: Colors.red,
                  ),
                  loading: () => const ExpenseCard(
                    title: 'Gastos do Mês',
                    amount: 0,
                    formattedAmount: 'Carregando...',
                    icon: Icons.trending_down,
                    color: Colors.red,
                  ),
                  error: (_, _) => const ExpenseCard(
                    title: 'Gastos do Mês',
                    amount: 0,
                    formattedAmount: 'Erro',
                    icon: Icons.trending_down,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Gastos por Categoria', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          categoryBreakdownAsync.when(
            data: (categories) {
              if (categories.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('Nenhum gasto este mês')),
                  ),
                );
              }
              
              final pieData = categories.map((c) => CategorySpending(
                name: c.label,
                amount: c.amount,
                percentage: c.percentage,
                color: _getColorForCategory(c.categoryId),
              )).toList();
              
              return CategoryPieChart(categories: pieData);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro: $e')),
          ),
          const SizedBox(height: 16),
          upcomingBillsAsync.when(
            data: (bills) => UpcomingBills(bills: bills),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro: $e')),
          ),
        ],
      ),
    );
  }

  Color _getColorForCategory(String categoryId) {
    switch (categoryId) {
      case 'food': return Colors.orange;
      case 'transport': return Colors.blue;
      case 'housing': return Colors.brown;
      case 'health': return Colors.red;
      case 'education': return Colors.purple;
      case 'entertainment': return Colors.pink;
      case 'clothing': return Colors.teal;
      case 'salary': return Colors.green;
      case 'freelance': return Colors.lightGreen;
      default: return Colors.grey;
    }
  }
}

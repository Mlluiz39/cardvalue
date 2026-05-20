import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'reports_providers.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  static const _chartColors = [
    Color(0xFF6366F1), // indigo
    Color(0xFF22D3EE), // cyan
    Color(0xFFF59E0B), // amber
    Color(0xFFEF4444), // red
    Color(0xFF10B981), // emerald
    Color(0xFF8B5CF6), // violet
    Color(0xFFF97316), // orange
    Color(0xFF14B8A6), // teal
    Color(0xFFEC4899), // pink
    Color(0xFF64748B), // slate
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMonthlySummary(context, ref),
          const SizedBox(height: 16),
          _buildMonthlyComparison(context, ref),
          const SizedBox(height: 16),
          _buildCategoryBreakdown(context, ref),
          const SizedBox(height: 16),
          _buildPaymentMethodBreakdown(context, ref),
          const SizedBox(height: 16),
          _buildCardSummary(context, ref),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMonthlySummary(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(monthlySummaryProvider);
    return summaryAsync.when(
      data: (summary) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Resumo de ${summary.monthLabel}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _summaryTile(context, 'Receitas', summary.totalIncome, Colors.green)),
                  const SizedBox(width: 8),
                  Expanded(child: _summaryTile(context, 'Despesas', summary.totalExpense, Colors.red)),
                  const SizedBox(width: 8),
                  Expanded(child: _summaryTile(
                    context,
                    'Saldo',
                    summary.balance,
                    summary.balance >= 0 ? Colors.blue : Colors.orange,
                  )),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${summary.transactionCount} transações registradas',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
      loading: () => const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))),
      error: (e, _) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('Erro: $e'))),
    );
  }

  Widget _summaryTile(BuildContext context, String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            'R\$ ${amount.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyComparison(BuildContext context, WidgetRef ref) {
    final comparisonAsync = ref.watch(monthlyComparisonProvider);
    return comparisonAsync.when(
      data: (months) {
        final hasData = months.any((m) => m.totalExpense > 0 || m.totalIncome > 0);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.trending_up, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Comparativo Mensal',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _legendDot(Colors.green, 'Receitas'),
                    const SizedBox(width: 16),
                    _legendDot(Colors.red, 'Despesas'),
                  ],
                ),
                const SizedBox(height: 16),
                if (!hasData)
                  const SizedBox(
                    height: 180,
                    child: Center(child: Text('Nenhum dado para exibir', style: TextStyle(color: Colors.grey))),
                  )
                else
                  SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx >= 0 && idx < months.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(months[idx].monthLabel, style: const TextStyle(fontSize: 11)),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: months.asMap().entries.map((e) {
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(toY: e.value.totalIncome, color: Colors.green, width: 10, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                              BarChartRodData(toY: e.value.totalExpense, color: Colors.red, width: 10, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))),
      error: (e, _) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('Erro: $e'))),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildCategoryBreakdown(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryBreakdownProvider);
    return categoriesAsync.when(
      data: (categories) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.pie_chart, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Gastos por Categoria',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (categories.isEmpty)
                const SizedBox(
                  height: 120,
                  child: Center(child: Text('Nenhuma despesa registrada este mês', style: TextStyle(color: Colors.grey))),
                )
              else ...[
                SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: categories.asMap().entries.map((e) {
                        final color = _chartColors[e.key % _chartColors.length];
                        return PieChartSectionData(
                          value: e.value.amount,
                          title: '${e.value.percentage.toStringAsFixed(0)}%',
                          color: color,
                          radius: 50,
                          titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...categories.asMap().entries.map((e) {
                  final cat = e.value;
                  final color = _chartColors[e.key % _chartColors.length];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
                        const SizedBox(width: 8),
                        Expanded(child: Text(cat.label)),
                        Text('${cat.count}x', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(width: 8),
                        Text(
                          'R\$ ${cat.amount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
      loading: () => const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))),
      error: (e, _) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('Erro: $e'))),
    );
  }

  Widget _buildPaymentMethodBreakdown(BuildContext context, WidgetRef ref) {
    final methodsAsync = ref.watch(paymentMethodBreakdownProvider);
    return methodsAsync.when(
      data: (methods) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.payment, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Gastos por Método de Pagamento',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (methods.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: Text('Nenhuma despesa registrada este mês', style: TextStyle(color: Colors.grey))),
                )
              else
                ...methods.map((m) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(_paymentIcon(m.method), size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(child: Text(m.label)),
                      Text('${m.count}x', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(width: 8),
                      Text(
                        'R\$ ${m.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )),
            ],
          ),
        ),
      ),
      loading: () => const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))),
      error: (e, _) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('Erro: $e'))),
    );
  }

  IconData _paymentIcon(String method) {
    switch (method) {
      case 'pix': return Icons.qr_code;
      case 'debit': return Icons.credit_card;
      case 'cash': return Icons.money;
      case 'transfer': return Icons.swap_horiz;
      case 'boleto': return Icons.receipt;
      case 'subscription': return Icons.autorenew;
      case 'credit_card': return Icons.credit_card;
      default: return Icons.more_horiz;
    }
  }

  Widget _buildCardSummary(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(cardSummaryProvider);
    return cardsAsync.when(
      data: (cards) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.credit_card, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Resumo dos Cartões',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (cards.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: Text('Nenhum cartão cadastrado', style: TextStyle(color: Colors.grey))),
                )
              else
                ...cards.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${c.bankName} - ${c.cardName}', style: const TextStyle(fontWeight: FontWeight.w500)),
                          Text(
                            '${c.usagePercent.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: c.usagePercent > 80 ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: c.limitAmount > 0 ? c.usedAmount / c.limitAmount : 0,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(c.usagePercent > 80 ? Colors.red : Colors.green),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'R\$ ${c.usedAmount.toStringAsFixed(2)} / R\$ ${c.limitAmount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                )),
            ],
          ),
        ),
      ),
      loading: () => const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))),
      error: (e, _) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('Erro: $e'))),
    );
  }
}

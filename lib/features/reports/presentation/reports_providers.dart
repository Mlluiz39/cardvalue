import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transactions/presentation/transaction_providers.dart';
import '../../cards/presentation/card_providers.dart';

final _monthNames = [
  'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
  'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
];

class MonthlySummary {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final int transactionCount;
  final String monthLabel;

  MonthlySummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionCount,
    required this.monthLabel,
  });
}

class CategorySummary {
  final String categoryId;
  final String label;
  final double amount;
  final double percentage;
  final int count;

  CategorySummary({
    required this.categoryId,
    required this.label,
    required this.amount,
    required this.percentage,
    required this.count,
  });
}

class CardSummary {
  final String cardId;
  final String cardName;
  final String bankName;
  final double usedAmount;
  final double limitAmount;
  final double usagePercent;

  CardSummary({
    required this.cardId,
    required this.cardName,
    required this.bankName,
    required this.usedAmount,
    required this.limitAmount,
    required this.usagePercent,
  });
}

class PaymentMethodSummary {
  final String method;
  final String label;
  final double amount;
  final int count;

  PaymentMethodSummary({
    required this.method,
    required this.label,
    required this.amount,
    required this.count,
  });
}

String _paymentMethodLabel(String method) {
  switch (method) {
    case 'pix': return 'PIX';
    case 'debit': return 'Débito';
    case 'cash': return 'Dinheiro';
    case 'transfer': return 'Transferência';
    case 'boleto': return 'Boleto';
    case 'subscription': return 'Assinatura';
    case 'credit_card': return 'Cartão de Crédito';
    default: return 'Outro';
  }
}

String _categoryLabel(String categoryId) {
  switch (categoryId) {
    case 'food': return 'Alimentação';
    case 'transport': return 'Transporte';
    case 'housing': return 'Moradia';
    case 'health': return 'Saúde';
    case 'education': return 'Educação';
    case 'entertainment': return 'Lazer';
    case 'clothing': return 'Vestuário';
    case 'salary': return 'Salário';
    case 'freelance': return 'Freelance';
    default: return 'Outros';
  }
}

final monthlySummaryProvider = FutureProvider<MonthlySummary>((ref) async {
  final transactions = await ref.watch(transactionListProvider.future);
  final now = DateTime.now();
  final monthTx = transactions.where(
    (t) => t.transactionDate.month == now.month && t.transactionDate.year == now.year,
  ).toList();

  final income = monthTx.where((t) => t.isIncome).fold<double>(0, (s, t) => s + t.amount);
  final expense = monthTx.where((t) => !t.isIncome).fold<double>(0, (s, t) => s + t.amount);

  return MonthlySummary(
    totalIncome: income,
    totalExpense: expense,
    balance: income - expense,
    transactionCount: monthTx.length,
    monthLabel: '${_monthNames[now.month - 1]} ${now.year}',
  );
});

final categoryBreakdownProvider = FutureProvider<List<CategorySummary>>((ref) async {
  final transactions = await ref.watch(transactionListProvider.future);
  final now = DateTime.now();
  final expenses = transactions.where(
    (t) => !t.isIncome && t.transactionDate.month == now.month && t.transactionDate.year == now.year,
  ).toList();

  if (expenses.isEmpty) return [];

  final totals = <String, double>{};
  final counts = <String, int>{};
  for (final t in expenses) {
    totals[t.categoryId] = (totals[t.categoryId] ?? 0) + t.amount;
    counts[t.categoryId] = (counts[t.categoryId] ?? 0) + 1;
  }

  final totalExpense = totals.values.fold<double>(0, (s, v) => s + v);
  final sorted = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

  return sorted.map((e) => CategorySummary(
    categoryId: e.key,
    label: _categoryLabel(e.key),
    amount: e.value,
    percentage: totalExpense > 0 ? (e.value / totalExpense) * 100 : 0,
    count: counts[e.key] ?? 0,
  )).toList();
});

final cardSummaryProvider = FutureProvider<List<CardSummary>>((ref) async {
  final cards = await ref.watch(cardListProvider.future);
  return cards.map((c) => CardSummary(
    cardId: c.id,
    cardName: c.cardName,
    bankName: c.bankName,
    usedAmount: c.usedAmount,
    limitAmount: c.limitAmount,
    usagePercent: c.limitAmount > 0 ? (c.usedAmount / c.limitAmount) * 100 : 0,
  )).toList();
});

final monthlyComparisonProvider = FutureProvider<List<MonthlySummary>>((ref) async {
  final transactions = await ref.watch(transactionListProvider.future);
  final now = DateTime.now();
  final summaries = <MonthlySummary>[];

  for (var i = 5; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i, 1);
    final monthTx = transactions.where(
      (t) => t.transactionDate.month == month.month && t.transactionDate.year == month.year,
    ).toList();

    final income = monthTx.where((t) => t.isIncome).fold<double>(0, (s, t) => s + t.amount);
    final expense = monthTx.where((t) => !t.isIncome).fold<double>(0, (s, t) => s + t.amount);

    summaries.add(MonthlySummary(
      totalIncome: income,
      totalExpense: expense,
      balance: income - expense,
      transactionCount: monthTx.length,
      monthLabel: _monthNames[month.month - 1],
    ));
  }

  return summaries;
});

final paymentMethodBreakdownProvider = FutureProvider<List<PaymentMethodSummary>>((ref) async {
  final transactions = await ref.watch(transactionListProvider.future);
  final now = DateTime.now();
  final monthTx = transactions.where(
    (t) => !t.isIncome && t.transactionDate.month == now.month && t.transactionDate.year == now.year,
  ).toList();

  if (monthTx.isEmpty) return [];

  final totals = <String, double>{};
  final counts = <String, int>{};
  for (final t in monthTx) {
    final method = t.paymentMethod ?? 'other';
    totals[method] = (totals[method] ?? 0) + t.amount;
    counts[method] = (counts[method] ?? 0) + 1;
  }

  final sorted = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  return sorted.map((e) => PaymentMethodSummary(
    method: e.key,
    label: _paymentMethodLabel(e.key),
    amount: e.value,
    count: counts[e.key] ?? 0,
  )).toList();
});

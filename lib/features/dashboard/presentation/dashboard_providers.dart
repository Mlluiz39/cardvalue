import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cards/presentation/card_providers.dart';
import '../../transactions/presentation/transaction_providers.dart';
import '../../installments/presentation/purchase_providers.dart';
import '../../../shared/widgets/upcoming_bills.dart';

final monthlySpendingProvider = FutureProvider<double>((ref) {
  return ref.watch(transactionListProvider.future).then((transactions) {
    final now = DateTime.now();
    final monthTransactions = transactions.where((t) =>
      t.type == 'expense' &&
      t.transactionDate.month == now.month &&
      t.transactionDate.year == now.year);
    return monthTransactions.fold<double>(0.0, (sum, t) => sum + t.amount);
  });
});

final monthlyIncomeProvider = FutureProvider<double>((ref) {
  return ref.watch(transactionListProvider.future).then((transactions) {
    final now = DateTime.now();
    final monthTransactions = transactions.where((t) =>
      t.type == 'income' &&
      t.transactionDate.month == now.month &&
      t.transactionDate.year == now.year);
    return monthTransactions.fold<double>(0.0, (sum, t) => sum + t.amount);
  });
});

class CategoryData {
  final String categoryId;
  final String label;
  final double amount;
  final double percentage;

  CategoryData(this.categoryId, this.label, this.amount, this.percentage);
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

final categoryBreakdownProvider = FutureProvider<List<CategoryData>>((ref) {
  return ref.watch(transactionListProvider.future).then((transactions) {
    final now = DateTime.now();
    final monthExpenses = transactions.where((t) =>
      t.type == 'expense' &&
      t.transactionDate.month == now.month &&
      t.transactionDate.year == now.year);
    
    if (monthExpenses.isEmpty) return [];

    final totals = <String, double>{};
    for (final t in monthExpenses) {
      totals[t.categoryId] = (totals[t.categoryId] ?? 0) + t.amount;
    }

    final totalExpense = totals.values.fold<double>(0, (s, v) => s + v);
    final sorted = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return sorted.map((e) => CategoryData(
      e.key,
      _categoryLabel(e.key),
      e.value,
      totalExpense > 0 ? (e.value / totalExpense) * 100 : 0,
    )).toList();
  });
});

final upcomingBillsProvider = FutureProvider<List<UpcomingBill>>((ref) async {
  final cards = await ref.watch(cardListProvider.future);
  final purchases = await ref.watch(purchaseListProvider.future);
  final now = DateTime.now();
  final bills = <UpcomingBill>[];

  for (final card in cards) {
    // Determine the next due date for this card
    var dueDate = DateTime(now.year, now.month, card.dueDay);
    var closingDate = DateTime(now.year, now.month, card.closingDay);
    
    // If the due date has passed, we look at next month's invoice
    if (now.isAfter(dueDate)) {
      dueDate = DateTime(now.year, now.month + 1, card.dueDay);
      closingDate = DateTime(now.year, now.month + 1, card.closingDay);
    }
    
    // Previous closing date
    final prevClosingDate = DateTime(closingDate.year, closingDate.month - 1, closingDate.day);

    // Sum purchases made between the previous closing date and the current closing date
    // Also include any installment portions due this month (simplified for now to just totalAmount if no installment logic is deep)
    final cardPurchases = purchases.where((p) => p.cardId == card.id);
    double invoiceAmount = 0;
    
    for (final p in cardPurchases) {
      if (p.purchaseDate.isAfter(prevClosingDate) && p.purchaseDate.isBefore(closingDate.add(const Duration(days: 1)))) {
        // Full purchase within the cycle
        invoiceAmount += p.totalAmount; 
      }
    }

    if (invoiceAmount > 0) {
      bills.add(UpcomingBill(
        description: 'Fatura ${card.cardName}',
        amount: invoiceAmount,
        dueDate: dueDate,
        category: 'Cartão de Crédito',
      ));
    }
  }

  bills.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  return bills;
});

final cardSpendingProvider = FutureProvider<double>((ref) {
  return ref.watch(cardListProvider.future).then((cards) {
    return cards.fold<double>(0.0, (sum, c) => sum + c.usedAmount);
  });
});


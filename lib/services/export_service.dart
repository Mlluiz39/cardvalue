import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'drift_database.dart';

class ExportService {
  final AppDatabase _db;

  ExportService(this._db);

  Future<File> exportToJsonFile() async {
    final cards = await _db.select(_db.cards).get();
    final purchases = await _db.select(_db.purchases).get();
    final installments = await _db.select(_db.installments).get();
    final invoiceCycles = await _db.select(_db.invoiceCycles).get();
    final transactions = await _db.select(_db.transactions).get();
    final debts = await _db.select(_db.debts).get();
    final goals = await _db.select(_db.goals).get();
    final categories = await _db.select(_db.categories).get();

    final data = {
      'exported_at': DateTime.now().toIso8601String(),
      'cards': cards.map((c) => _cardToJson(c)).toList(),
      'purchases': purchases.map((p) => _purchaseToJson(p)).toList(),
      'installments': installments.map((i) => _installmentToJson(i)).toList(),
      'invoice_cycles': invoiceCycles.map((ic) => _invoiceCycleToJson(ic)).toList(),
      'transactions': transactions.map((t) => _transactionToJson(t)).toList(),
      'debts': debts.map((d) => _debtToJson(d)).toList(),
      'goals': goals.map((g) => _goalToJson(g)).toList(),
      'categories': categories.map((c) => _categoryToJson(c)).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'cardvalue_backup.json'));
    await file.writeAsString(jsonString);
    return file;
  }

  Map<String, dynamic> _cardToJson(Card c) {
    return {
      'id': c.id,
      'user_id': c.userId,
      'bank_name': c.bankName,
      'card_name': c.cardName,
      'brand': c.brand,
      'card_type': c.cardType,
      'limit_amount': c.limitAmount,
      'closing_day': c.closingDay,
      'due_day': c.dueDay,
      'color': c.color,
      'is_active': c.isActive,
      'created_at': c.createdAt.toIso8601String(),
      'updated_at': c.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _purchaseToJson(Purchase p) {
    return {
      'id': p.id,
      'card_id': p.cardId,
      'user_id': p.userId,
      'merchant_name': p.merchantName,
      'total_amount': p.totalAmount,
      'category_id': p.categoryId,
      'purchase_date': p.purchaseDate.toIso8601String(),
      'installment_count': p.installmentCount,
      'notes': p.notes,
      'is_reconciled': p.isReconciled,
      'created_at': p.createdAt.toIso8601String(),
      'updated_at': p.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _installmentToJson(Installment i) {
    return {
      'id': i.id,
      'purchase_id': i.purchaseId,
      'invoice_cycle_id': i.invoiceCycleId,
      'user_id': i.userId,
      'sequence_number': i.sequenceNumber,
      'total_installments': i.totalInstallments,
      'amount': i.amount,
      'due_date': i.dueDate.toIso8601String(),
      'status': i.status,
      'paid_at': i.paidAt?.toIso8601String(),
      'created_at': i.createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _invoiceCycleToJson(InvoiceCycle ic) {
    return {
      'id': ic.id,
      'card_id': ic.cardId,
      'user_id': ic.userId,
      'month': ic.month,
      'year': ic.year,
      'closing_date': ic.closingDate.toIso8601String(),
      'due_date': ic.dueDate.toIso8601String(),
      'total_amount': ic.totalAmount,
      'is_paid': ic.isPaid,
      'paid_at': ic.paidAt?.toIso8601String(),
      'notes': ic.notes,
      'created_at': ic.createdAt.toIso8601String(),
      'updated_at': ic.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _transactionToJson(Transaction t) {
    return {
      'id': t.id,
      'user_id': t.userId,
      'type': t.type,
      'payment_method': t.paymentMethod,
      'category_id': t.categoryId,
      'description': t.description,
      'amount': t.amount,
      'transaction_date': t.transactionDate.toIso8601String(),
      'notes': t.notes,
      'recurrence_rule_id': t.recurrenceRuleId,
      'debt_id': t.debtId,
      'goal_id': t.goalId,
      'created_at': t.createdAt.toIso8601String(),
      'updated_at': t.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _debtToJson(Debt d) {
    return {
      'id': d.id,
      'user_id': d.userId,
      'title': d.title,
      'total_amount': d.totalAmount,
      'remaining_amount': d.remainingAmount,
      'interest_rate': d.interestRate,
      'total_installments': d.totalInstallments,
      'remaining_installments': d.remainingInstallments,
      'due_date': d.dueDate.toIso8601String(),
      'priority': d.priority,
      'status': d.status,
      'notes': d.notes,
      'created_at': d.createdAt.toIso8601String(),
      'updated_at': d.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _goalToJson(Goal g) {
    return {
      'id': g.id,
      'user_id': g.userId,
      'title': g.title,
      'target_amount': g.targetAmount,
      'current_amount': g.currentAmount,
      'deadline': g.deadline?.toIso8601String(),
      'category_id': g.categoryId,
      'monthly_contribution': g.monthlyContribution,
      'status': g.status,
      'created_at': g.createdAt.toIso8601String(),
      'updated_at': g.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _categoryToJson(Category c) {
    return {
      'id': c.id,
      'user_id': c.userId,
      'name': c.name,
      'icon': c.icon,
      'color': c.color,
      'type': c.type,
      'is_system': c.isSystem,
      'sort_order': c.sortOrder,
    };
  }
}

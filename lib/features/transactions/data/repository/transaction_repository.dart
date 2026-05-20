import 'dart:async';
import 'package:drift/drift.dart';
import '../../../../services/drift_database.dart' hide Transaction;
import '../../domain/models/transaction.dart';

class TransactionRepository {
  final AppDatabase _db;

  TransactionRepository() : _db = AppDatabase();

  Stream<List<Transaction>> watchAll(String userId) {
    return (_db.select(_db.transactions)
      ..where((t) => t.userId.equals(userId))
      ..orderBy([(t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc)]))
      .watch()
      .map((rows) => rows.map((r) => Transaction(
        id: r.id, userId: r.userId, type: r.type,
        paymentMethod: r.paymentMethod, categoryId: r.categoryId,
        description: r.description, amount: r.amount,
        transactionDate: r.transactionDate, notes: r.notes,
        recurrenceRuleId: r.recurrenceRuleId, debtId: r.debtId, goalId: r.goalId,
        createdAt: r.createdAt, updatedAt: r.updatedAt,
      )).toList());
  }

  Future<Transaction> create(Transaction transaction) async {
    final companion = TransactionsCompanion(
      id: Value(transaction.id), userId: Value(transaction.userId),
      type: Value(transaction.type), paymentMethod: Value<String?>(transaction.paymentMethod),
      categoryId: Value(transaction.categoryId), description: Value(transaction.description),
      amount: Value(transaction.amount), transactionDate: Value(transaction.transactionDate),
      notes: Value<String?>(transaction.notes),
      recurrenceRuleId: Value<String?>(transaction.recurrenceRuleId),
      debtId: Value<String?>(transaction.debtId), goalId: Value<String?>(transaction.goalId),
    );
    await _db.into(_db.transactions).insertOnConflictUpdate(companion);
    return transaction;
  }

  Future<List<Transaction>> getAll(String userId) async {
    final rows = await (_db.select(_db.transactions)
      ..where((t) => t.userId.equals(userId))
      ..orderBy([(t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc)]))
      .get();
    return rows.map((r) => Transaction(
      id: r.id, userId: r.userId, type: r.type,
      paymentMethod: r.paymentMethod, categoryId: r.categoryId,
      description: r.description, amount: r.amount,
      transactionDate: r.transactionDate, notes: r.notes,
      recurrenceRuleId: r.recurrenceRuleId, debtId: r.debtId, goalId: r.goalId,
      createdAt: r.createdAt, updatedAt: r.updatedAt,
    )).toList();
  }

  Future<Transaction?> getById(String id) async {
    final row = await (_db.select(_db.transactions)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return Transaction(
      id: row.id, userId: row.userId, type: row.type,
      paymentMethod: row.paymentMethod, categoryId: row.categoryId,
      description: row.description, amount: row.amount,
      transactionDate: row.transactionDate, notes: row.notes,
      recurrenceRuleId: row.recurrenceRuleId, debtId: row.debtId, goalId: row.goalId,
      createdAt: row.createdAt, updatedAt: row.updatedAt,
    );
  }

  Future<void> update(Transaction transaction) async {
    final companion = TransactionsCompanion(
      id: Value(transaction.id), userId: Value(transaction.userId),
      type: Value(transaction.type), paymentMethod: Value<String?>(transaction.paymentMethod),
      categoryId: Value(transaction.categoryId), description: Value(transaction.description),
      amount: Value(transaction.amount), transactionDate: Value(transaction.transactionDate),
      notes: Value<String?>(transaction.notes),
      recurrenceRuleId: Value<String?>(transaction.recurrenceRuleId),
      debtId: Value<String?>(transaction.debtId), goalId: Value<String?>(transaction.goalId),
    );
    await _db.into(_db.transactions).insertOnConflictUpdate(companion);
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }
}
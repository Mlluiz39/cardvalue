import 'dart:async';
import 'package:drift/drift.dart';
import '../../../../services/drift_database.dart' hide Debt;
import '../../domain/models/debt.dart';

class DebtRepository {
  final AppDatabase _db;

  DebtRepository() : _db = AppDatabase();

  Stream<List<Debt>> watchAll(String userId) {
    return (_db.select(_db.debts)..where((d) => d.userId.equals(userId))).watch().map((rows) =>
        rows.map((r) => Debt(
          id: r.id, userId: r.userId, title: r.title,
          totalAmount: r.totalAmount, remainingAmount: r.remainingAmount,
          interestRate: r.interestRate, totalInstallments: r.totalInstallments,
          remainingInstallments: r.remainingInstallments, dueDate: r.dueDate,
          priority: r.priority, status: r.status, notes: r.notes,
          createdAt: r.createdAt, updatedAt: r.updatedAt,
        )).toList());
  }

  Future<Debt> create(Debt debt) async {
    await _db.into(_db.debts).insertOnConflictUpdate(DebtsCompanion(
      id: Value(debt.id), userId: Value(debt.userId), title: Value(debt.title),
      totalAmount: Value(debt.totalAmount), remainingAmount: Value(debt.remainingAmount),
      interestRate: Value(debt.interestRate), totalInstallments: Value(debt.totalInstallments),
      remainingInstallments: Value(debt.remainingInstallments), dueDate: Value(debt.dueDate),
      priority: Value(debt.priority), status: Value(debt.status), notes: Value<String?>(debt.notes),
    ));
    return debt;
  }

  Future<List<Debt>> getAll(String userId) async {
    final rows = await (_db.select(_db.debts)..where((d) => d.userId.equals(userId))).get();
    return rows.map((r) => Debt(
      id: r.id, userId: r.userId, title: r.title,
      totalAmount: r.totalAmount, remainingAmount: r.remainingAmount,
      interestRate: r.interestRate, totalInstallments: r.totalInstallments,
      remainingInstallments: r.remainingInstallments, dueDate: r.dueDate,
      priority: r.priority, status: r.status, notes: r.notes,
      createdAt: r.createdAt, updatedAt: r.updatedAt,
    )).toList();
  }

  Future<Debt?> getById(String id) async {
    final row = await (_db.select(_db.debts)..where((d) => d.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return Debt(
      id: row.id, userId: row.userId, title: row.title,
      totalAmount: row.totalAmount, remainingAmount: row.remainingAmount,
      interestRate: row.interestRate, totalInstallments: row.totalInstallments,
      remainingInstallments: row.remainingInstallments, dueDate: row.dueDate,
      priority: row.priority, status: row.status, notes: row.notes,
      createdAt: row.createdAt, updatedAt: row.updatedAt,
    );
  }

  Future<Debt> update(Debt debt) async {
    await _db.into(_db.debts).insertOnConflictUpdate(DebtsCompanion(
      id: Value(debt.id), userId: Value(debt.userId), title: Value(debt.title),
      totalAmount: Value(debt.totalAmount), remainingAmount: Value(debt.remainingAmount),
      interestRate: Value(debt.interestRate), totalInstallments: Value(debt.totalInstallments),
      remainingInstallments: Value(debt.remainingInstallments), dueDate: Value(debt.dueDate),
      priority: Value(debt.priority), status: Value(debt.status), notes: Value<String?>(debt.notes),
    ));
    return debt;
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.debts)..where((d) => d.id.equals(id))).go();
  }
}
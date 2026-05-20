import 'dart:async';
import 'package:drift/drift.dart';
import '../../../../services/drift_database.dart' hide InvoiceCycle;
import '../local/invoice_cycle_local_ds.dart';
import '../../domain/models/invoice_cycle.dart';

class InvoiceCycleRepository {
  final InvoiceCycleLocalDs _local;

  InvoiceCycleRepository()
      : _local = InvoiceCycleLocalDs(AppDatabase());

  Stream<List<InvoiceCycle>> watchByCard(String cardId) {
    return _local.watchByCard(cardId).map((rows) =>
        rows.map((row) => InvoiceCycle(
          id: row.id,
          cardId: row.cardId,
          userId: row.userId,
          month: row.month,
          year: row.year,
          closingDate: row.closingDate,
          dueDate: row.dueDate,
          totalAmount: row.totalAmount,
          isPaid: row.isPaid,
          paidAt: row.paidAt,
          notes: row.notes,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
        )).toList());
  }

  Future<InvoiceCycle?> getById(String id) async {
    final local = await _local.getById(id);
    if (local != null) {
      return InvoiceCycle(
        id: local.id,
        cardId: local.cardId,
        userId: local.userId,
        month: local.month,
        year: local.year,
        closingDate: local.closingDate,
        dueDate: local.dueDate,
        totalAmount: local.totalAmount,
        isPaid: local.isPaid,
        paidAt: local.paidAt,
        notes: local.notes,
        createdAt: local.createdAt,
        updatedAt: local.updatedAt,
      );
    }
    return null;
  }

  Future<InvoiceCycle> create(InvoiceCycle cycle) async {
    await _local.upsert(_toDrift(cycle));
    return cycle;
  }

  Future<InvoiceCycle> update(InvoiceCycle cycle) async {
    await _local.upsert(_toDrift(cycle));
    return cycle;
  }

  Future<List<InvoiceCycle>> getAll(String userId) async {
    final db = _local.db;
    final rows = await (db.select(db.invoiceCycles)..where((i) => i.userId.equals(userId))).get();
    return rows.map((r) => InvoiceCycle(
      id: r.id, cardId: r.cardId, userId: r.userId, month: r.month, year: r.year,
      closingDate: r.closingDate, dueDate: r.dueDate, totalAmount: r.totalAmount,
      isPaid: r.isPaid, paidAt: r.paidAt, notes: r.notes,
      createdAt: r.createdAt, updatedAt: r.updatedAt,
    )).toList();
  }

  Future<void> delete(String id) async {
    await _local.delete(id);
  }

  InvoiceCyclesCompanion _toDrift(InvoiceCycle c) {
    return InvoiceCyclesCompanion(
      id: Value(c.id),
      cardId: Value(c.cardId),
      userId: Value(c.userId),
      month: Value(c.month),
      year: Value(c.year),
      closingDate: Value(c.closingDate),
      dueDate: Value(c.dueDate),
      totalAmount: Value(c.totalAmount),
      isPaid: Value(c.isPaid),
      paidAt: Value<DateTime?>(c.paidAt),
      notes: Value<String?>(c.notes),
    );
  }
}
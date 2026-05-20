import 'dart:async';
import 'package:drift/drift.dart';
import '../../../../services/drift_database.dart' hide FinancialAlert;
import '../../domain/models/financial_alert.dart';

class AlertRepository {
  final AppDatabase _db;

  AlertRepository() : _db = AppDatabase();

  Stream<List<FinancialAlert>> watchAll(String userId) {
    return (_db.select(_db.financialAlerts)..where((a) => a.userId.equals(userId))..orderBy([(a) => OrderingTerm(expression: a.createdAt, mode: OrderingMode.desc)])).watch().map((rows) =>
        rows.map((r) => FinancialAlert(
          id: r.id, userId: r.userId, type: r.type, title: r.title,
          message: r.message, severity: r.severity, isRead: r.isRead,
          data: r.data != null ? Map<String, dynamic>.from(r.data as Map) : null,
          createdAt: r.createdAt,
        )).toList());
  }
}

import 'package:drift/drift.dart';
import '../../../../services/drift_database.dart';

class AlertLocalDs {
  final AppDatabase _db;

  AlertLocalDs(this._db);

  Stream<List<dynamic>> watchAll(String userId) {
    return (_db.select(_db.financialAlerts)..where((a) => a.userId.equals(userId))..orderBy([(a) => OrderingTerm(expression: a.createdAt, mode: OrderingMode.desc)])).watch();
  }

  Future<void> upsert(FinancialAlertsCompanion alert) async {
    await _db.into(_db.financialAlerts).insertOnConflictUpdate(alert);
  }
}

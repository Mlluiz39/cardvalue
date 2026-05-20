import 'package:drift/drift.dart';
import '../../../../services/drift_database.dart';

class ReconciliationReportLocalDs {
  final AppDatabase _db;

  ReconciliationReportLocalDs(this._db);

  Future<dynamic> getByInvoiceCycle(String invoiceCycleId) async {
    return await (_db.select(_db.reconciliationReports)
      ..where((r) => r.invoiceCycleId.equals(invoiceCycleId))
    ).getSingleOrNull();
  }

  Future<void> upsert(ReconciliationReportsCompanion report) async {
    await _db.into(_db.reconciliationReports).insertOnConflictUpdate(report);
  }
}

class ReconciliationItemLocalDs {
  final AppDatabase _db;

  ReconciliationItemLocalDs(this._db);

  Future<List<dynamic>> getByReport(String reportId) async {
    return await (_db.select(_db.reconciliationItems)
      ..where((i) => i.reportId.equals(reportId))
    ).get();
  }

  Future<void> upsertAll(List<ReconciliationItemsCompanion> items) async {
    await _db.batch((batch) {
      for (final item in items) {
        batch.insert(_db.reconciliationItems, item, mode: InsertMode.insertOrReplace);
      }
    });
  }
}

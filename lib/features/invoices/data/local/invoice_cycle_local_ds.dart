import 'package:drift/drift.dart';
import '../../../../services/drift_database.dart';

class InvoiceCycleLocalDs {
  final AppDatabase _db;

  InvoiceCycleLocalDs(this._db);

  AppDatabase get db => _db;

  Stream<List<dynamic>> watchByCard(String cardId) {
    return (_db.select(_db.invoiceCycles)..where((c) => c.cardId.equals(cardId))..orderBy([(c) => OrderingTerm(expression: c.year, mode: OrderingMode.desc), (c) => OrderingTerm(expression: c.month, mode: OrderingMode.desc)])).watch();
  }

  Future<dynamic> getById(String id) async {
    return await (_db.select(_db.invoiceCycles)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  Future<dynamic> getByCardAndMonth(String cardId, int month, int year) async {
    final result = await (_db.select(_db.invoiceCycles)
      ..where((c) => c.cardId.equals(cardId) & c.month.equals(month) & c.year.equals(year))
    ).getSingleOrNull();
    return result;
  }

  Future<void> upsert(InvoiceCyclesCompanion cycle) async {
    await _db.into(_db.invoiceCycles).insertOnConflictUpdate(cycle);
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.invoiceCycles)..where((c) => c.id.equals(id))).go();
  }
}

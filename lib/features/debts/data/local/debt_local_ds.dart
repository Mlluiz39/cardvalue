import '../../../../services/drift_database.dart';

class DebtLocalDs {
  final AppDatabase _db;

  DebtLocalDs(this._db);

  Stream<List<dynamic>> watchAll(String userId) {
    return (_db.select(_db.debts)..where((d) => d.userId.equals(userId))).watch();
  }

  Future<dynamic> getById(String id) async {
    return await (_db.select(_db.debts)..where((d) => d.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsert(DebtsCompanion debt) async {
    await _db.into(_db.debts).insertOnConflictUpdate(debt);
  }
}

import 'package:drift/drift.dart';
import '../../../../services/drift_database.dart';

class TransactionLocalDs {
  final AppDatabase _db;

  TransactionLocalDs(this._db);

  Stream<List<dynamic>> watchAll(String userId) {
    return (_db.select(_db.transactions)..where((t) => t.userId.equals(userId))..orderBy([(t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc)])).watch();
  }

  Future<dynamic> getById(String id) async {
    return await (_db.select(_db.transactions)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsert(TransactionsCompanion transaction) async {
    await _db.into(_db.transactions).insertOnConflictUpdate(transaction);
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }
}

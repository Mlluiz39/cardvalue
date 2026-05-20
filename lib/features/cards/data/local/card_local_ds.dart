import 'package:drift/drift.dart';
import '../../../../services/drift_database.dart';

class CardLocalDs {
  final AppDatabase _db;

  CardLocalDs(this._db);

  AppDatabase get db => _db;

  Stream<List<Card>> watchAll(String userId) {
    return (_db.select(_db.cards)..where((c) => c.userId.equals(userId))).watch();
  }

  Future<Card?> getById(String id) async {
    return await (_db.select(_db.cards)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsert(Insertable<Card> card) async {
    await _db.into(_db.cards).insertOnConflictUpdate(card);
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.cards)..where((c) => c.id.equals(id))).go();
  }
}

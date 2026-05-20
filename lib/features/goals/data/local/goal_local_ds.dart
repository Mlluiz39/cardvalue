import '../../../../services/drift_database.dart';

class GoalLocalDs {
  final AppDatabase _db;

  GoalLocalDs(this._db);

  Stream<List<dynamic>> watchAll(String userId) {
    return (_db.select(_db.goals)..where((g) => g.userId.equals(userId))).watch();
  }

  Future<void> upsert(GoalsCompanion goal) async {
    await _db.into(_db.goals).insertOnConflictUpdate(goal);
  }
}

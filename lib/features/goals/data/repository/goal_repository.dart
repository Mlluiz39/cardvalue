import 'dart:async';
import 'package:drift/drift.dart';
import '../../../../services/drift_database.dart' hide Goal;
import '../../domain/models/goal.dart';

class GoalRepository {
  final AppDatabase _db;

  GoalRepository() : _db = AppDatabase();

  Stream<List<Goal>> watchAll(String userId) {
    return (_db.select(_db.goals)..where((g) => g.userId.equals(userId))).watch().map((rows) =>
        rows.map((r) => Goal(
          id: r.id, userId: r.userId, title: r.title,
          targetAmount: r.targetAmount, currentAmount: r.currentAmount,
          deadline: r.deadline, categoryId: r.categoryId,
          monthlyContribution: r.monthlyContribution, status: r.status,
          createdAt: r.createdAt, updatedAt: r.updatedAt,
        )).toList());
  }

  Future<Goal> create(Goal goal) async {
    await _db.into(_db.goals).insertOnConflictUpdate(GoalsCompanion(
      id: Value(goal.id), userId: Value(goal.userId), title: Value(goal.title),
      targetAmount: Value(goal.targetAmount), currentAmount: Value(goal.currentAmount),
      deadline: Value<DateTime?>(goal.deadline), categoryId: Value<String?>(goal.categoryId),
      monthlyContribution: Value<double?>(goal.monthlyContribution), status: Value(goal.status),
    ));
    return goal;
  }

  Future<List<Goal>> getAll(String userId) async {
    final rows = await (_db.select(_db.goals)..where((g) => g.userId.equals(userId))).get();
    return rows.map((r) => Goal(
      id: r.id, userId: r.userId, title: r.title,
      targetAmount: r.targetAmount, currentAmount: r.currentAmount,
      deadline: r.deadline, categoryId: r.categoryId,
      monthlyContribution: r.monthlyContribution, status: r.status,
      createdAt: r.createdAt, updatedAt: r.updatedAt,
    )).toList();
  }

  Future<Goal?> getById(String id) async {
    final row = await (_db.select(_db.goals)..where((g) => g.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return Goal(
      id: row.id, userId: row.userId, title: row.title,
      targetAmount: row.targetAmount, currentAmount: row.currentAmount,
      deadline: row.deadline, categoryId: row.categoryId,
      monthlyContribution: row.monthlyContribution, status: row.status,
      createdAt: row.createdAt, updatedAt: row.updatedAt,
    );
  }

  Future<Goal> update(Goal goal) async {
    await _db.into(_db.goals).insertOnConflictUpdate(GoalsCompanion(
      id: Value(goal.id), userId: Value(goal.userId), title: Value(goal.title),
      targetAmount: Value(goal.targetAmount), currentAmount: Value(goal.currentAmount),
      deadline: Value<DateTime?>(goal.deadline), categoryId: Value<String?>(goal.categoryId),
      monthlyContribution: Value<double?>(goal.monthlyContribution), status: Value(goal.status),
    ));
    return goal;
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.goals)..where((g) => g.id.equals(id))).go();
  }
}
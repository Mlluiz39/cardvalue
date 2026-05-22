import 'dart:async';
import 'package:drift/drift.dart';
import '../../../../services/drift_database.dart' hide Category;
import '../../domain/models/category.dart';

class CategoryRepository {
  final AppDatabase _db;

  CategoryRepository() : _db = AppDatabase();

  Stream<List<Category>> watchAll(String userId) {
    return (_db.select(_db.categories)
      ..where((c) => c.userId.equals(userId))
      ..orderBy([(c) => OrderingTerm(expression: c.sortOrder)]))
      .watch()
      .map((rows) => rows.map((r) => Category(
        id: r.id, userId: r.userId, name: r.name,
        icon: r.icon, colorHex: r.color, type: r.type,
        isSystem: r.isSystem, sortOrder: r.sortOrder,
      )).toList());
  }

  Future<Category> create(Category category) async {
    await _db.into(_db.categories).insertOnConflictUpdate(CategoriesCompanion(
      id: Value(category.id), userId: Value(category.userId),
      name: Value(category.name), icon: Value<String?>(category.icon),
      color: Value<String?>(category.colorHex), type: Value(category.type),
      isSystem: Value(category.isSystem), sortOrder: Value(category.sortOrder),
    ));
    return category;
  }

  Future<void> update(Category category) async {
    await _db.into(_db.categories).insertOnConflictUpdate(CategoriesCompanion(
      id: Value(category.id), userId: Value(category.userId),
      name: Value(category.name), icon: Value<String?>(category.icon),
      color: Value<String?>(category.colorHex), type: Value(category.type),
      isSystem: Value(category.isSystem), sortOrder: Value(category.sortOrder),
    ));
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
  }
}

import 'dart:async';
import 'package:drift/drift.dart';
import '../../../../services/drift_database.dart' hide Tag;
import '../../domain/models/tag.dart';

class TagRepository {
  final AppDatabase _db;

  TagRepository() : _db = AppDatabase();

  Stream<List<Tag>> watchAll(String userId) {
    return (_db.select(_db.tags)
      ..where((t) => t.userId.equals(userId)))
      .watch()
      .map((rows) => rows.map((r) => Tag(
        id: r.id, userId: r.userId, name: r.name, color: r.color,
      )).toList());
  }

  Future<Tag> create(Tag tag) async {
    await _db.into(_db.tags).insertOnConflictUpdate(TagsCompanion(
      id: Value(tag.id), userId: Value(tag.userId),
      name: Value(tag.name), color: Value<String?>(tag.color),
    ));
    return tag;
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.tags)..where((t) => t.id.equals(id))).go();
  }
}

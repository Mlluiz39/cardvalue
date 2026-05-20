import 'dart:convert';
import 'package:drift/drift.dart';
import 'drift_database.dart';

class SyncService {
  static final SyncService _instance = SyncService._();
  factory SyncService() => _instance;
  SyncService._();

  bool _isSyncing = false;
  final AppDatabase _db = AppDatabase();

  Future<void> syncAll() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      await Future.delayed(const Duration(milliseconds: 100));
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> syncTable(String tableName) async {
    await syncAll();
  }

  Future<void> addToOutbox({
    required String userId,
    required String targetTable,
    required String recordId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
  }
}
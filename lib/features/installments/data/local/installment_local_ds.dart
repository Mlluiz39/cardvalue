import 'package:drift/drift.dart';
import '../../../../services/drift_database.dart';

class PurchaseLocalDs {
  final AppDatabase _db;

  PurchaseLocalDs(this._db);

  Stream<List<dynamic>> watchAll(String userId) {
    return (_db.select(_db.purchases)..where((p) => p.userId.equals(userId))).watch();
  }

  Future<dynamic> getById(String id) async {
    return await (_db.select(_db.purchases)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsert(PurchasesCompanion purchase) async {
    await _db.into(_db.purchases).insertOnConflictUpdate(purchase);
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.purchases)..where((p) => p.id.equals(id))).go();
  }
}

class InstallmentLocalDs {
  final AppDatabase _db;

  InstallmentLocalDs(this._db);

  Stream<List<dynamic>> watchByPurchase(String purchaseId) {
    return (_db.select(_db.installments)..where((i) => i.purchaseId.equals(purchaseId))).watch();
  }

  Stream<List<dynamic>> watchByInvoiceCycle(String invoiceCycleId) {
    return (_db.select(_db.installments)..where((i) => i.invoiceCycleId.equals(invoiceCycleId))).watch();
  }

  Future<dynamic> getById(String id) async {
    return await (_db.select(_db.installments)..where((i) => i.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsert(InstallmentsCompanion installment) async {
    await _db.into(_db.installments).insertOnConflictUpdate(installment);
  }

  Future<void> upsertAll(List<InstallmentsCompanion> installments) async {
    await _db.batch((batch) {
      for (final i in installments) {
        batch.insert(_db.installments, i, mode: InsertMode.insertOrReplace);
      }
    });
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.installments)..where((i) => i.id.equals(id))).go();
  }
}

import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../../../services/drift_database.dart' hide Purchase, Installment;
import '../local/installment_local_ds.dart';
import '../../domain/models/purchase.dart';
import '../../domain/models/installment.dart';

class PurchaseRepository {
  final PurchaseLocalDs _local;
  final InstallmentLocalDs _installmentLocal;
  final _uuid = const Uuid();

  PurchaseRepository()
      : _local = PurchaseLocalDs(AppDatabase()),
        _installmentLocal = InstallmentLocalDs(AppDatabase());

  Stream<List<Purchase>> watchAll(String userId) {
    return _local.watchAll(userId).map((rows) =>
        rows.map((row) => Purchase(
          id: row.id,
          cardId: row.cardId,
          userId: row.userId,
          merchantName: row.merchantName,
          totalAmount: row.totalAmount,
          categoryId: row.categoryId,
          purchaseDate: row.purchaseDate,
          installmentCount: row.installmentCount,
          notes: row.notes,
          isReconciled: row.isReconciled,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
        )).toList());
  }

  Future<Purchase> createWithInstallments(Purchase purchase, int closingDay) async {
    final now = DateTime.now();
    final installments = _generateInstallments(purchase, closingDay, now);

    await _local.upsert(_toDrift(purchase));
    await _installmentLocal.upsertAll(installments.map((i) => _toDriftInstallment(i)).toList());

    return purchase;
  }

  List<Installment> _generateInstallments(Purchase purchase, int closingDay, DateTime now) {
    final count = purchase.installmentCount;
    final unit = (purchase.totalAmount / count * 100).floorToDouble() / 100;
    final lastAmount = purchase.totalAmount - unit * (count - 1);

    final firstDueDate = _computeFirstDueDate(purchase.purchaseDate, closingDay);

    return List.generate(count, (i) {
      final amount = (i == count - 1) ? lastAmount : unit;
      final dueDate = DateTime(firstDueDate.year, firstDueDate.month + i, firstDueDate.day);
      return Installment(
        id: _uuid.v4(),
        purchaseId: purchase.id,
        invoiceCycleId: null,
        userId: purchase.userId,
        sequenceNumber: i + 1,
        totalInstallments: count,
        amount: amount,
        dueDate: dueDate,
        status: 'pending',
      );
    });
  }

  DateTime _computeFirstDueDate(DateTime purchaseDate, int closingDay) {
    final purchaseDay = purchaseDate.day;

    DateTime firstCycleDueDate;
    if (purchaseDay <= closingDay) {
      firstCycleDueDate = DateTime(purchaseDate.year, purchaseDate.month + 1, closingDay);
    } else {
      firstCycleDueDate = DateTime(purchaseDate.year, purchaseDate.month + 2, closingDay);
    }

    final safeDay = closingDay > 28 ? 28 : closingDay;
    return DateTime(firstCycleDueDate.year, firstCycleDueDate.month, safeDay);
  }

  Future<Purchase?> getById(String id) async {
    final local = await _local.getById(id);
    if (local != null) {
      return Purchase(
        id: local.id,
        cardId: local.cardId,
        userId: local.userId,
        merchantName: local.merchantName,
        totalAmount: local.totalAmount,
        categoryId: local.categoryId,
        purchaseDate: local.purchaseDate,
        installmentCount: local.installmentCount,
        notes: local.notes,
        isReconciled: local.isReconciled,
        createdAt: local.createdAt,
        updatedAt: local.updatedAt,
      );
    }
    return null;
  }

  Future<void> delete(String id) async {
    await _local.delete(id);
  }

  PurchasesCompanion _toDrift(Purchase p) {
    return PurchasesCompanion(
      id: Value(p.id),
      cardId: Value(p.cardId),
      userId: Value(p.userId),
      merchantName: Value(p.merchantName),
      totalAmount: Value(p.totalAmount),
      categoryId: Value(p.categoryId),
      purchaseDate: Value(p.purchaseDate),
      installmentCount: Value(p.installmentCount),
      notes: Value<String?>(p.notes),
      isReconciled: Value(p.isReconciled),
    );
  }

  InstallmentsCompanion _toDriftInstallment(Installment i) {
    return InstallmentsCompanion(
      id: Value(i.id),
      purchaseId: Value(i.purchaseId),
      invoiceCycleId: Value<String?>(i.invoiceCycleId),
      userId: Value(i.userId),
      sequenceNumber: Value(i.sequenceNumber),
      totalInstallments: Value(i.totalInstallments),
      amount: Value(i.amount),
      dueDate: Value(i.dueDate),
      status: Value(i.status),
      paidAt: Value<DateTime?>(i.paidAt),
    );
  }
}
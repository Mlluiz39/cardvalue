import 'dart:async';
import '../../../../services/drift_database.dart' hide Purchase, Installment;
import '../local/installment_local_ds.dart';
import '../../domain/models/installment.dart';

class InstallmentRepository {
  final InstallmentLocalDs _local;

  InstallmentRepository()
      : _local = InstallmentLocalDs(AppDatabase());

  Stream<List<Installment>> watchByPurchase(String purchaseId) {
    return _local.watchByPurchase(purchaseId).map((rows) =>
        rows.map((row) {
          final r = row;
          return Installment(
            id: r.id,
            purchaseId: r.purchaseId,
            invoiceCycleId: r.invoiceCycleId,
            userId: r.userId,
            sequenceNumber: r.sequenceNumber,
            totalInstallments: r.totalInstallments,
            amount: r.amount,
            dueDate: r.dueDate,
            status: r.status,
            paidAt: r.paidAt,
            createdAt: r.createdAt,
          );
        }).toList());
  }

  Stream<List<Installment>> watchByInvoiceCycle(String invoiceCycleId) {
    return _local.watchByInvoiceCycle(invoiceCycleId).map((rows) =>
        rows.map((row) {
          final r = row;
          return Installment(
            id: r.id,
            purchaseId: r.purchaseId,
            invoiceCycleId: r.invoiceCycleId,
            userId: r.userId,
            sequenceNumber: r.sequenceNumber,
            totalInstallments: r.totalInstallments,
            amount: r.amount,
            dueDate: r.dueDate,
            status: r.status,
            paidAt: r.paidAt,
            createdAt: r.createdAt,
          );
        }).toList());
  }

  Future<void> markAsPaid(String installmentId, DateTime paidAt) async {
    final existing = await _local.getById(installmentId);
    if (existing != null) {
      await _local.upsert(existing.copyWith(status: 'paid', paidAt: paidAt));
    }
  }

  Future<void> markAsPending(String installmentId) async {
    final existing = await _local.getById(installmentId);
    if (existing != null) {
      await _local.upsert(existing.copyWith(status: 'pending', paidAt: null));
    }
  }

  Stream<List<Installment>> watchByCard(String cardId) {
    return _local.watchByCard(cardId).map((rows) =>
        rows.map((row) {
          final r = row;
          return Installment(
            id: r.id,
            purchaseId: r.purchaseId,
            invoiceCycleId: r.invoiceCycleId,
            userId: r.userId,
            sequenceNumber: r.sequenceNumber,
            totalInstallments: r.totalInstallments,
            amount: r.amount,
            dueDate: r.dueDate,
            status: r.status,
            paidAt: r.paidAt,
            createdAt: r.createdAt,
          );
        }).toList());
  }
}

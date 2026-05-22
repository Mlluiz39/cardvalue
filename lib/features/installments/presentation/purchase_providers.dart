import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/repository/purchase_repository.dart';
import '../data/repository/installment_repository.dart';
import '../domain/models/purchase.dart';
import '../domain/models/installment.dart';

final purchaseRepositoryProvider = Provider<PurchaseRepository>((ref) => PurchaseRepository());

final purchaseListProvider = StreamProvider<List<Purchase>>((ref) {
  final userId = ref.watch(userIdProvider);
  return ref.watch(purchaseRepositoryProvider).watchAll(userId);
});

final purchaseDetailProvider = FutureProvider.family<Purchase?, String>((ref, id) {
  return ref.watch(purchaseRepositoryProvider).getById(id);
});

final installmentRepositoryProvider = Provider<InstallmentRepository>((ref) => InstallmentRepository());

final installmentListProvider = StreamProvider.family<List<Installment>, String>((ref, purchaseId) {
  return ref.watch(installmentRepositoryProvider).watchByPurchase(purchaseId);
});

final cardInstallmentsProvider = StreamProvider.family<List<Installment>, String>((ref, cardId) {
  return ref.watch(installmentRepositoryProvider).watchByCard(cardId);
});

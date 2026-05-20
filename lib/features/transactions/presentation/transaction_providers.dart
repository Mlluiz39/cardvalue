import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/repository/transaction_repository.dart';
import '../domain/models/transaction.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) => TransactionRepository());

final transactionListProvider = StreamProvider<List<Transaction>>((ref) {
  final userId = ref.watch(userIdProvider);
  return ref.watch(transactionRepositoryProvider).watchAll(userId);
});

final transactionDetailProvider = FutureProvider.family<Transaction?, String>((ref, id) {
  return ref.watch(transactionRepositoryProvider).getById(id);
});

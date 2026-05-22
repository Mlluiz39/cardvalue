import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/repository/debt_repository.dart';
import '../domain/models/debt.dart';

final debtRepositoryProvider = Provider<DebtRepository>((ref) => DebtRepository());

final debtListProvider = StreamProvider<List<Debt>>((ref) {
  final userId = ref.watch(userIdProvider);
  return ref.watch(debtRepositoryProvider).watchAll(userId);
});

final debtDetailProvider = FutureProvider.family<Debt?, String>((ref, debtId) {
  return ref.watch(debtRepositoryProvider).getById(debtId);
});

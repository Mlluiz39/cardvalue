import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/repository/goal_repository.dart';
import '../domain/models/goal.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) => GoalRepository());

final goalListProvider = StreamProvider<List<Goal>>((ref) {
  final userId = ref.watch(userIdProvider);
  return ref.watch(goalRepositoryProvider).watchAll(userId);
});

final goalDetailProvider = FutureProvider.family<Goal?, String>((ref, goalId) {
  return ref.watch(goalRepositoryProvider).getById(goalId);
});

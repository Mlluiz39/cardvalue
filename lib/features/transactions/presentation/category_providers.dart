import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/repository/category_repository.dart';
import '../domain/models/category.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) => CategoryRepository());

final categoryListProvider = StreamProvider<List<Category>>((ref) {
  final userId = ref.watch(userIdProvider);
  return ref.watch(categoryRepositoryProvider).watchAll(userId);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/repository/tag_repository.dart';
import '../domain/models/tag.dart';

final tagRepositoryProvider = Provider<TagRepository>((ref) => TagRepository());

final tagListProvider = StreamProvider<List<Tag>>((ref) {
  final userId = ref.watch(userIdProvider);
  return ref.watch(tagRepositoryProvider).watchAll(userId);
});

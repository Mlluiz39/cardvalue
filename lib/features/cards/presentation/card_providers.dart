import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../cards/data/repository/card_repository.dart';
import '../../cards/domain/models/card.dart' as domain;

final cardRepositoryProvider = Provider<CardRepository>((ref) => CardRepository());

final cardListProvider = StreamProvider<List<domain.CardModel>>((ref) {
  final userId = ref.watch(userIdProvider);
  return ref.watch(cardRepositoryProvider).watchAll(userId);
});

final cardDetailProvider = FutureProvider.family<domain.CardModel?, String>((ref, id) {
  return ref.watch(cardRepositoryProvider).getById(id);
});

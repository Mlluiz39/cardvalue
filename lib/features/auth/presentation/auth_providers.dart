import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class LocalUser {
  final String id;
  final String name;

  LocalUser({required this.id, required this.name});
}

class AuthRepository {
  final _uuid = const Uuid();
  
  String get currentUserId {
    return _uuid.v4();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

final localUserProvider = StateProvider<LocalUser>((ref) {
  return LocalUser(
    id: const Uuid().v4(),
    name: 'Usuário Local',
  );
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return true;
});

final userIdProvider = Provider<String>((ref) {
  return ref.watch(localUserProvider).id;
});
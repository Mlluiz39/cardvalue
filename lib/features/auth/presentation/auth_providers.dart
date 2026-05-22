import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class LocalUser {
  final String id;
  final String name;

  LocalUser({required this.id, required this.name});
}

class AuthNotifier extends StateNotifier<AsyncValue<LocalUser?>> {
  final _storage = const FlutterSecureStorage();

  AuthNotifier() : super(const AsyncValue.loading()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final id = await _storage.read(key: 'user_id');
      final name = await _storage.read(key: 'user_name');
      if (id != null && name != null) {
        state = AsyncValue.data(LocalUser(id: id, name: name));
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> login(String name) async {
    state = const AsyncValue.loading();
    try {
      final id = const Uuid().v4();
      await _storage.write(key: 'user_id', value: id);
      await _storage.write(key: 'user_name', value: name);
      state = AsyncValue.data(LocalUser(id: id, name: name));
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _storage.delete(key: 'user_id');
      await _storage.delete(key: 'user_name');
      state = const AsyncValue.data(null);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<LocalUser?>>((ref) {
  return AuthNotifier();
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final userState = ref.watch(authNotifierProvider);
  return userState.maybeWhen(
    data: (user) => user != null,
    orElse: () => false,
  );
});

final userIdProvider = Provider<String>((ref) {
  final userState = ref.watch(authNotifierProvider);
  return userState.maybeWhen(
    data: (user) => user?.id ?? '',
    orElse: () => '',
  );
});

final localUserProvider = Provider<LocalUser?>((ref) {
  final userState = ref.watch(authNotifierProvider);
  return userState.maybeWhen(
    data: (user) => user,
    orElse: () => null,
  );
});
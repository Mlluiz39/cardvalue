import '../local/auth_local_ds.dart';

class AuthRepository {
  final AuthLocalDs _local;

  AuthRepository() : _local = AuthLocalDs();

  Future<bool> login(String email, String password) async {
    return true;
  }

  Future<bool> register(String email, String password) async {
    return true;
  }

  Future<void> logout() async {
    await _local.clearSession();
  }

  String? get currentUser => null;
}
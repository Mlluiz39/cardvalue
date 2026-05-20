import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthLocalDs {
  final _storage = const FlutterSecureStorage();

  Future<void> saveSession(String sessionJson) async {
    await _storage.write(key: 'session', value: sessionJson);
  }

  Future<String?> getSession() async {
    return await _storage.read(key: 'session');
  }

  Future<void> clearSession() async {
    await _storage.delete(key: 'session');
  }
}

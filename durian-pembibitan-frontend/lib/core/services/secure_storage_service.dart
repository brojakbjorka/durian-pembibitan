import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'user_role';
  static const String _emailKey = 'user_email';
  static const String _nameKey = 'user_name';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveRole(String role) async {
    await _storage.write(key: _roleKey, value: role);
  }

  Future<String?> getRole() async {
    return await _storage.read(key: _roleKey);
  }

  Future<void> saveUserData(String name, String email) async {
    await _storage.write(key: _nameKey, value: name);
    await _storage.write(key: _emailKey, value: email);
  }

  Future<Map<String, String?>> getUserData() async {
    final name = await _storage.read(key: _nameKey);
    final email = await _storage.read(key: _emailKey);
    return {'name': name, 'email': email};
  }

  Future<void> clearAll() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _nameKey);
    await _storage.delete(key: _emailKey);
  }
}

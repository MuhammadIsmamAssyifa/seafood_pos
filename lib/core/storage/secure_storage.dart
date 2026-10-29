import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';
import 'storage_keys.dart';

class SecureStorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  final GetStorage _localStorage = GetStorage();

  // Token Management
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: StorageKeys.accessToken, value: token);
    _localStorage.write(StorageKeys.accessToken, token);
  }

  Future<String?> getToken() async {
    try {
      final token = await _secureStorage.read(key: StorageKeys.accessToken);
      if (token != null && token.isNotEmpty) {
        return token;
      }
    } catch (_) {
      // Fallback if secure storage encounters issue on some devices
    }
    return _localStorage.read<String>(StorageKeys.accessToken);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> deleteToken() async {
    try {
      await _secureStorage.delete(key: StorageKeys.accessToken);
    } catch (_) {}
    _localStorage.remove(StorageKeys.accessToken);
  }

  // User Session Management
  Future<void> saveUserSession(Map<String, dynamic> userJson) async {
    final encoded = jsonEncode(userJson);
    await _secureStorage.write(key: StorageKeys.userSession, value: encoded);
    _localStorage.write(StorageKeys.userSession, encoded);
  }

  Future<Map<String, dynamic>?> getUserSession() async {
    String? raw;
    try {
      raw = await _secureStorage.read(key: StorageKeys.userSession);
    } catch (_) {}

    raw ??= _localStorage.read<String>(StorageKeys.userSession);
    if (raw != null && raw.isNotEmpty) {
      try {
        return jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // General Key-Value Storage
  Future<void> write(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (_) {
      return _localStorage.read<String>(key);
    }
  }

  Future<void> delete(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (_) {}
    _localStorage.remove(key);
  }

  Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
    } catch (_) {}
    await _localStorage.erase();
  }
}

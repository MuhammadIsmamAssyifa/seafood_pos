import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';
import 'storage_keys.dart';

class SecureStorageService {
  final FlutterSecureStorage? _secureStorage;
  final GetStorage? _localStorage;
  final Map<String, dynamic> _memoryCache;

  SecureStorageService({
    FlutterSecureStorage? secureStorage,
    GetStorage? localStorage,
    bool isTest = false,
  })  : _secureStorage = isTest ? null : (secureStorage ?? const FlutterSecureStorage(aOptions: AndroidOptions())),
        _localStorage = isTest ? null : (localStorage ?? GetStorage()),
        _memoryCache = {};

  // Access Token Management
  Future<void> saveToken(String token) async {
    _memoryCache[StorageKeys.accessToken] = token;
    try {
      await _secureStorage?.write(key: StorageKeys.accessToken, value: token);
      _localStorage?.write(StorageKeys.accessToken, token);
    } catch (_) {}
  }

  Future<String?> getToken() async {
    if (_memoryCache.containsKey(StorageKeys.accessToken)) {
      return _memoryCache[StorageKeys.accessToken]?.toString();
    }

    try {
      final token = await _secureStorage?.read(key: StorageKeys.accessToken);
      if (token != null && token.isNotEmpty) {
        _memoryCache[StorageKeys.accessToken] = token;
        return token;
      }
    } catch (_) {}

    try {
      final local = _localStorage?.read<String>(StorageKeys.accessToken);
      if (local != null && local.isNotEmpty) {
        _memoryCache[StorageKeys.accessToken] = local;
        return local;
      }
    } catch (_) {}

    return null;
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> deleteToken() async {
    _memoryCache.remove(StorageKeys.accessToken);
    try {
      await _secureStorage?.delete(key: StorageKeys.accessToken);
      _localStorage?.remove(StorageKeys.accessToken);
    } catch (_) {}
  }

  // User ID Management
  Future<void> saveUserId(int id) async {
    _memoryCache[StorageKeys.userId] = id;
    try {
      await _secureStorage?.write(key: StorageKeys.userId, value: id.toString());
      _localStorage?.write(StorageKeys.userId, id);
    } catch (_) {}
  }

  Future<int?> getUserId() async {
    if (_memoryCache.containsKey(StorageKeys.userId)) {
      final val = _memoryCache[StorageKeys.userId];
      if (val is int) return val;
      return int.tryParse(val.toString());
    }

    try {
      final raw = await _secureStorage?.read(key: StorageKeys.userId);
      if (raw != null) {
        final parsed = int.tryParse(raw);
        if (parsed != null) {
          _memoryCache[StorageKeys.userId] = parsed;
          return parsed;
        }
      }
    } catch (_) {}

    try {
      final local = _localStorage?.read<int>(StorageKeys.userId);
      if (local != null) {
        _memoryCache[StorageKeys.userId] = local;
        return local;
      }
    } catch (_) {}

    return null;
  }

  // User Data Management
  Future<void> saveUserData(Map<String, dynamic> userJson) async {
    _memoryCache[StorageKeys.userData] = userJson;
    final encoded = jsonEncode(userJson);
    try {
      await _secureStorage?.write(key: StorageKeys.userData, value: encoded);
      _localStorage?.write(StorageKeys.userData, encoded);
    } catch (_) {}

    if (userJson['id'] != null) {
      await saveUserId(int.tryParse(userJson['id'].toString()) ?? 0);
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    if (_memoryCache.containsKey(StorageKeys.userData)) {
      final cached = _memoryCache[StorageKeys.userData];
      if (cached is Map<String, dynamic>) return cached;
    }

    String? raw;
    try {
      raw = await _secureStorage?.read(key: StorageKeys.userData);
    } catch (_) {}

    try {
      raw ??= _localStorage?.read<String>(StorageKeys.userData);
    } catch (_) {}

    if (raw != null && raw.isNotEmpty) {
      try {
        final parsed = jsonDecode(raw) as Map<String, dynamic>;
        _memoryCache[StorageKeys.userData] = parsed;
        return parsed;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // Generic key-value storage
  Future<void> write(String key, String value) async {
    _memoryCache[key] = value;
    try {
      await _secureStorage?.write(key: key, value: value);
      _localStorage?.write(key, value);
    } catch (_) {}
  }

  Future<String?> read(String key) async {
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key]?.toString();
    }

    try {
      final secure = await _secureStorage?.read(key: key);
      if (secure != null) {
        _memoryCache[key] = secure;
        return secure;
      }
    } catch (_) {}

    try {
      final local = _localStorage?.read<String>(key);
      if (local != null) {
        _memoryCache[key] = local;
        return local;
      }
    } catch (_) {}

    return null;
  }

  Future<void> delete(String key) async {
    _memoryCache.remove(key);
    try {
      await _secureStorage?.delete(key: key);
      _localStorage?.remove(key);
    } catch (_) {}
  }

  Future<void> clearAll() async {
    _memoryCache.clear();
    try {
      await _secureStorage?.deleteAll();
      await _localStorage?.erase();
    } catch (_) {}
  }
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String keyLogin = "isLoggedIn";
  static const String keyLastLogin = "lastLoginTime";
  static const String keyUserId = "userId";
  static const String keyRowId = "rowId";
  static const String keyTheme = "appTheme";
  static const String keyFullName = "fullName";
  static const String keyOnboarding = "hasSeenOnboarding";

  static Future<void> storeLogin(String value) async {
    await _storage.write(key: keyLogin, value: value);
  }

  static Future<String?> getStoredLogin() async {
    return await _storage.read(key: keyLogin);
  }

  static Future<void> deleteStoredLogin() async {
    await _storage.delete(key: keyLogin);
  }

  static Future<void> storeTime(String value) async {
    await _storage.write(key: keyLastLogin, value: value);
  }

  static Future<String?> getStoredTime() async {
    return await _storage.read(key: keyLastLogin);
  }

  static Future<void> deleteStoredTime() async {
    await _storage.delete(key: keyLastLogin);
  }

  static Future<void> storeUserId(String value) async {
    await _storage.write(key: keyUserId, value: value);
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: keyUserId);
  }

  static Future<void> deleteUserId() async {
    await _storage.delete(key: keyUserId);
  }

  static Future<void> storeRowId(String value) async {
    await _storage.write(key: keyRowId, value: value);
  }

  static Future<String?> getRowId() async {
    return await _storage.read(key: keyRowId);
  }

  static Future<void> deleteRowId() async {
    await _storage.delete(key: keyRowId);
  }

  static Future<void> storeTheme(String value) async {
    await _storage.write(key: keyTheme, value: value);
  }

  static Future<String?> getStoredTheme() async {
    return await _storage.read(key: keyTheme);
  }

  static Future<void> deleteStoredTheme() async {
    await _storage.delete(key: keyTheme);
  }

  static Future<void> storeFullName(String value) async {
    await _storage.write(key: keyFullName, value: value);
  }

  static Future<String?> getFullName() async {
    return await _storage.read(key: keyFullName);
  }

  static Future<void> deleteFullName() async {
    await _storage.delete(key: keyFullName);
  }

  static Future<bool> hasSeenOnboarding() async {
    final value = await _storage.read(key: keyOnboarding);
    return value == "true";
  }

  static Future<void> setHasSeenOnboarding() async {
    await _storage.write(key: keyOnboarding, value: "true");
  }
}

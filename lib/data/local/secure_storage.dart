import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class SecureStorageKeys {
  SecureStorageKeys._();

  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String permissions = 'user_permissions';
  static const String userType = 'user_type'; // Maps to user.role
  static const String userId = 'user_id';     // Maps to user.id
  static const String userName = 'user_name'; // Maps to user.name
  static const String userData = 'user_data'; // Full serialized user map

  // New specific keys from your payload
  static const String companyId = 'company_id';
  static const String companyName = 'company_name';
  static const String userEmail = 'user_email';
  static const String userMobile = 'user_mobile';
}


/// A thread-safe Singleton wrapper around FlutterSecureStorage.
class SecureStorageService {
  static SecureStorageService? _instance;
  final FlutterSecureStorage _storage;

  // Private constructor
  SecureStorageService._internal(this._storage);

  /// Retrieves the active static instance of the service.
  static Future<SecureStorageService> get instance async {
    _instance ??= SecureStorageService._internal(
      const FlutterSecureStorage(
        aOptions: AndroidOptions(
          // Automatically wipes keystore configuration changes on hardware updates
          // instead of throwing unexpected runtime app crashes.
          resetOnError: true,
        ),
      ),
    );
    return _instance!;
  }

  // ==========================================
  // ---------- CORE AUTH TOKENS --------------
  // ==========================================

  /// Writes the active session JWT access token.
  Future<void> setAccessToken(String accessToken) async {
    await _storage.write(key: SecureStorageKeys.accessToken, value: accessToken);
  }

  /// Reads the active session JWT access token.
  Future<String?> get accessToken => _storage.read(key: SecureStorageKeys.accessToken);

  /// Writes the active session refresh token.
  Future<void> setRefreshToken(String refreshToken) async {
    await _storage.write(key: SecureStorageKeys.refreshToken, value: refreshToken);
  }

  /// Reads the active session refresh token.
  Future<String?> get refreshToken => _storage.read(key: SecureStorageKeys.refreshToken);

  // ==========================================
  // ---------- COMPONENT DATA ----------------
  // ==========================================

  /// Serializes and writes a list of string permissions.
  Future<void> setPermissions(List<String> permissions) async {
    await _storage.write(
      key: SecureStorageKeys.permissions,
      value: jsonEncode(permissions),
    );
  }

  /// Reads and deserializes stored user permissions. Returns empty array if none found.
  Future<List<String>> get permissions async {
    final jsonString = await _storage.read(key: SecureStorageKeys.permissions);
    if (jsonString == null) return [];
    try {
      return List<String>.from(jsonDecode(jsonString));
    } catch (_) {
      return [];
    }
  }

  /// Unified batch writer for the incoming login response properties.
  /// Unified batch writer for the exact incoming login JSON response properties.
  Future<void> saveLoginSession({
    required String accessToken,
    required String refreshToken,
    required String userType,
    required String userId,
    required String userName,
    required String email,
    required String mobile,
    required String companyId,
    required String companyName,
    required List<String> permissions,
    required Map<String, dynamic> userData,
  }) async {
    // Core Auth Tokens
    await _storage.write(key: SecureStorageKeys.accessToken, value: accessToken);
    await _storage.write(key: SecureStorageKeys.refreshToken, value: refreshToken);

    // Profile Details
    await _storage.write(key: SecureStorageKeys.userType, value: userType);
    await _storage.write(key: SecureStorageKeys.userId, value: userId);
    await _storage.write(key: SecureStorageKeys.userName, value: userName);
    await _storage.write(key: SecureStorageKeys.userEmail, value: email);
    await _storage.write(key: SecureStorageKeys.userMobile, value: mobile);
    await _storage.write(key: SecureStorageKeys.companyId, value: companyId);
    await _storage.write(key: SecureStorageKeys.companyName, value: companyName);

    // Complex Structural Fields (Lists and Maps)
    await _storage.write(key: SecureStorageKeys.permissions, value: jsonEncode(permissions));
    await _storage.write(key: SecureStorageKeys.userData, value: jsonEncode(userData));
  }

  // ==========================================
  // ---------- INDIVIDUAL PROFILE GETTERS ----
  // ==========================================

  Future<String?> get userType => _storage.read(key: SecureStorageKeys.userType);
  Future<String?> get userId => _storage.read(key: SecureStorageKeys.userId);
  Future<String?> get userName => _storage.read(key: SecureStorageKeys.userName);
  Future<String?> get companyId => _storage.read(key: SecureStorageKeys.companyId);

  /// Reads and parses full structural user profile metadata.
  Future<Map<String, dynamic>?> get userData async {
    final jsonString = await _storage.read(key: SecureStorageKeys.userData);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ==========================================
  // ---------- CLEANUP MECHANISMS ------------
  // ==========================================

  /// Completely wipes out stored elements during explicit logouts.
  Future<void> clearSession() async {
    await _storage.deleteAll();
  }
}

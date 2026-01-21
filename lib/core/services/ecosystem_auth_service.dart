import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class EcosystemAuthService {
  static const String _vaultKey = 'whisperr_ecosystem_vault';
  static const String _groupId = 'group.com.whisperr.ecosystem';

  final _storage = const FlutterSecureStorage(
    iOptions: IOSOptions(
      groupId: _groupId,
      accessibility: KeychainAccessibility.first_unlock,
    ),
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Saves the user ID and session secret to the shared vault.
  Future<void> saveSession(String userId, String secret) async {
    final data = jsonEncode({'userId': userId, 'secret': secret});
    await _storage.write(key: _vaultKey, value: data);
  }

  /// Retrieves the session data if it exists.
  Future<Map<String, String>?> getSession() async {
    final data = await _storage.read(key: _vaultKey);
    if (data != null) {
      try {
        return Map<String, String>.from(jsonDecode(data));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Clears the vault.
  Future<void> clearSession() async {
    await _storage.delete(key: _vaultKey);
  }
}

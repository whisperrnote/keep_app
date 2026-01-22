import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class EcosystemAuthService {
  static final EcosystemAuthService _instance = EcosystemAuthService._internal();
  factory EcosystemAuthService() => _instance;
  EcosystemAuthService._internal();

  static const String _vaultKey = 'whisperr_ecosystem_vault';
  static const String _groupId = 'group.com.whisperr.ecosystem';
  
  // Shared account name for Linux/Windows to ensure different apps look at the same entry
  static const String _accountName = 'WhisperrEcosystem';

  final _storage = const FlutterSecureStorage(
    iOptions: IOSOptions(
      groupId: _groupId,
      accessibility: KeychainAccessibility.first_unlock,
    ),
    mOptions: MacOsOptions(
      groupId: _groupId,
      accessibility: KeychainAccessibility.first_unlock,
    ),
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      // sharedUserId in Manifest handles the OS-level permission
    ),
    lOptions: LinuxOptions(
      accountName: _accountName,
    ),
    wOptions: WindowsOptions(
      // Windows DPAPI is per-user, but we use a shared workspace to ensure
      // different binaries can potentially reach the same storage if configured.
    ),
  );

  /// Saves the user ID and session secret to the shared vault.
  Future<void> saveSession(String userId, String secret) async {
    final data = jsonEncode({
      'userId': userId, 
      'secret': secret,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    await _storage.write(key: _vaultKey, value: data);
  }

  /// Retrieves the session data if it exists.
  Future<Map<String, String>?> getSession() async {
    try {
      final data = await _storage.read(key: _vaultKey);
      if (data != null) {
        final Map<String, dynamic> decoded = jsonDecode(data);
        return {
          'userId': decoded['userId'] as String,
          'secret': decoded['secret'] as String,
        };
      }
    } catch (e) {
      // In case of corruption or platform key change
      await clearSession();
    }
    return null;
  }

  /// Clears the vault.
  Future<void> clearSession() async {
    await _storage.delete(key: _vaultKey);
  }
}

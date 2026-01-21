import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cryptography/cryptography.dart';
import 'encryption_service.dart';

class VaultProvider with ChangeNotifier {
  static final VaultProvider _instance = VaultProvider._internal();
  factory VaultProvider() => _instance;
  VaultProvider._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final EncryptionService _encryptionService = EncryptionService();

  SecretKey? _sessionKey;
  bool _isLocked = true;

  bool get isLocked => _isLocked;
  bool get hasSessionKey => _sessionKey != null;

  /// Unlocks the vault using the master password.
  /// This derives the session key and stores it in memory.
  Future<bool> unlockWithPassword(String password, String salt) async {
    try {
      _sessionKey = await _encryptionService.deriveKey(password, salt);
      _isLocked = false;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Unlocks the vault using biometrics.
  /// Requires that a master password hash was previously saved securely.
  Future<bool> unlockWithBiometrics() async {
    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      if (!canAuthenticate) return false;

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Access your secure vault',
      );

      if (authenticated) {
        final savedKey = await _secureStorage.read(key: 'vault_session_key');
        if (savedKey != null) {
          _sessionKey = SecretKey(base64Decode(savedKey));
          _isLocked = false;
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Locks the vault and clears the session key.
  void lock() {
    _sessionKey = null;
    _isLocked = true;
    notifyListeners();
  }

  Future<String> encryptData(String data) async {
    if (_sessionKey == null) throw Exception('Vault is locked');
    return _encryptionService.encrypt(data, _sessionKey!);
  }

  Future<String> decryptData(String encryptedData) async {
    if (_sessionKey == null) throw Exception('Vault is locked');
    return _encryptionService.decrypt(encryptedData, _sessionKey!);
  }

  Future<void> saveMasterKeySecurely(SecretKey key) async {
    final bytes = await key.extractBytes();
    await _secureStorage.write(
      key: 'vault_session_key',
      value: base64Encode(bytes),
    );
  }
}

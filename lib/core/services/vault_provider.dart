import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cryptography/cryptography.dart';
import 'encryption_service.dart';
import '../constants/app_constants.dart';

class VaultProvider with ChangeNotifier {
  static final VaultProvider _instance = VaultProvider._internal();
  factory VaultProvider() => _instance;
  VaultProvider._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final EncryptionService _encryptionService = EncryptionService();

  SecretKey? _sessionKey;
  bool _isLocked = true;
  bool _isInitialized = false;

  bool get isLocked => _isLocked;
  bool get isInitialized => _isInitialized;
  bool get hasSessionKey => _sessionKey != null;

  Future<void> checkInitialization() async {
    if (AppConstants.useMockMode) {
      _isInitialized = true;
      _isLocked = false;
      // In mock mode, we don't need a real key, but if we want to avoid null checks failing:
      // We can set a dummy key or modify encrypt/decrypt to bypass if mock mode.
      // For now, let's leave key null and modify encrypt/decrypt/lock logic or just ensure we don't use it.
      // Actually, VaultService uses encrypt/decrypt. We should bypass those there too.
      // But let's set a dummy key to be safe if possible, or just let it be.
      // Better: VaultService checks mock mode and returns plain text.
      notifyListeners();
      return;
    }
    final masterHash = await _secureStorage.read(key: 'master_password_hash');
    _isInitialized = masterHash != null;
    notifyListeners();
  }

  Future<void> setupMasterPassword(String password) async {
    // In a real app, we'd generate a random salt and store it in Appwrite
    const salt = 'constant_salt_for_prototype';
    final key = await _encryptionService.deriveKey(password, salt);

    // Store a hash of the password to verify later
    // For simplicity in this prototype, we'll store a fixed string or the derived key's hash
    final bytes = await key.extractBytes();
    final hash = base64Encode(
      bytes,
    ); // Not a real hash, but works for prototype verification

    await _secureStorage.write(key: 'master_password_hash', value: hash);

    // For biometrics, store the session key securely
    await saveMasterKeySecurely(key);

    _sessionKey = key;
    _isLocked = false;
    _isInitialized = true;
    notifyListeners();
  }

  /// Unlocks the vault using the master password.
  /// This derives the session key and stores it in memory.
  Future<bool> unlockWithPassword(String password, String salt) async {
    try {
      final key = await _encryptionService.deriveKey(password, salt);
      final bytes = await key.extractBytes();
      final currentHash = base64Encode(bytes);

      final storedHash = await _secureStorage.read(key: 'master_password_hash');

      if (storedHash == currentHash) {
        _sessionKey = key;
        _isLocked = false;

        // Refresh the secure storage key for biometrics on successful password login
        await saveMasterKeySecurely(key);

        notifyListeners();
        return true;
      }
      return false;
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

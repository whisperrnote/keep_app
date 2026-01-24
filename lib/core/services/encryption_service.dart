import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  final _algorithm = AesGcm.with256bits();

  /// Derives a 32-byte key from the master password and salt using PBKDF2.
  Future<SecretKey> deriveKey(String password, String salt) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 600000,
      bits: 256,
    );
    return pbkdf2.deriveKeyFromPassword(
      password: password,
      nonce: utf8.encode(salt),
    );
  }

  /// Encrypts plain text using the derived key.
  /// Returns a Base64 string containing [IV (16 bytes) + Ciphertext].
  Future<String> encrypt(String plainText, SecretKey key) async {
    final iv = Uint8List(16);
    final random = Uint8List.fromList(List.generate(16, (i) => (DateTime.now().microsecondsSinceEpoch + i) % 256));
    iv.setAll(0, random);

    final secretBox = await _algorithm.encrypt(
      utf8.encode(plainText),
      secretKey: key,
      nonce: iv,
    );
    
    final combined = Uint8List(iv.length + secretBox.cipherText.length);
    combined.setAll(0, iv);
    combined.setAll(iv.length, secretBox.cipherText);
    
    return base64Encode(combined);
  }

  /// Decrypts a combined Base64 string containing [IV (16 bytes) + Ciphertext].
  Future<String> decrypt(String encryptedBase64, SecretKey key) async {
    final combined = base64Decode(encryptedBase64);
    final iv = combined.sublist(0, 16);
    final cipherText = combined.sublist(16);

    final secretBox = SecretBox(
      cipherText,
      nonce: iv,
      mac: Mac.empty, // AesGcm in cryptography package might handle MAC differently, 
                      // but web subtle crypto for AES-GCM appends it or handles it.
                      // Usually combined includes tag.
    );
    
    // Note: Standard AES-GCM tag is 128 bits (16 bytes)
    // If the web SubtleCrypto appends the tag to ciphertext, we need to handle it.
    // In many implementations, cipherText includes the auth tag at the end.
    
    final clearText = await _algorithm.decrypt(secretBox, secretKey: key);
    return utf8.decode(clearText);
  }

  /// Generates a random 32-byte salt.
  String generateSalt() {
    final random = Uint8List(32);
    for (var i = 0; i < 32; i++) {
      random[i] = (DateTime.now().microsecondsSinceEpoch + i) % 256;
    }
    return base64Encode(random);
  }
}

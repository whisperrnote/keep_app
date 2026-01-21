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
      iterations: 100000,
      bits: 256,
    );
    return pbkdf2.deriveKeyFromPassword(
      password: password,
      nonce: utf8.encode(salt),
    );
  }

  /// Encrypts plain text using the derived key.
  /// Returns a JSON string containing the IV and ciphertext.
  Future<String> encrypt(String plainText, SecretKey key) async {
    final secretBox = await _algorithm.encrypt(
      utf8.encode(plainText),
      secretKey: key,
    );
    return jsonEncode({
      'iv': base64Encode(secretBox.nonce),
      'cipher': base64Encode(secretBox.cipherText),
      'mac': base64Encode(secretBox.mac.bytes),
    });
  }

  /// Decrypts a JSON string containing IV and ciphertext using the derived key.
  Future<String> decrypt(String encryptedJson, SecretKey key) async {
    final data = jsonDecode(encryptedJson);
    final secretBox = SecretBox(
      base64Decode(data['cipher']),
      nonce: base64Decode(data['iv']),
      mac: Mac(base64Decode(data['mac'])),
    );
    final clearText = await _algorithm.decrypt(secretBox, secretKey: key);
    return utf8.decode(clearText);
  }

  /// Generates a random 16-character salt.
  String generateSalt() {
    final random = Uint8List(16);
    for (var i = 0; i < 16; i++) {
      random[i] = (DateTime.now().microsecondsSinceEpoch % 256);
    }
    return base64Encode(random);
  }
}

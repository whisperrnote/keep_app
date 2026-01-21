import 'package:appwrite/appwrite.dart';
import '../constants/appwrite_constants.dart';
import 'appwrite_service.dart';
import '../models/credential_model.dart';
import 'vault_provider.dart';

class VaultService {
  final Databases _databases = AppwriteService().databases;
  final VaultProvider _vaultProvider = VaultProvider();

  Future<List<Credential>> listCredentials(String userId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.credentialsCollectionId,
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('\$createdAt'),
        ],
      );

      final credentials = response.documents
          .map((doc) => Credential.fromJson(doc.data))
          .toList();

      // Decrypt sensitive fields if vault is unlocked
      if (!_vaultProvider.isLocked) {
        for (var cred in credentials) {
          try {
            cred.password = await _vaultProvider.decryptData(cred.password);
            if (cred.totpSecret != null) {
              cred.totpSecret = await _vaultProvider.decryptData(
                cred.totpSecret!,
              );
            }
          } catch (e) {
            // Probably not encrypted or wrong key
          }
        }
      }

      return credentials;
    } catch (e) {
      throw Exception('Failed to list credentials: $e');
    }
  }

  Future<Credential> createCredential({
    required String userId,
    required String title,
    required String username,
    required String password,
    String? url,
    String? notes,
    String? totpSecret,
    required String category,
  }) async {
    try {
      // Encrypt sensitive fields
      final encryptedPassword = await _vaultProvider.encryptData(password);
      String? encryptedTotpSecret;
      if (totpSecret != null && totpSecret.isNotEmpty) {
        encryptedTotpSecret = await _vaultProvider.encryptData(totpSecret);
      }

      final doc = await _databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.credentialsCollectionId,
        documentId: ID.unique(),
        data: {
          'title': title,
          'username': username,
          'password': encryptedPassword,
          'url': url,
          'notes': notes,
          'totpSecret': encryptedTotpSecret,
          'category': category,
          'userId': userId,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        permissions: [
          Permission.read(Role.user(userId)),
          Permission.update(Role.user(userId)),
          Permission.delete(Role.user(userId)),
        ],
      );
      final credential = Credential.fromJson(doc.data);
      credential.password = password; // Return decrypted
      return credential;
    } catch (e) {
      throw Exception('Failed to create credential: $e');
    }
  }

  Future<void> deleteCredential(String credentialId) async {
    try {
      await _databases.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.credentialsCollectionId,
        documentId: credentialId,
      );
    } catch (e) {
      throw Exception('Failed to delete credential: $e');
    }
  }
}

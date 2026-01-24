import 'package:appwrite/appwrite.dart';
import '../constants/appwrite_constants.dart';
import 'appwrite_service.dart';
import '../models/credential_model.dart';
import '../models/totp_model.dart';
import 'vault_provider.dart';
import '../constants/app_constants.dart';

class VaultService {
  final Databases _databases = AppwriteService().databases;
  final VaultProvider _vaultProvider = VaultProvider();

  Future<List<Credential>> listCredentials(String userId) async {
    if (AppConstants.useMockMode) {
      return [
        Credential(
          id: '1',
          title: 'Mock Google Account',
          username: 'mockuser@gmail.com',
          password: 'mock_password_123',
          category: 'Social',
          userId: userId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
    }
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
            cred.username = await _vaultProvider.decryptData(cred.username);
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
      final encryptedUsername = await _vaultProvider.encryptData(username);
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
          'username': encryptedUsername,
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
      credential.username = username;
      credential.password = password; 
      return credential;
    } catch (e) {
      throw Exception('Failed to create credential: $e');
    }
  }

  Future<List<TotpItem>> listTotpSecrets(String userId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.totpSecretsCollectionId,
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('\$createdAt'),
        ],
      );

      final items = response.documents
          .map((doc) => TotpItem.fromJson(doc.data))
          .toList();

      if (!_vaultProvider.isLocked) {
        for (var item in items) {
          try {
            item.secretKey = await _vaultProvider.decryptData(item.secretKey);
          } catch (e) {
            item.secretKey = '[LOCKED]';
          }
        }
      }
      return items;
    } catch (e) {
      throw Exception('Failed to list TOTP secrets: $e');
    }
  }

  Future<void> deleteTotpSecret(String id) async {
    try {
      await _databases.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.totpSecretsCollectionId,
        documentId: id,
      );
    } catch (e) {
      throw Exception('Failed to delete TOTP secret: $e');
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

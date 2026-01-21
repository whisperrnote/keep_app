import 'package:appwrite/appwrite.dart';
import '../constants/appwrite_constants.dart';
import 'appwrite_service.dart';
import '../models/credential_model.dart';

class VaultService {
  final Databases _databases = AppwriteService().databases;

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
      return response.documents
          .map((doc) => Credential.fromJson(doc.data))
          .toList();
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
    required String category,
  }) async {
    try {
      final doc = await _databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.credentialsCollectionId,
        documentId: ID.unique(),
        data: {
          'title': title,
          'username': username,
          'password': password,
          'url': url,
          'notes': notes,
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
      return Credential.fromJson(doc.data);
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

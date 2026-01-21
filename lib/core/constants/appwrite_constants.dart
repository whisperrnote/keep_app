class AppwriteConstants {
  static const String endpoint = 'https://fra.cloud.appwrite.io/v1';
  static const String projectId = '67fe9627001d97e37ef3';
  static const String databaseId = '67ff05a9000296822396';

  // Collections
  static const String usersCollectionId = '67ff05c900247b5673d3';
  static const String credentialsCollectionId =
      '67ff05f3002502ef239e'; // Linked to Credentials in Keep
  static const String categoriesCollectionId = 'categories';
  static const String securityAuditCollectionId = 'securityAudit';
  static const String commentsCollectionId = 'comments';
  static const String reactionsCollectionId = 'reactions';
  static const String activityLogCollectionId = 'activityLog';

  // Buckets
  static const String profilePicturesBucketId = 'profile_pictures';
  static const String notesAttachmentsBucketId = 'notes_attachments';
}

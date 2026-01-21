class Credential {
  final String id;
  final String title;
  final String username;
  final String password;
  final String? url;
  final String? notes;
  final String category; // social, work, finance, etc.
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Credential({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    this.url,
    this.notes,
    required this.category,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Credential.fromJson(Map<String, dynamic> json) {
    return Credential(
      id: json['\$id'] ?? '',
      title: json['title'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      url: json['url'],
      notes: json['notes'],
      category: json['category'] ?? 'general',
      userId: json['userId'] ?? '',
      createdAt: DateTime.parse(json['\$createdAt']),
      updatedAt: DateTime.parse(json['\$updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'username': username,
      'password': password,
      'url': url,
      'notes': notes,
      'category': category,
      'userId': userId,
    };
  }
}

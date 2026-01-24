class TotpItem {
  final String id;
  final String? issuer;
  final String? accountName;
  String secretKey;
  final int period;
  final int digits;
  final String algorithm;
  final String? folderId;
  final String userId;

  TotpItem({
    required this.id,
    this.issuer,
    this.accountName,
    required this.secretKey,
    this.period = 30,
    this.digits = 6,
    this.algorithm = 'SHA1',
    this.folderId,
    required this.userId,
  });

  factory TotpItem.fromJson(Map<String, dynamic> json) {
    return TotpItem(
      id: json['\$id'] ?? '',
      issuer: json['issuer'],
      accountName: json['accountName'],
      secretKey: json['secretKey'] ?? '',
      period: json['period'] ?? 30,
      digits: json['digits'] ?? 6,
      algorithm: json['algorithm'] ?? 'SHA1',
      folderId: json['folderId'],
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'issuer': issuer,
      'accountName': accountName,
      'secretKey': secretKey,
      'period': period,
      'digits': digits,
      'algorithm': algorithm,
      'folderId': folderId,
      'userId': userId,
    };
  }
}

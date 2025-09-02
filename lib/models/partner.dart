// models/partner.dart
class Partner {
  final int id;
  final String userId;
  final String name;
  final String email;
  final String mobile;
  final String businessType;
  final String companyName;
  final String partnerSince;

  Partner({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.mobile,
    required this.businessType,
    required this.companyName,
    required this.partnerSince,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      businessType: json['businessType'] ?? '',
      companyName: json['companyName'] ?? '',
      partnerSince: json['createdAt'] != null
          ? _formatDate(json['createdAt'])
          : 'Unknown',
    );
  }

  static String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}
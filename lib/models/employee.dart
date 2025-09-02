// models/employee.dart
class Employee {
  final String id;
  final String username;
  final String email;
  final String mobile;
  final String empId;
  final DateTime? createdAt;

  Employee({
    required this.id,
    required this.username,
    required this.email,
    required this.mobile,
    required this.empId,
    this.createdAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      empId: json['empId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'mobile': mobile,
      'empId': empId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  Employee copyWith({
    String? id,
    String? username,
    String? email,
    String? mobile,
    String? empId,
    DateTime? createdAt,
  }) {
    return Employee(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      empId: empId ?? this.empId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
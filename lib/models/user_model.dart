class UserModel {
  final String? id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final bool isActive;
  final DateTime? createdAt;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role = 'user',
    this.isActive = true,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'user',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      'role': role,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}

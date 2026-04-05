class UserModel {
  final String id;
  final String phone;
  final String firstName;
  final String lastName;
  final String role;
  final String? email;
  final String? avatar;
  final bool isActive;

  UserModel({
    required this.id,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.email,
    this.avatar,
    this.isActive = true,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role'] ?? 'member',
      email: json['email'],
      avatar: json['avatar'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'first_name': firstName,
        'last_name': lastName,
        'role': role,
        'email': email,
        'avatar': avatar,
      };
}

class UserModel {
  final String uid;
  final String email;
  final String role;
  final String? displayName;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    this.role = 'Admin',
    this.displayName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'displayName': displayName ?? '',
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return UserModel(
      uid: id ?? map['uid'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'Admin',
      displayName: map['displayName'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

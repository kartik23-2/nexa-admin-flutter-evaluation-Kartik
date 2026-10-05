class EmployeeModel {
  final String id;
  final String name;
  final String mobile;
  final String email;
  final String designation;
  final String branchId;
  final String status;
  final String? photoUrl;
  final DateTime createdAt;

  const EmployeeModel({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.designation,
    required this.branchId,
    this.status = 'Active',
    this.photoUrl,
    required this.createdAt,
  });

  bool get isActive => status.toLowerCase() == 'active';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
      'designation': designation,
      'branchId': branchId,
      'status': status,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory EmployeeModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return EmployeeModel(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      mobile: map['mobile'] ?? '',
      email: map['email'] ?? '',
      designation: map['designation'] ?? '',
      branchId: map['branchId'] ?? '',
      status: map['status'] ?? 'Active',
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  EmployeeModel copyWith({
    String? id,
    String? name,
    String? mobile,
    String? email,
    String? designation,
    String? branchId,
    String? status,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      designation: designation ?? this.designation,
      branchId: branchId ?? this.branchId,
      status: status ?? this.status,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

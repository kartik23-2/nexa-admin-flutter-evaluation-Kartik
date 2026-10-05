class CustomerModel {
  final String id;
  final String name;
  final String mobile;
  final String email;
  final String status; // 'New', 'Contacted', 'Interested', 'Converted', 'Rejected'
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    this.status = 'New',
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return CustomerModel(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      mobile: map['mobile'] ?? '',
      email: map['email'] ?? '',
      status: map['status'] ?? 'New',
      notes: map['notes'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? mobile,
    String? email,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

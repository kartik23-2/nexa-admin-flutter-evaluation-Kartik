class BranchModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radius; // In meters
  final String address;
  final DateTime createdAt;

  const BranchModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.address = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BranchModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return BranchModel(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      radius: (map['radius'] as num?)?.toDouble() ?? 100.0,
      address: map['address'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  BranchModel copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    double? radius,
    String? address,
    DateTime? createdAt,
  }) {
    return BranchModel(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

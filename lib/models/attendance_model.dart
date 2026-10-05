class AttendanceModel {
  final String id;
  final String employeeId;
  final String employeeName;
  final String branchId;
  final String branchName;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double distanceMeters;
  final String status; // 'Present', 'Rejected'
  final String verificationNote;

  const AttendanceModel({
    required this.id,
    required this.employeeId,
    this.employeeName = '',
    required this.branchId,
    this.branchName = '',
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    required this.status,
    required this.verificationNote,
  });

  bool get isPresent => status.toLowerCase() == 'present';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'branchId': branchId,
      'branchName': branchName,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'distanceMeters': distanceMeters,
      'status': status,
      'verificationNote': verificationNote,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return AttendanceModel(
      id: docId ?? map['id'] ?? '',
      employeeId: map['employeeId'] ?? '',
      employeeName: map['employeeName'] ?? '',
      branchId: map['branchId'] ?? '',
      branchName: map['branchName'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      distanceMeters: (map['distanceMeters'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'Rejected',
      verificationNote: map['verificationNote'] ?? '',
    );
  }

  AttendanceModel copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    String? branchId,
    String? branchName,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    double? distanceMeters,
    String? status,
    String? verificationNote,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      status: status ?? this.status,
      verificationNote: verificationNote ?? this.verificationNote,
    );
  }
}

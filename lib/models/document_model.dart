class DocumentModel {
  final String id;
  final String entityType; // 'customer', 'employee', 'general'
  final String entityId;
  final String entityName;
  final String type; // 'Aadhaar Card', 'PAN Card', 'Driving License', 'Passport', 'ID Proof', 'Other'
  final String fileUrl;
  final String fileName;
  final DateTime uploadedAt;
  final String uploadedBy;

  const DocumentModel({
    required this.id,
    this.entityType = 'customer',
    required this.entityId,
    this.entityName = '',
    required this.type,
    required this.fileUrl,
    required this.fileName,
    required this.uploadedAt,
    required this.uploadedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entityType': entityType,
      'entityId': entityId,
      'entityName': entityName,
      'type': type,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'uploadedAt': uploadedAt.toIso8601String(),
      'uploadedBy': uploadedBy,
    };
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return DocumentModel(
      id: docId ?? map['id'] ?? '',
      entityType: map['entityType'] ?? 'customer',
      entityId: map['entityId'] ?? '',
      entityName: map['entityName'] ?? '',
      type: map['type'] ?? 'ID Proof',
      fileUrl: map['fileUrl'] ?? '',
      fileName: map['fileName'] ?? '',
      uploadedAt: map['uploadedAt'] != null
          ? DateTime.tryParse(map['uploadedAt']) ?? DateTime.now()
          : DateTime.now(),
      uploadedBy: map['uploadedBy'] ?? 'Administrator',
    );
  }

  DocumentModel copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? entityName,
    String? type,
    String? fileUrl,
    String? fileName,
    DateTime? uploadedAt,
    String? uploadedBy,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      entityName: entityName ?? this.entityName,
      type: type ?? this.type,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      uploadedBy: uploadedBy ?? this.uploadedBy,
    );
  }
}

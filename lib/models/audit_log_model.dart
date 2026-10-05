class AuditLogModel {
  final String id;
  final String action;
  final String entityType;
  final String entityId;
  final String description;
  final String performedBy;
  final String userId;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const AuditLogModel({
    required this.id,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.description,
    required this.performedBy,
    required this.userId,
    required this.timestamp,
    this.metadata = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'description': description,
      'performedBy': performedBy,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory AuditLogModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return AuditLogModel(
      id: docId ?? map['id'] ?? '',
      action: map['action'] ?? '',
      entityType: map['entityType'] ?? 'General',
      entityId: map['entityId'] ?? '',
      description: map['description'] ?? '',
      performedBy: map['performedBy'] ?? 'Administrator',
      userId: map['userId'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }
}

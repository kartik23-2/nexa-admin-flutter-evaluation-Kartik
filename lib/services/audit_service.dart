import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/firestore_collections.dart';
import '../models/audit_log_model.dart';

class AuditService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AuditService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _auditRef =>
      _firestore.collection(FirestoreCollections.auditLogs);

  Stream<List<AuditLogModel>> streamAuditLogs() {
    return _auditRef
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AuditLogModel.fromMap(doc.data(), docId: doc.id);
      }).toList();
    });
  }

  Future<List<AuditLogModel>> getAuditLogs({String? entityType}) async {
    Query<Map<String, dynamic>> query = _auditRef.orderBy('timestamp', descending: true);
    if (entityType != null && entityType != 'All') {
      query = query.where('entityType', isEqualTo: entityType);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => AuditLogModel.fromMap(doc.data(), docId: doc.id))
        .toList();
  }

  Future<void> logEvent({
    required String action,
    required String entityType,
    required String entityId,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = _auth.currentUser;
      final docRef = _auditRef.doc();

      await docRef.set({
        'id': docRef.id,
        'action': action,
        'entityType': entityType,
        'entityId': entityId,
        'description': description,
        'performedBy': user?.email ?? 'System Administrator',
        'userId': user?.uid ?? 'system',
        'metadata': metadata ?? {},
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[AuditService] Failed to record audit log: $e');
    }
  }
}

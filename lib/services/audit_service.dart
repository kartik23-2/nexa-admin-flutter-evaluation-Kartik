import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/firestore_collections.dart';

class AuditService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AuditService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<void> logEvent({
    required String action,
    required String entityType,
    required String entityId,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = _auth.currentUser;
      final docRef = _firestore.collection(FirestoreCollections.auditLogs).doc();

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

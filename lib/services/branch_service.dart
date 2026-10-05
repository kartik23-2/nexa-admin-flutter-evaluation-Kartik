import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/firestore_collections.dart';
import '../models/branch_model.dart';
import 'audit_service.dart';

class BranchService {
  final FirebaseFirestore _firestore;
  final AuditService _auditService;

  BranchService({
    FirebaseFirestore? firestore,
    AuditService? auditService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auditService = auditService ?? AuditService();

  CollectionReference<Map<String, dynamic>> get _branchesRef =>
      _firestore.collection(FirestoreCollections.branches);

  Stream<List<BranchModel>> streamBranches() {
    return _branchesRef
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return BranchModel.fromMap(doc.data(), docId: doc.id);
      }).toList();
    });
  }

  Future<List<BranchModel>> getBranches() async {
    final snapshot = await _branchesRef.orderBy('name').get();
    return snapshot.docs
        .map((doc) => BranchModel.fromMap(doc.data(), docId: doc.id))
        .toList();
  }

  Future<BranchModel?> getBranchById(String id) async {
    final doc = await _branchesRef.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return BranchModel.fromMap(doc.data()!, docId: doc.id);
  }

  Future<String> addBranch(BranchModel branch) async {
    final docRef = _branchesRef.doc();
    final newBranch = branch.copyWith(id: docRef.id);
    await docRef.set(newBranch.toMap());

    // Trigger Audit Log
    await _auditService.logEvent(
      action: 'BRANCH_CREATED',
      entityType: 'Branch',
      entityId: docRef.id,
      description: 'Created branch "${branch.name}" with ${branch.radius}m geofence radius',
      metadata: {
        'name': branch.name,
        'latitude': branch.latitude,
        'longitude': branch.longitude,
        'radius': branch.radius,
      },
    );

    return docRef.id;
  }

  Future<void> updateBranch(
    BranchModel branch, {
    double? previousRadius,
    double? previousLat,
    double? previousLng,
  }) async {
    await _branchesRef.doc(branch.id).update(branch.toMap());

    final bool geofenceChanged = (previousRadius != null && previousRadius != branch.radius) ||
        (previousLat != null && previousLat != branch.latitude) ||
        (previousLng != null && previousLng != branch.longitude);

    if (geofenceChanged) {
      await _auditService.logEvent(
        action: 'GEOFENCE_UPDATED',
        entityType: 'Branch',
        entityId: branch.id,
        description: 'Geofence boundary modified for branch "${branch.name}" (radius: ${branch.radius}m, lat: ${branch.latitude}, lng: ${branch.longitude})',
        metadata: {
          'previousRadius': previousRadius,
          'newRadius': branch.radius,
          'previousLat': previousLat,
          'newLat': branch.latitude,
          'previousLng': previousLng,
          'newLng': branch.longitude,
        },
      );
    } else {
      await _auditService.logEvent(
        action: 'BRANCH_UPDATED',
        entityType: 'Branch',
        entityId: branch.id,
        description: 'Updated details for branch "${branch.name}"',
        metadata: branch.toMap(),
      );
    }
  }

  Future<void> deleteBranch(String id, String branchName) async {
    await _branchesRef.doc(id).delete();

    await _auditService.logEvent(
      action: 'BRANCH_DELETED',
      entityType: 'Branch',
      entityId: id,
      description: 'Deleted branch "$branchName"',
      metadata: {'id': id, 'name': branchName},
    );
  }
}

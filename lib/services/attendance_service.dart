import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/firestore_collections.dart';
import '../models/attendance_model.dart';
import 'audit_service.dart';

class AttendanceService {
  final FirebaseFirestore _firestore;
  final AuditService _auditService;

  AttendanceService({
    FirebaseFirestore? firestore,
    AuditService? auditService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auditService = auditService ?? AuditService();

  CollectionReference<Map<String, dynamic>> get _attendanceRef =>
      _firestore.collection(FirestoreCollections.attendance);

  Stream<List<AttendanceModel>> streamAttendanceLogs() {
    return _attendanceRef
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AttendanceModel.fromMap(doc.data(), docId: doc.id);
      }).toList();
    });
  }

  Future<List<AttendanceModel>> getAttendanceLogs({
    DateTime? date,
    String? status,
  }) async {
    Query<Map<String, dynamic>> query = _attendanceRef.orderBy('timestamp', descending: true);

    if (status != null && status != 'All') {
      query = query.where('status', isEqualTo: status);
    }

    if (date != null) {
      final start = DateTime(date.year, date.month, date.day);
      final end = DateTime(date.year, date.month, date.day, 23, 59, 59);
      query = query
          .where('timestamp', isGreaterThanOrEqualTo: start.toIso8601String())
          .where('timestamp', isLessThanOrEqualTo: end.toIso8601String());
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => AttendanceModel.fromMap(doc.data(), docId: doc.id))
        .toList();
  }

  Future<String> recordAttendance(AttendanceModel attendance) async {
    final docRef = _attendanceRef.doc();
    final newRecord = attendance.copyWith(id: docRef.id);
    await docRef.set(newRecord.toMap());

    // Trigger Audit Log
    await _auditService.logEvent(
      action: 'ATTENDANCE_RECORDED',
      entityType: 'Attendance',
      entityId: docRef.id,
      description: 'Attendance ${attendance.status} recorded for ${attendance.employeeName} at ${attendance.branchName} (Distance: ${attendance.distanceMeters.toStringAsFixed(1)}m)',
      metadata: {
        'employeeId': attendance.employeeId,
        'branchId': attendance.branchId,
        'status': attendance.status,
        'distanceMeters': attendance.distanceMeters,
        'verificationNote': attendance.verificationNote,
      },
    );

    return docRef.id;
  }
}

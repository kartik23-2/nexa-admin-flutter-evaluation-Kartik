import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/firestore_collections.dart';
import '../models/dashboard_stats_model.dart';

class DashboardService {
  final FirebaseFirestore _firestore;

  DashboardService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<DashboardStatsModel> fetchDashboardStats() async {
    try {
      // 1. Total Employees
      final employeesSnap = await _firestore
          .collection(FirestoreCollections.employees)
          .count()
          .get()
          .catchError((_) => const AggregateQuerySnapshot());
      final totalEmployees = employeesSnap.count ?? 0;

      // 2. Attendance count for today
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

      int presentCount = 0;
      int absentCount = 0;

      try {
        final attendanceSnap = await _firestore
            .collection(FirestoreCollections.attendance)
            .where('timestamp', isGreaterThanOrEqualTo: startOfToday.toIso8601String())
            .where('timestamp', isLessThanOrEqualTo: endOfToday.toIso8601String())
            .get();

        for (final doc in attendanceSnap.docs) {
          final status = doc.data()['status']?.toString();
          if (status == 'Present') {
            presentCount++;
          } else if (status == 'Absent' || status == 'Rejected') {
            absentCount++;
          }
        }
      } catch (e) {
        debugPrint('[DashboardService] Attendance query notice: $e');
      }

      // 3. Total Customers / Leads
      final customersSnap = await _firestore
          .collection(FirestoreCollections.customers)
          .count()
          .get()
          .catchError((_) => const AggregateQuerySnapshot());
      final totalCustomers = customersSnap.count ?? 0;

      // 4. Pending Approvals (Expenses)
      final pendingExpensesSnap = await _firestore
          .collection(FirestoreCollections.expenses)
          .where('status', isEqualTo: 'Pending')
          .count()
          .get()
          .catchError((_) => const AggregateQuerySnapshot());
      final pendingApprovals = pendingExpensesSnap.count ?? 0;

      // 5. Today's Collections (Approved collection amounts / payments)
      double todayCollections = 0.0;
      try {
        final collectionsSnap = await _firestore
            .collection(FirestoreCollections.expenses)
            .where('status', isEqualTo: 'Approved')
            .get();

        for (final doc in collectionsSnap.docs) {
          final amt = doc.data()['amount'];
          if (amt is num) {
            todayCollections += amt.toDouble();
          }
        }
      } catch (e) {
        debugPrint('[DashboardService] Collections query notice: $e');
      }

      return DashboardStatsModel(
        totalEmployees: totalEmployees,
        presentCount: presentCount,
        absentCount: absentCount,
        totalCustomers: totalCustomers,
        pendingApprovals: pendingApprovals,
        todayCollections: todayCollections,
      );
    } catch (e) {
      debugPrint('[DashboardService] General fetch error: $e');
      return const DashboardStatsModel();
    }
  }
}

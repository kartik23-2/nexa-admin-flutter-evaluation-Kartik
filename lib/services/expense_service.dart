import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/firestore_collections.dart';
import '../models/expense_model.dart';
import 'audit_service.dart';

class ExpenseService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final AuditService _auditService;

  ExpenseService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    AuditService? auditService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _auditService = auditService ?? AuditService();

  CollectionReference<Map<String, dynamic>> get _expensesRef =>
      _firestore.collection(FirestoreCollections.expenses);

  Stream<List<ExpenseModel>> streamExpenses() {
    return _expensesRef
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ExpenseModel.fromMap(doc.data(), docId: doc.id);
      }).toList();
    });
  }

  Future<List<ExpenseModel>> getExpenses({String? status}) async {
    Query<Map<String, dynamic>> query = _expensesRef.orderBy('submittedAt', descending: true);
    if (status != null && status != 'All') {
      query = query.where('status', isEqualTo: status);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ExpenseModel.fromMap(doc.data(), docId: doc.id))
        .toList();
  }

  Future<ExpenseModel?> getExpenseById(String id) async {
    final doc = await _expensesRef.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return ExpenseModel.fromMap(doc.data()!, docId: doc.id);
  }

  Future<String> createExpense(ExpenseModel expense) async {
    final docRef = _expensesRef.doc();
    final newExpense = expense.copyWith(
      id: docRef.id,
      submittedAt: DateTime.now(),
      status: 'Pending',
    );
    await docRef.set(newExpense.toMap());

    // Trigger Audit Log
    await _auditService.logEvent(
      action: 'EXPENSE_SUBMITTED',
      entityType: 'Expense',
      entityId: docRef.id,
      description: 'Submitted expense request of \$${expense.amount.toStringAsFixed(2)} (${expense.category}) for ${expense.employeeName}',
      metadata: {
        'amount': expense.amount,
        'category': expense.category,
        'employeeId': expense.employeeId,
        'employeeName': expense.employeeName,
      },
    );

    return docRef.id;
  }

  Future<void> approveExpense({
    required String expenseId,
    required String approvedBy,
    required ExpenseModel expense,
  }) async {
    final now = DateTime.now();
    await _expensesRef.doc(expenseId).update({
      'status': 'Approved',
      'approvedAt': now.toIso8601String(),
      'approvedBy': approvedBy,
      'rejectionReason': null,
    });

    // Trigger Audit Log
    await _auditService.logEvent(
      action: 'EXPENSE_APPROVED',
      entityType: 'Expense',
      entityId: expenseId,
      description: 'Approved expense of \$${expense.amount.toStringAsFixed(2)} for ${expense.employeeName}',
      metadata: {
        'expenseId': expenseId,
        'amount': expense.amount,
        'employeeName': expense.employeeName,
        'decision': 'Approved',
        'approvedBy': approvedBy,
      },
    );
  }

  Future<void> rejectExpense({
    required String expenseId,
    required String reason,
    required String rejectedBy,
    required ExpenseModel expense,
  }) async {
    final now = DateTime.now();
    await _expensesRef.doc(expenseId).update({
      'status': 'Rejected',
      'rejectionReason': reason,
      'approvedAt': now.toIso8601String(),
      'approvedBy': rejectedBy,
    });

    // Trigger Audit Log
    await _auditService.logEvent(
      action: 'EXPENSE_REJECTED',
      entityType: 'Expense',
      entityId: expenseId,
      description: 'Rejected expense of \$${expense.amount.toStringAsFixed(2)} for ${expense.employeeName}. Reason: "$reason"',
      metadata: {
        'expenseId': expenseId,
        'amount': expense.amount,
        'employeeName': expense.employeeName,
        'decision': 'Rejected',
        'reason': reason,
        'rejectedBy': rejectedBy,
      },
    );
  }
}
